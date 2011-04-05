sc_dsp_transforms
.................

:Stable release:  unreleased

:Status:  draft

:Maintainer:  https://github.com/henkmuller

:Description:  Transforms


Key Features
============

* Basic quantising DCT for JPEG encoder
* Basic Huffman encoder
* Basic Generation of JPEG frame

To Do
=====

* Create parallel DCT + huffman block.

Firmware Overview
=================

The purpose of this repo is to collect a series of algorithms to perform
transforsm on data, such as FFT, DCT, etc.

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
