// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "fdctint.h"

void quantDCT(int preprocessedQuant[65], const unsigned char quantisationTable[64]) {
    for(int i = 0; i < 64; i++) {
        preprocessedQuant[i] = (4*(0x08000000/quantisationTable[i]));
    }
    preprocessedQuant[64] = 0;
}
