sc_dsp_transforms
.................

:Stable release:  unreleased

:Status:  draft

:Maintainer:  https://github.com/henkmuller

:Description:  DCT and other transforms


Key Features
============

Functionality:

* Basic quantising DCT for JPEG encoder
* Basic Huffman encoder
* Access functions to compress a series of blocks.
* Example app to compress a PBM file into a JPEG file (PBM because that
  uses little memory to store).

Performance (provided you can stream data in and out):

* three 50 MIPS threads compress approx 1.7 Msamples/s.
* QVGA greyscale: 22 fps in three 50 MIPS threads. 
* VGA greyscale: 5 fps in three 50 MIPS threads. 
* VGA greyscale: 14 fps in three 125 MIPS threads. With an extra DCT thread
  this may go up to 20 fps.
* Colour-images: approx two thirds of the speed?

The performance depends on the compression ratio. When compressing
marginally, Huffman encoding starts to take a serious amount of time. 

To Do
=====

* Interface with a camera.

Firmware Overview
=================

The purpose of this repo is to collect a series of algorithms to perform
transforms on data, such as FFT, DCT, etc.

There are two modules in the repo:

* module_fdctint: forward quantising DCT.
  The process requires patches of 8x8 integer values, and in situ replace
  this with 8x8 transformed and quantised patches. 

* module_jhuffman: Huffman encode for JPEG images (this may have to go in a
  different repo).
  The process requires patches of 8x8 integer values, and streams bits out
  over a (streaming) channel.

Known Issues
============

* This repo contains, for testing purposes, code from the JPEG library.
  This is not covered by LICENSE.TXT but has its own original LICENSE in an
  accompanying README file.

Required Repositories
=====================

* xcommon git\@github.com:xcore/xcommon.git

Support
=======

None at present
