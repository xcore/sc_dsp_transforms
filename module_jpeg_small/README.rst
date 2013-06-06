module_jpeg_small
.................

:Stable release:  unreleased

:Status:  draft

:Maintainer:  https://github.com/andrewstanfordjason

:Description:  Compact JPEG decoding library


Key Features
============

Functionality:

* fits in 10KB
* memory footprint can be pushed down to around 6KB depending on restrictions on input images.
* handles 422 chroma subsampling.
* runs in a single thread.
* 3.6 fps at 480*272 (1.3 MB/s) at quailty 70.
* currently capped at 7 fps at 480*272 as quality decreases. 
* can be pipelined across threads.

The performance depends on the compression ratio. Performace can be optimised by preprocessing the images to be loaded, i.e. selecting quantization tables.


To Do
=====

* 421 chroma subsampling
* 411 chroma subsampling
* grey scale
* Speed improvements
* Abstract the data I/O to an API.
* Hand coded IDCT 

Known Issues
============

* This repo contains, for testing purposes, code from the MPEG library.
  This is not covered by LICENSE.TXT but has its own original LICENSE in an
  accompanying README file.

Required Repositories
=====================

* xcommon git\@github.com:xcore/xcommon.git

Support
=======

None at present