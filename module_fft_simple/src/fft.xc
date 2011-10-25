// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
#include "fft.h"
#include <xs1.h>
#include <xclib.h>
#include <stdio.h>

int sineValue(int sine[], int index, int N, int total) {
    int quart = total >> 2;
    int sgn = 1;
    index &= total - 1;
    if (index > quart * 2) {
        sgn = -1;
        index -= quart*2;
    }
    if (index <= quart) {
        return sgn * sine[index];
    }
    return sgn * sine[2*quart - index];
}

int cosValue(int sine[], int k, int N, int total) {
    return sineValue(sine, k*(total/N) + (total/4), N, total);
}

int sinValue(int sine[], int k, int N, int total) {
    return sineValue(sine, k*(total/N), N, total);
}

int mult(int a, int b) {
    int h, l;
    {h,l} = macs(a, b, 0, 0);
//    printf("%d times %d is %d\n", a, b, h<<1);
    return h << 2;        // TODO - this should be 2....
}


void fftTwiddle(int re[], int im[], int N) {
    unsigned int shift = clz(N);
    for(unsigned int i = 0; i < (N>>1); i++) {
        unsigned int rev = bitrev(i) >> (shift + 1);
        int t = re[i];
        re[i] = re[rev];
        re[rev] = t;
        t = im[i];
        im[i] = im[rev];
        im[rev] = t;
    }
}

void fftForward(int re[], int im[], int N, int sine[]) {
    for(int step = 2; step <= N; step = step * 2) {
        int step2 = step >> 1;
        int numberBlocks = N/step;           // TODO: remove division.
        for(int block = 0; block < N; block+=step) {
            for(int k = 0; k < step2; k++) {
                int tRe = re[block + k];
                int tIm = im[block + k];
                int tRe2 = re[block + k + step2];
                int tIm2 = im[block + k + step2];
                int rRe = cosValue(sine, k, step, N);
                int rIm = -sinValue(sine, k, step, N);
                int sRe2 = mult(tRe2, rRe) - mult(tIm2, rIm);
                int sIm2 = mult(tRe2, rIm) + mult(tIm2, rRe);

                re[block + k] = tRe + sRe2;
                im[block + k] = tIm + sIm2;
                re[block + k+step2] = tRe - sRe2;
                im[block + k+step2] = tIm - sIm2;

                printf("Butterfly on %d, %d : %d %d and %d %d -> %d %d and %d %d\n", block+k, block+k+step2, tRe, tIm, tRe2, tIm2, re[block + k], im[block + k], re[block + k+step2], im[block + k+step2]);

            }
        }
    }
}

void fftInverse(int re[], int im[], int N, int sine[]) {
}
