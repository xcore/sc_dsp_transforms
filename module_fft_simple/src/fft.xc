// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
#include "fft.h"
#include <xs1.h>
#include <xclib.h>
#include <stdio.h>

#pragma unsafe arrays
static inline int sineValue(int sine[], int index, int N, int total) {
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

static inline int cosValue(int sine[], int k, int N, int total) {
    return sineValue(sine, k*(total/N) + (total/4), N, total);
}

static inline int sinValue(int sine[], int k, int N, int total) {
    return sineValue(sine, k*(total/N), N, total);
}

static inline int mult(int a, int b) {
    int h, l;
    {h,l} = macs(a, b, 0, 0);
//    printf("%d times %d is %d\n", a, b, h<<1);
    return h << 2;        // TODO - this should be 2....
}


#pragma unsafe arrays
void fftTwiddle(int re[], int im[], int N) {
    unsigned int shift = clz(N);
    for(unsigned int i = 1; i < N-1; i++) {
        unsigned int rev = bitrev(i) >> (shift + 1);
        if (rev > i) {
            int t = re[i];
            re[i] = re[rev];
            re[rev] = t;
            t = im[i];
            im[i] = im[rev];
            im[rev] = t;
        }
    }
}

#pragma unsafe arrays
void fftForward(int re[], int im[], int N, int sine[]) {
    for(int step = 2; step <= N; step = step * 2) {
        int step2 = step >> 1;
        for(int k = 0; k < step2; k++) {
            int rRe = cosValue(sine, k, step, N);
            int rIm = -sinValue(sine, k, step, N);
            for(int block = k; block < k+N; block+=step) {
                int tRe = re[block];
                int tIm = im[block];
                int tRe2 = re[block + step2];
                int tIm2 = im[block + step2];
                int h;
                unsigned l;
                int sRe2, sIm2;
                {h,l} = macs(tRe2, rRe, 0, 0x40000000);
                {h,l} = macs(tIm2, -rIm, h, l);
                sRe2 = h << 1 | l >> 31;
                {h,l} = macs(tRe2, rIm, 0, 0x40000000);
                {h,l} = macs(tIm2, rRe, h, l);
                sIm2 = h << 1 | l >> 31;
                tRe >>= 1;
                tIm >>= 1;
                re[block] = tRe + sRe2;
                im[block] = tIm + sIm2;
                re[block+step2] = tRe - sRe2;
                im[block+step2] = tIm - sIm2;

            }
        }
    }
}

#pragma unsafe arrays
void fftInverse(int re[], int im[], int N, int sine[]) {
    for(int step = 2; step <= N; step = step * 2) {
        int step2 = step >> 1;
        for(int k = 0; k < step2; k++) {
            int rRe = cosValue(sine, k, step, N);
            int rIm = sinValue(sine, k, step, N);
            for(int block = k; block < k+N; block+=step) {
                int tRe = re[block];
                int tIm = im[block];
                int tRe2 = re[block + step2];
                int tIm2 = im[block + step2];
                int h;
                unsigned l;
                int sRe2, sIm2;
                {h,l} = macs(tRe2, rRe, 0, 0x20000000);
                {h,l} = macs(tIm2, -rIm, h, l);
                sRe2 = h << 2 | l >> 30;
                {h,l} = macs(tRe2, rIm, 0, 0x20000000);
                {h,l} = macs(tIm2, rRe, h, l);
                sIm2 = h << 2 | l >> 30;

                re[block] = tRe + sRe2;
                im[block] = tIm + sIm2;
                re[block+step2] = tRe - sRe2;
                im[block+step2] = tIm - sIm2;

            }
        }
    }
}
