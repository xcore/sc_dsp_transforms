// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
#include "fft.h"
#include <xs1.h>
#include <xclib.h>
#include <stdio.h>

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
    unsigned int shift = 30-clz(N);
    for(unsigned int step = 2 ; step <= N; step = step * 2, shift--) {
        unsigned int step2 = step >> 1;
        unsigned int step4 = step2 >> 1;
        unsigned int k;
        for(k = 0; k < step4 + (step2&1); k++) {
            int rRe = sine[(N>>2)-(k<<shift)];
            int rIm = sine[k<<shift];
            for(int block = k; block < k+N; block+=step) {
                int tRe = re[block];
                int tIm = im[block];
                int tRe2 = re[block + step2];
                int tIm2 = im[block + step2];
                int h;
                unsigned l;
                int sRe2, sIm2;
                {h,l} = macs(tRe2, rRe, 0, 0x80000000);
                {h,l} = macs(tIm2, rIm, h, l);
                sRe2 = h;
                {h,l} = macs(tRe2, -rIm, 0, 0x80000000);
                {h,l} = macs(tIm2, rRe, h, l);
                sIm2 = h;
                tRe >>= 1;
                tIm >>= 1;
                re[block] = tRe + sRe2;
                im[block] = tIm + sIm2;
                re[block+step2] = tRe - sRe2;
                im[block+step2] = tIm - sIm2;
            }
        }
        for(k=(step2 & 1); k < step2-step4; k++) {
            int rRe = -sine[k<<shift];
            int rIm = sine[(N>>2)-(k<<shift)];
            for(int block = k+step4; block < k+step4+N; block+=step) {
                int tRe = re[block];
                int tIm = im[block];
                int tRe2 = re[block + step2];
                int tIm2 = im[block + step2];
                int h;
                unsigned l;
                int sRe2, sIm2;
                {h,l} = macs(tRe2, rRe, 0, 0x80000000);
                {h,l} = macs(tIm2, rIm, h, l);
                sRe2 = h;
                {h,l} = macs(tRe2, -rIm, 0, 0x80000000);
                {h,l} = macs(tIm2, rRe, h, l);
                sIm2 = h;
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

// Note: for an extra bit of precision change the 8 lines that use 0x80000000 or l>>31.

#pragma unsafe arrays
void fftInverse(int re[], int im[], int N, int sine[]) {
    unsigned int shift = 30-clz(N);
    for(unsigned int step = 2 ; step <= N; step = step * 2, shift--) {
        unsigned int step2 = step >> 1;
        unsigned int step4 = step2 >> 1;
        unsigned int k;
        for(k = 0; k < step4 + (step2&1); k++) {
            int rRe = sine[(N>>2)-(k<<shift)];
            int rIm = sine[k<<shift];
            for(int block = k; block < k+N; block+=step) {
                int tRe = re[block];
                int tIm = im[block];
                int tRe2 = re[block + step2];
                int tIm2 = im[block + step2];
                int h;
                unsigned l;
                int sRe2, sIm2;
                {h,l} = macs(tRe2, rRe, 0, 0x80000000);  // Make this 0x40000000
                {h,l} = macs(tIm2, -rIm, h, l);
                sRe2 = h << 1;// | l >> 31;              // And include this part
                {h,l} = macs(tRe2, rIm, 0, 0x80000000);
                {h,l} = macs(tIm2, rRe, h, l);
                sIm2 = h << 1;// | l >> 31;

                re[block] = tRe + sRe2;
                im[block] = tIm + sIm2;
                re[block+step2] = tRe - sRe2;
                im[block+step2] = tIm - sIm2;
            }
        }
        for(k=(step2 & 1); k < step2-step4; k++) {
            int rRe = -sine[k<<shift];
            int rIm = sine[(N>>2)-(k<<shift)];
            for(int block = k+step4; block < k+step4+N; block+=step) {
                int tRe = re[block];
                int tIm = im[block];
                int tRe2 = re[block + step2];
                int tIm2 = im[block + step2];
                int h;
                unsigned l;
                int sRe2, sIm2;
                {h,l} = macs(tRe2, rRe, 0, 0x80000000);
                {h,l} = macs(tIm2, -rIm, h, l);
                sRe2 = h << 1;// | l >> 31;
                {h,l} = macs(tRe2, rIm, 0, 0x80000000);
                {h,l} = macs(tIm2, rRe, h, l);
                sIm2 = h << 1;// | l >> 31;

                re[block] = tRe + sRe2;
                im[block] = tIm + sIm2;
                re[block+step2] = tRe - sRe2;
                im[block+step2] = tIm - sIm2;
            }
        }
    }
}

// TODO.

complexMagnitudeSquared(int re[], int im[], int magnitude[], int N) {

}
