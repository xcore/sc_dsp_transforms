#include "huffTables.h"
#include <stdio.h>
#include <print.h>

static void outByte(int x) {
}

void emitter(streaming chanend generator) {
    unsigned char length;
    int code;
    int bits =0;
    int numbits = 0;
    while(1) {
        generator :> length;
        generator :> code;
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
    timer tt;
    int t0, t1;
    int v = x[0];
    int dcdiff = v - dcval;
    int exp, t, code;
    int run = 0;
    tt :> t0;
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
    tt :> t1;
            printf("%d pixels/sec (50 MIPS @ 400 MHz)\n", 32*(100000000/(t1-t0)));
            printf("grey QVGA: %d fps (1 thread, 50 MIPS @ 400 MHz)\n", (32*(100000000/(t1-t0)))/320/240);
            printf("grey  VGA: %d fps (1 thread, 50 MIPS @ 400 MHz)\n", (32*(100000000/(t1-t0)))/640/480);
}
