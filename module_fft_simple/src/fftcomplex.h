// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
/*! \file */


/** This function computes a forward FFT. The complex input array is
 * supplied as two arrays of integers, with numbers represented as
 * fixed-point values. The number of points must be a power of 2, and the
 * array of sine values should contain a quarter sine-wave. Use one of
 * sine_N provided in sine.h. The function does not perform a bit-twiddle -
 * if required then fftTwiddle() should be called beforehand.
 *
 * \param re    real part of each input point
 *
 * \param im    imaginary part of each input point
 *
 * \param N     number of points. Must be a power of 2, both re and im should be N long
 *
 * \param sine  array of N/4+1 sine values, each represented as a sign bit,
 *              and a 31 bit fraction. 1 should be represented as 0x7fffffff.
 *              Arrays are provided in sine.h; for example, for a 1024 point
 *              FFT use sin_1024.
 */
void fftForward(int re[], int im[], int N, int sine[]);

/** This function computes an inverse FFT. The complex input array is
 * supplied as two arrays of integers, with numbers represented as
 * fixed-point values. The number of points must be a power of 2, and the
 * array of sine values should contain a quarter sine-wave. Use one of
 * sine_N provided in sine.h. The function does not perform a bit-twiddle -
 * if required then fftTwiddle() should be called beforehand.
 *
 * \param re    real part of each input point
 *
 * \param im    imaginary part of each input point
 *
 * \param N     number of points. Must be a power of 2, both re and im should be N long
 *
 * \param sine  array of N/4+1 sine values, each represented as a sign bit,
 *              and a 31 bit fraction. 1 should be represented as 0x7fffffff.
 *              Arrays are provided in sine.h; for example, for a 1024 point
 *              FFT use sin_1024.
 */
void fftInverse(int re[], int im[], int N, int sine[]);

/** This function twiddles the arrays around prior to computing an FFT. A
 * calling sequence for a forward FFT involves fftTwiddle() followed by
 * fftForward(), and for an inverse FFT it involves fftTwiddle() followed
 * by fftInverse(). In some cases twiddling can be avoided, for example
 * when computing a convolution.
 *
 * \param re    real part of each input point
 *
 * \param im    imaginary part of each input point
 *
 * \param N     number of points. Must be a power of 2, both re and im should be N long
 */
void fftTwiddle(int re[], int im[], int N);
