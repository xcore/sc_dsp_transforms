// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/** THis function computes a forward FFT. The complex input array is
 * supplied as two arrays of integers, with numbers represented as
 * fixed-point values. The number of poits must be a power of 2, and the
 * array of sine values should contain a quarter sine-wave.
 *
 * \param re    real part of each input point
 *
 * \param im    imaginary part of each input point
 *
 * \param N     number of points. Must be a power of 2, both re and im should be N long
 *
 * \param sine  array of N/4 sine values, each represented as a sign bit with a 31 bit
 *              fraction. An implicit '1' is added at the end of the array (since +1
 *              cannot be represented) (Hmm - not happy about this, think again)
 */
void fftForward(int re[], int im[], int N, int sine[]);

void fftInverse(int re[], int im[], int N, int sine[]);

void fftTwiddle(int re[], int im[], int N);
