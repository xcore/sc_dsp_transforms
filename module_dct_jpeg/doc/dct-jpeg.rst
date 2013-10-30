Overview
--------

DSP transformations perform functions such as FFTs or DFTs; they transform
between the time and frequency domains.

There are shelves of textbooks that cover filtering; a two-page summary is
necessarily incomplete. Typical characterisations of transformations include:

* The number of points. This is the number of smaples on which to run the
  transform.

* Whether it requires a forward or a backwards transform.

* Type of filter. This module implements a two-dimensional DCT.

As a rule of thumb, computational requirements are O(n log n) in the number
of points. Double the number of points doubles the time that an FFT takes
plus a bit more.

Typically, overflow leads to chaos. Numbers are typically
rounded to the nearest value, with 0.5 being rounded up.

The DCT module comprises a heavily optimised DCT function that needs to run
in a thread of its own (since it uses all registers of the processor). The
DCT function operates in place on 8x8 blocks of 2D data. A block of data is
to be stored in memory, the address is to be passed to the function, and on
completion the pointer is returned. Between outputting the address, and
getting it back, the buffer is owned by the DCT-thread, and shall not be
used by any other thread. A common scheme would use a triple buffering
scheme, where one buffer is filled with new data, whilst a second buffer is
transformed by the DCT thread, whilst the third buffer is compressed using
the huffman module.


Resource usage and performance
------------------------------

This module is a proof-of-concept 2D DCT for JPEG compression.

Performance (provided you can stream data in and out):

   * three 50 MIPS threads compress approx 1.7 Msamples/s.
   * QVGA greyscale: 22 fps in three 50 MIPS threads. 
   * VGA greyscale: 5 fps in three 50 MIPS threads. 
   * VGA greyscale: 14 fps in three 125 MIPS threads. With an extra DCT thread
  this may go up to 20 fps.
   * Colour-images: approx two thirds of the speed?

The performance depends on the compression ratio. When compressing
marginally, Huffman encoding starts to take a large amount of time. 

API
===

.. doxygenfunction:: forwardDCT

.. doxygenfunction:: doDCT

.. doxygenfunction:: endDCT

.. doxygenfunction:: quantDCT

Example program
===============

provideBlocks(streaming chanend toDCT) {
    for(int i = 0; i < 256; i++) {
        doDCT(block1); // This needs to be split
                       // And needs a better example
    }
}

docompress(in quant[]) {
    int quant2[65];
    quantDCT(quant2, quant);

    par {
        forwardDCT(toDCT, quant2);
        provideBlocks(toDCT, toHuffman);
    }
}
