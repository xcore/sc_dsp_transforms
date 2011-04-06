#include "huffTables.h"
#include <stdio.h>
#include <print.h>
#include <xs1.h>

#define SOF0 0xFFC0

#define SOI 0xFFD8
#define EOI 0xFFD9
#define DHT 0xFFC4
#define DQT 0xFFDB
#define SOS 0xFFDA
#define RST0 0xFFD0

static void outByte(int x) {
//    printf("%02x ", x & 0xff);
}

void header4(int header) {
//    printf("%02x %02x ", header >> 8, header & 0xff);    
}

void header2(int header) {
//    printf("%02x ", header & 0xff);    
}

void hufftableprint(const unsigned char lengths[], const short codes[], int len, int isAC) {
    int allL[17];
    int Lh = 3;
    for(int i = 0; i < 17; i++) {
        allL[i] = 0;
    }
    for(int i = 0; i < len; i++) {
        allL[(int)lengths[i]] ++;
    }
    for(int i = 1; i < 17; i++) {
        Lh += allL[i]+1;
    }
    header4(DHT);
    header4(Lh);
    header2(isAC<<4);
    for(int i = 1; i < 17; i++) {
        header2(allL[i]);
    }
    for(int i = 1; i < 17; i++) {
        if (len > 100) {
            for(int k = 0; k < 16; k++) {
                for(int j = 0; j <= 10; j++) {
                    int index = k | j << 4;
                    if (lengths[index] == i) {
                        header2(j | k << 4);
                    }
                }
            }
        } else {
            for(int k = 0; k < len; k++) {
                if (lengths[k] == i) {
                    header2(k);
                }
            }
        }
    }
}

extern const unsigned char quant[64];
void emitter(streaming chanend generator) {
    unsigned char length;
    int code;
    int bits =0;
    int numbits = 0;
    int first = 1;

    while(1) {
        if(stestct(generator)) {
            break;
        }
        generator :> length;
        generator :> code;
        if (first) {
            first = 0;
            header4(SOI);
            header4(SOF0);
            header4(11); // length
            header2(8); // Depth
            header4(8); // Y
            header4(24); // X
            header2(1); // Number
            
            header2(0); // 
            header2(0x11); // KX/Y ratios
            header2(0); // Quantisation table index
            
            header4(DQT);
            header4(67);
            header2(0x00);
            header2(quant[0]);
            for(int i = 0; i < 63; i++) {
                header2(quant[(int)ordering[i]]);
            }
            
            hufftableprint(dclengths, dccodes, 12, 0);
            hufftableprint(aclengths, accodes, 176, 1);
    
            header4(SOS);
            header4(8); // length
            header2(1); 
            
            header2(0); // Scan components 
            header2(0x00); // Entropy encoding tables
            
            header2(0); // Scan start
            header2(63); // Scan end
            header2(0x00); // Ahl
        }
        bits <<= length;
        bits |= code & ((1<<length)-1);
        numbits += length;
        if (numbits > 8) {
            int l = numbits & 7;
            if (numbits > 16) {
                outByte(bits >> (l + 8));
            }
            outByte( bits >> l);
            numbits &= 7;
        }
    }    
    outByte( bits << (8-numbits));
    header4(RST0);
    header4(EOI);
    sinct(generator);
}

static inline void emit(streaming chanend emit, unsigned char length, int code) {
    emit <: length;
    emit <: code;
}


static inline int magnitude(int a) {
    int exp;
    asm("clz %0, %1" : "=r" (exp) : "r" (a));
    return 32 - exp;
}




int dcval = 0;

#pragma unsafe arrays

void huffEncode(streaming chanend emitter, int x[64]) {
    int v = x[0];
    int dcdiff = v - dcval;
    int exp, t, code;
    int run = 0;
    dcval = v;
    if (dcdiff < 0) {
        t = -dcdiff;
        dcdiff--;
    } else {
        t = dcdiff;
    }
    exp = magnitude(t);
    emit(emitter, dclengths[exp], dccodes[exp]);
    emit(emitter, exp, dcdiff);

#pragma loop unroll(3)
    for(int i = 0; i < 63; i++) {
        int o = ordering[i];
        v = x[o];
        if (v == 0) {
            run++;
        } else {
            while (run > 15) {
                emit(emitter, acl0xf0, accode0xf0);
                run -= 16;
            }
            if (v < 0) {
                t = -v;
                v--;
            } else {
                t = v;
            }
            exp = magnitude(t);
            code = exp << 4 | run;
            emit(emitter, aclengths[code], accodes[code]);
            emit(emitter, exp, v);
            run = 0;
        }
    }
    if (run > 15) {
        emit(emitter, acl0x00, accode0x00);
    }
}
