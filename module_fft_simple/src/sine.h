// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

extern const int sine_8[];
extern const int sine_16[];
extern const int sine_32[];
extern const int sine_64[];
extern const int sine_128[];
extern const int sine_256[];
extern const int sine_512[];
extern const int sine_1024[];
extern const int sine_2048[];
extern const int sine_4096[];
extern const int sine_8192[];

#define FFT_SINE0(N) sine_ ## N
#define FFT_SINE(N) FFT_SINE0(N)
