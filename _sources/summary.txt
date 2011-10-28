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

This module provides function that performs forward and/or inverse
FFTs on sets of either complex or real points. The number of cycles taken for the
forward or inverse FFT is roughly the same.

Complex FFT
+++++++++++

The table below shows the
number of thread cycles for the bit twiddling, and for performing either an
forward or an inverse FFT. The maximum rate shows the rate for performing a
twiddle, a forward FFT, a twiddle, and an inverse FFT on a single 50 MIPS
thread:

+----------+----------------------------+---------+----------+---------+-------------+
| Points   | Thread cycles              | Max rate| Error    | Memory  | Status      |
|          +-------------+--------------+         |          |         |             |
|          | Twiddle     | FFT          | FFT+Inv |          |         |             |
+----------+-------------+--------------+---------+----------+---------+-------------+
| 64       | 886         | 10810        | 2137 Hz | 3-4 bits | 1 KB    | Implemented |
+----------+-------------+--------------+---------+----------+---------+-------------+
| 1024     | 14626       | 256340       | 92  Hz  | 5-6 bits | 2 KB    | Implemented |
+----------+-------------+--------------+---------+----------+---------+-------------+
| N        | 14 N        | 25  N log N  |2/N log N| N/2 bits |1 KB + N | Implemented |
+----------+-------------+--------------+---------+----------+---------+-------------+

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

+----------+--------------+-----------+----------+---------+-------------+
| Points   | Thread cycles| Max rate  | Error    | Memory  | Status      |
+----------+--------------+-----------+----------+---------+-------------+
| 2 x 64   | 13332        | 1875 Hz   | 4 bits   | 1 KB    | Implemented |
+----------+--------------+-----------+----------+---------+-------------+
| 2 x 1024 | 294584       | 85  Hz    | 6 bits   | 2 KB    | Implemented |
+----------+--------------+-----------+----------+---------+-------------+
| 2 x N    | 29  N log N  |1.8/N log N|N/2+1 bits|1 KB + N | Implemented |
+----------+--------------+-----------+----------+---------+-------------+

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

module_dct_jpeg
===============

This module is a proof-of-concept 2D DCT for JPEG compression.

Performance (provided you can stream data in and out):

* three 50 MIPS threads compress approx 1.7 Msamples/s.
* QVGA greyscale: 22 fps in three 50 MIPS threads. 
* VGA greyscale: 5 fps in three 50 MIPS threads. 
* VGA greyscale: 14 fps in three 125 MIPS threads. With an extra DCT thread
  this may go up to 20 fps.
* Colour-images: approx two thirds of the speed?

The performance depends on the compression ratio. When compressing
marginally, Huffman encoding starts to take a serious amount of time. 
