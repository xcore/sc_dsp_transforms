#include "huffTables.h"
#include <stdio.h>
#include <print.h>
#include <xs1.h>

static void emitter(streaming chanend codes, streaming chanend generator) {
    unsigned char length;
    int code;
    int bits =0;
    int numbits = 0;

    while(1) {
        if(stestct(generator)) {
            int ct = sinct(generator);
            codes <: (unsigned char) (bits << (8-numbits) | 0xff >> numbits);
            soutct(codes, ct);
            sinct(codes);
            soutct(generator, ct);
            break;
        }
        generator :> length;
        generator :> code;
        bits <<= length;
        bits |= code & ((1<<length)-1);
        numbits += length;
        if (numbits >= 8) {
            int l = numbits & 7;
            if (numbits >= 16) {
                codes <: (unsigned char) (bits >> (l + 8));
            }
            codes <: (unsigned char) (bits >> l);
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



#pragma unsafe arrays

int doHuff(streaming chanend blocks, int x[64]) {
    int ret;
    asm("out res[%0], %1" :: "r" (blocks), "r" (x));
    asm("in %0, res[%1]" : "=r" (ret) : "r" (blocks));
    return ret;
}

void endHuff(streaming chanend blocks) {
    soutct(blocks, 5);
    sinct(blocks);
}

static void huffEncode(streaming chanend blocks, streaming chanend emitter) {
    int dcval = 0;
    int run = 0;// int b = 0;
    while(1) {
        int address;
        int v;
        int dcdiff;
        int exp, t, code;
        if (stestct(blocks)) {
            int ct = sinct(blocks);
            soutct(emitter, ct);
            sinct(emitter);
            soutct(blocks, ct);
            return;
        }
        blocks :> address;
//        printf("Encoding %08x\n", address);
        asm("ldw %0, %1[0]" : "=r" (v) : "r" (address)); //   v = addr[0];
        dcdiff = v - dcval;
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
            asm("ldw %0, %1[%2]" : "=r" (v) : "r" (address), "r" (o) ); //   v = addr[o];
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
        if (run > 0) {
            emit(emitter, acl0x00, accode0x00);
            run = 0;
        }
        blocks <: address;
    }
}

void processHuff(streaming chanend blocks, streaming chanend codes) {
    streaming chan c;
    par {
        huffEncode(blocks, c);
        emitter(codes, c);
    }
}

