// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "fftreal.h"
#include "fft.h"


#pragma unsafe arrays
void fftTwoRealsForward(int re1[], int re2[], int im1[], int im2[], int N, int sine[]) {
    fftTwiddle(re1, re2, N);
    fftForward(re1, re2, N, sine);
    im1[0] = 0;
    im2[0] = 0;
    for(int i = N >> 1; i != 0; i--) {
        im1[i] = (re2[i] - re2[N-i])>>1;
        im1[N-i] = -im1[i];
        im2[i] = (re1[N-i] - re1[i])>>1;
        im2[N-i] = -im2[i];
    }
    for(int i = N >> 1; i != 0; i--) {
        re1[i] = (re1[i] + re1[N-i]) >> 1;
        re1[N-i] = re1[i];
        re2[i] = (re2[i] + re2[N-i])>>1;
        re2[N-i] = re2[i];
    }
}

#pragma unsafe arrays
void fftTwoRealsInverse(int re1[], int re2[], int im1[], int im2[], int N, int sine[]) {
    for(int i = N >> 1; i != 0; i--) {
        re1[i] = re1[i] + im2[N-i];
        re1[N-i] = re1[N-i] + im2[i];
        re2[i] = re2[i] + im1[i];
        re2[N-i] = re2[N-i] + im1[N-i];
    }
    fftTwiddle(re1, re2, N);
    fftInverse(re1, re2, N, sine);
}
