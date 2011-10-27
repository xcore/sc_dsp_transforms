// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>


int doHuff(streaming chanend blocks, int x[64]);

void endHuff(streaming chanend blocks);

void processHuff(streaming chanend blocks, streaming chanend codes);
