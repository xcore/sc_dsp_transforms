// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/** Function that computes a Hann window over a set of input points.
 * 
 * \param[out] output Array of N points in which the windowed data will be
 *                    stored.
 *
 * \param[in] data    Array of input points
 *
 * \param[in] offset  index of the first input points
 *
 * \param[in] N       Window size
 *
 * \param[in] sine    Array with sine values, sine[i] =
 *                    sin(pi/2*N)*0x7fffffff. This array should be N
 *                    elements long. For windows where N is a power of 2,
 *                    use one of sine_8, sine_16, ... in sine.h in
 *                    module_fft_simple.

 */
extern void windowHann(int output[], int data[], int offset, int N, int sine[]);
