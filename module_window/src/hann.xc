// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "stdio.h"
#include "hann.h"
#include "xs1.h"

static inline int hmul(int a, int b) {
    int h;
    unsigned l;
    {h,l} = macs(a, b, 0, 0);
    return h << 1 | l >> 31;
}

void windowHann(int output[], int data[], int offset, int N, int sine[]) {
    for(int i = 0; i < (N>>2); i++) {
        int s = sine[i]>>1;
//        printf("%d... %08x\n", i, s);
        output[1*(N>>2)-i] = hmul(data[1*(N>>2)-i+offset], 0x3fffffff-s);
        output[1*(N>>2)+i] = hmul(data[1*(N>>2)+i+offset], 0x3fffffff+s);
        output[3*(N>>2)-i] = hmul(data[3*(N>>2)-i+offset], 0x3fffffff+s);
        output[3*(N>>2)+i] = hmul(data[3*(N>>2)+i+offset], 0x3fffffff-s);
//        printf("done %d...\n", i);
    }
    output[0] = 0;
    output[N>>1] = hmul(data[(N>>1)+offset], 0x7ffffffe);
}
