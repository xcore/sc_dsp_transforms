// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*! \file */

/** This function computes the FFT of two real sequences in one go. It uses
 * a nifty trick (http://www.katjaas.nl/realFFT/realFFT.html) that enables
 * one to use a single complex FFT to compute two real FFTs simultaneously.
 * The real inputs should be in the first two real arrays, the output is in
 * the real and imaginary arrays (the output of a real FFT is still a
 * complex number).
 *
 * \param[in,out] re1    array of first set of real numbers on which to
 *                       compute FFT, on output this array stores the real
 *                       part of the complex FFT on this set of numbers.
 *
 * \param[in,out] re2    array of second set of real numbers on which to
 *                       compute FFT, on output this array stores the real
 *                       part of the complex FFT on this set of numbers.
 *
 * \param[out]    im1    imaginary parts of complex FFT of first array
 *
 * \param[out]    im2    imaginary parts of complex FFT of second array
 *
 * \param[in]     N      number of points
 *
 * \param[in]  sine  array of N/4+1 sine values, each represented as a sign bit,
 *              and a 31 bit fraction. 1 should be represented as 0x7fffffff.
 *              Arrays are provided in sine.h; for example, for a 1024 point
 *              FFT use sin_1024.
 */
void fftTwoRealsForward(int re1[], int re2[], int im1[], int im2[], int N, int sine[]);

/** This function computes the inverse FFT on two sets of complex data that
 * are known to result in real numbers only in one go. It uses a nifty
 * trick (http://www.katjaas.nl/realFFT/realFFT.html) that enables one to
 * use a single complex inverse FFT to compute two real inverse FFTs
 * simultaneously. The outputs are in the two real arrays, the imaginary
 * arrays are unchanged.
 *
 * \param[in,out] re1    real part of first set of complex numbers on which
 *                       to compute inverse FFT
 *
 * \param[in,out] re2    real part of second set of complex numbers on which
 *                       to compute inverse FFT
 *
 * \param[in]     im1    imaginary part of first set of complex numbers on which
 *                       to compute inverse FFT
 *
 * \param[in]     im2    imaginary part of second set of complex numbers on which
 *                       to compute inverse FFT
 *
 * \param[in]     N      number of points
 *
 * \param[in] sine  array of N/4+1 sine values, each represented as a sign bit,
 *              and a 31 bit fraction. 1 should be represented as 0x7fffffff.
 *              Arrays are provided in sine.h; for example, for a 1024 point
 *              FFT use sin_1024.
 */
void fftTwoRealsInverse(int re1[], int re2[], int im1[], int im2[], int N, int sine[]);
