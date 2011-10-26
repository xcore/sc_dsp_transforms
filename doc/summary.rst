DSP Transforms
==============

DSP transformations perform functions such as FFTs or DFTs; they transform
between the time and frequency domains.

There are shelves of textbooks that cover filtering; a two-page summary is
necessarily incomplete. Typical characterisations of transformations include:

* The number of points. This is the number of smaples on which to run the
  transform.

* Whether it requires a forward or a backwards transform.

* Type of filter. We at present only implemetn a one-dimensional FFT and a
  two-dimensional DCT.

As a rule of thumb, computational requirements are O(n log n) in the number
of points. Double the number of points doubles the time that an FFT takes
plus a bit more.

Typically, overflow leads to chaos. Numbers are typically
rounded to the nearest value, with 0.5 being rounded up.

module_fft_simple
-----------------

This module provides a function that performs a forward and/or inverse
complex FFT on an array of data points. The number of cycles taken for the
forward or inverse FFT is roughly the same. The table below shows the
number of thread cycles for the bit twiddling, and for performing either an
forward or an inverse FFT. The maximum rate shows the rate for performing a
twiddle, a forward FFT, a twiddle, and an inverse FFT on a single 50 MIPS
thread:

+----------+----------------------------+---------+----------+-------------+
| Points   | Thread cycles              | Max rate| Memory   | Status      |
|          +-------------+--------------+         |          |             |
|          | Twiddle     | FFT          | FFT+Inv |          |             |
+----------+-------------+--------------+---------+----------+-------------+
| 64       | 886         | 14011        | 1650 Hz | 1 KB     | Implemented |
+----------+-------------+--------------+---------+----------+-------------+
| 1024     | 14626       | 317515       | 75  Hz  | 2 KB     | Implemented |
+----------+-------------+--------------+---------+----------+-------------+
| N        | 3.5 N       | 7.7 N log N  | 50/...  | 1 KB + N | Implemented |
+----------+-------------+--------------+---------+----------+-------------+

The memory required comprises roughly 1K of code, and then extra space for
a sin() lookup table. It excludes storage for the data points, which
amounts to eight bytes per point (four bytes real part, and four bytes
imaginary part).

Note that there are a few more optimisations that could reduce the cycle
count a bit, and that not performing rounding can further decrease cycle
count.


module_dct
==========

Performance (provided you can stream data in and out):

* three 50 MIPS threads compress approx 1.7 Msamples/s.
* QVGA greyscale: 22 fps in three 50 MIPS threads. 
* VGA greyscale: 5 fps in three 50 MIPS threads. 
* VGA greyscale: 14 fps in three 125 MIPS threads. With an extra DCT thread
  this may go up to 20 fps.
* Colour-images: approx two thirds of the speed?

The performance depends on the compression ratio. When compressing
marginally, Huffman encoding starts to take a serious amount of time. 
