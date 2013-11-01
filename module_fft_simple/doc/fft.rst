Simple FFT Function Library
===========================

Overview
--------

DSP transformations perform functions such as FFTs or DFTs; they transform
between the time and frequency domains.

There are shelves of textbooks that cover filtering; a two-page summary is
necessarily incomplete. Typical characterisations of transformations include:

   * The number of points. This is the number of smaples on which to run the transform.
   * Whether it requires a forward or a backwards transform.
   * Type of filter (for example, this module only implements a one-dimensional FFT)

As a rule of thumb, computational requirements are O(n log n) in the number
of points. Double the number of points doubles the time that an FFT takes
plus a bit more. Typically, overflow leads to chaos. Numbers are typically rounded to the nearest value, with 0.5 being rounded up.

This FFT module implements a set of functions that can be used to compute the FFT of a set of complex data points, or the inverse.

Resource Usage and Performance
------------------------------

Complex FFT
+++++++++++

The table below shows the
number of thread cycles for the bit twiddling, and for performing either an
forward or an inverse FFT. The maximum rate shows the rate for performing a
twiddle, a forward FFT, a twiddle, and an inverse FFT on a single 50 MIPS
thread:

+----------+----------------------------+---------+----------+---------+
| Points   | Thread cycles              | Max rate| Error    | Memory  | 
|          +-------------+--------------+         |          |         |             
|          | Twiddle     | FFT          | FFT+Inv |          |         |        
+----------+-------------+--------------+---------+----------+---------+
| 64       | 886         | 10810        | 2137 Hz | 3-4 bits | 1 KB    | 
+----------+-------------+--------------+---------+----------+---------+
| 1024     | 14626       | 256340       | 92  Hz  | 5-6 bits | 2 KB    |
+----------+-------------+--------------+---------+----------+---------+
| N        | 14 N        | 25  N log N  |2/N log N| N/2 bits |1 KB + N | 
+----------+-------------+--------------+---------+----------+---------+

The memory required comprises roughly 1K of code, and then extra space for
a sin() lookup table. It excludes storage for the data points, which
amounts to eight bytes per point (four bytes real part, and four bytes
imaginary part).

Note that there is a trade-off between rounding and accuracy - the inverse
FFT can be made more accurate (by half to one extra bit) at a cost of 5% extra
instructions. This is marked in the code. The errors are indications only,
maximum errors will be higher and are value dependent.

Real FFT
++++++++

The table below shows the number of thread cycles for performing either an
forward or an inverse FFT. The maximum rate shows the rate for performing a
forward FFT, and an inverse FFT on a single 50 MIPS thread:

+----------+--------------+-----------+----------+---------+
| Points   | Thread cycles| Max rate  | Error    | Memory  | 
+----------+--------------+-----------+----------+---------+
| 2 x 64   | 13332        | 1875 Hz   | 4 bits   | 1 KB    |  
+----------+--------------+-----------+----------+---------+
| 2 x 1024 | 294584       | 85  Hz    | 6 bits   | 2 KB    |  
+----------+--------------+-----------+----------+---------+
| 2 x N    | 29  N log N  |1.8/N log N|N/2+1 bits|1 KB + N |  
+----------+--------------+-----------+----------+---------+

Note that the rate is slightly lower but that this computes *two real FFTs
simultaneously*, and is hence 1.8 times faster than its complex
counterpart.

The memory required comprises roughly 1K of code, and then extra space for
a sin() lookup table. It excludes storage for the data points, which
amounts to eight bytes per point (four bytes real part, and four bytes
imaginary part). (Even though the FFT is on real data, the answer is still
in the complex domain)

The real FFT uses the ocmplex FFT code, and the same tradeoff between
runtime and accuracy exists. The real code is half a bit less accurate
than its complex counterpart.

API
---

Sine arrays
+++++++++++

The include file "fft.h" defines a set of arrays that are to be used with
the FFT functions, called sine_8[], sine_16[], ..., sine_8192[]. Depending on the
number of points, pick the appropriate array and pass it to fftForward and
fftInverse as required.

FFT functions
+++++++++++++

.. doxygenfunction:: fftTwiddle

.. doxygenfunction:: fftForward

.. doxygenfunction:: fftInverse

.. doxygenfunction:: fftTwoRealsForward

.. doxygenfunction:: fftTwoRealsInverse


Programming Guide
-----------------

Below is an example calling sequence::

  #include "fft.h"

  int main(void) {
    int re[8], im[8];

    for(int i = 0; i < 8; i++) {
      // Fill re and im.
    }
    fftTwiddle(re, im, 8);
    fftForward(re, im, 8, sine_8);

    // Modify re and im, which are in the frequency domain

    fftTwiddle(re, im, 8);
    fftInverse(re, im, 8, sine_8);

    // and back to the time domain
  }
