sc_dsp_transforms
.................

:Stable release:  unreleased

:Status:  draft

:Maintainer:  https://github.com/henkmuller

:Description:  DCT, FFT, and other transforms


Key Features
============

DCT Functionality:

* Basic quantising DCT for JPEG compression
* Basic Huffman encoder for JPEG encoder
* Access functions to compress a series of blocks.
* Example app to compress a PBM file into a JPEG file (PBM because that
  uses little memory to store).

FFT Functionality:

* Forward complex FFT
* Inverse complex FFT
* Forward real FFT
* Inverse real FFT
* Example app that performs forwards and inverse FFT in sequence

To Do
=====

* Interface DCT with a camera.

Firmware Overview
=================

The purpose of this repo is to collect a series of algorithms to perform
transforms on data, such as FFT, DCT, etc.

There are three modules in the repo:

* module_dct_jpeg: forward quantising DCT.
  The process requires patches of 8x8 integer values, and in situ replace
  this with 8x8 transformed and quantised patches. 

* module_huffman_jpeg: Huffman encode for JPEG images (this may have to go in a
  different repo).
  The process requires patches of 8x8 integer values, and streams bits out
  over a (streaming) channel.

* module_fft_simple: complex FFT (size must be a power of 2), and real FFT
  (two arrays of identical length that must both be a power of 2).

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
