module_jpeg_small
.................

:Stable release:  unreleased

:Status:  draft

:Maintainer:  https://github.com/andrewstanfordjason

:Description:  Compact JPEG decoding library


Key Features
============

Functionality:

* fits in 10Kb
* handles 4:2:2 chroma subsampling

To Do
=====

* 4:2:1 chroma subsampling
* 4:1:1 chroma subsampling
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