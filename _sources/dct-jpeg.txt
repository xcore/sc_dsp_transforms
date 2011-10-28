module_dct_jpeg
'''''''''''''''

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
