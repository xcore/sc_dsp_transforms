// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "stdio.h"
#include "xs1.h"
#include "huffman.h"
#include "fdctint.h"


static void p(int x[], int div) {
    for(int i = 0; i < 8; i++) {
        for(int j = 0; j < 8; j++) {
            printf("%8d ", x[i*8+j]/div);
        }
        printf("\n");
    }
    printf("%08x \n", x[64]);
}

const unsigned char quant[64] = {
        16, 11, 10, 16, 24, 40, 51, 61,
        12, 12, 14, 19, 26, 58, 60, 55,
        14, 13, 16, 24, 40, 57, 69, 56,
        14, 17, 22, 29, 51, 87, 80, 62,
        18, 22, 37, 56, 68, 109, 103, 77,
        24, 35, 55, 64, 81, 104, 113, 92,
        49, 64, 78, 87, 103, 121, 120, 101,
        72, 92, 95, 98, 112, 100, 103, 99
};


int main(void) {
    streaming chan c;
    streaming chan toDCT;
    int t1, t0;
    timer t;
    int x[65] = {
        52,55,61, 66, 70, 61,64,73,
        63,59,55, 90,109, 85,69,72,
        62,59,68,113,144,104,66,73,
        63,58,71,122,154,106,70,69,
        67,61,68,104,126, 88,68,70,
        79,65,60, 70, 77, 68,58,75,
        85,71,64, 59, 55, 61,65,83,
        87,79,69, 68, 65, 76,78,94, 0xdeadbeef
    };
    int quant2[65];
    quantDCT(quant2, quant);
    par {
        fdctintS(toDCT, quant2);
        {
        t :> t0;
            doDCT(toDCT, x);
        t :> t1;
            endDCT(toDCT);
            printf("DCT: %d us for 64 pixels @ 100 MIPS: %d pixels/sec (50 MIPS)\n", (t1-t0)/100, 32*(100000000/(t1-t0)));
            printf("grey QVGA: %d fps (1 thread, 50 MIPS)\n", (32*(100000000/(t1-t0)))/320/240);
            printf("grey  VGA: %d fps (1 thread, 50 MIPS)\n", (32*(100000000/(t1-t0)))/640/480);
            p(x, 1);
            huffEncode(c, x);
        t :> t0;
            huffEncode(c, x);
        t :> t1;
            printf("HUFF: %d us for 64 pixels @ 100 MIPS: %d pixels/sec (50 MIPS)\n", (t1-t0)/100, 32*(100000000/(t1-t0)));
            printf("grey QVGA: %d fps (2 threads, 50 MIPS)\n", (32*(100000000/(t1-t0)))/320/240);
            printf("grey  VGA: %d fps (2 threads, 50 MIPS)\n", (32*(100000000/(t1-t0)))/640/480);
            huffEncode(c, x);
            soutct(c, 5);
        }
        emitter(c);
    }
    return 0;
}
