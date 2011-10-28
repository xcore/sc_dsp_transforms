module_fft
''''''''''

The FFT module implements a set of functions that can be used to compute
the FFT of a set of complex data points, or the inverse.

API
===

Sine arrays
-----------

The include file "fft.h" defines a set of arrays that are to be used with
the FFT functions, called sine_8[], sine_16[], ..., sine_8192[]. Depending on the
number of points, pick the appropriate array and pass it to fftForward and
fftInverse as required.

FFT functions
-------------

.. doxygenfunction:: fftTwiddle

.. doxygenfunction:: fftForward

.. doxygenfunction:: fftInverse

.. doxygenfunction:: fftTwoRealsForward

.. doxygenfunction:: fftTwoRealsInverse


Example program
---------------

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
