// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "stdio.h"

unsigned char image[320*240/8];
int xSize, ySize;
static FILE *fd;

void readImage(void) {
    char *name = "example.pbm";
    int c;
    fd = fopen(name, "r");
    if (fd == NULL) {
        printf("File %s not found\n", name);
    }
    while((c = getc(fd)) != '\n');
    while((c = getc(fd)) != '\n');
    while((c = getc(fd)) != ' ') {
        xSize = xSize * 10 + c - '0';
    }
    while((c = getc(fd)) != '\n') {
        ySize = ySize * 10 + c - '0';
    }
    if (xSize*ySize > 320*240) {
        printf("Oops - expected fewer pixels not %d x %d pixels\n", xSize, ySize);
    }
    if (xSize % 32 != 0) {
        printf("Xsize must be a multiple of 32\n");
    }
    for(int i = 0; i < xSize*ySize/8; i++) {
        int bits = 0;
        for(int k = 0; k < 8; k++) {
            bits >>= 1;
            do {
                c = getc(fd);
                if (c == EOF) {
                    printf("Oops EOF?\n");
                    return;
                }
            } while (c != '0' && c != '1');
            if (c == '0') { // ! reverse of other netpbm formats.
                bits |= 0x80;
            }
        }
        image[i] = bits;
    }
    printf("Read %d pixels\n", xSize * ySize);
    fclose(fd);
    fd = fopen("output.jpg", "w");
}

void header2(int header) {
    fputc(header, fd);    
}
