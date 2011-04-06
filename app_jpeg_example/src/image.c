#include "stdio.h"

unsigned char image[320*60/8];
int xSize, ySize;
static FILE *fd;

void readImage(void) {
    char *name = "example2.pbm";
    fd = fopen(name, "r");
    if (fd == NULL) {
        printf("File %s not found\n", name);
    }
    fscanf(fd, "%*[^\n]\n");
    fscanf(fd, "%*[^\n]\n");
    fscanf(fd, "%d %d\n", &xSize, &ySize);
    if (xSize*ySize > 320*60) {
        printf("Oops - expected fewer pixels not %d x %d pixels\n", xSize, ySize);
    }
    if (xSize % 32 != 0) {
        printf("Xsize must be a multiple of 32\n");
    }
    for(int i = 0; i < xSize*ySize/8; i++) {
        int bits = 0;
        for(int k = 0; k < 8; k++) {
            int c;
            bits >>= 1;
            do {
                c = getc(fd);
                if (c == EOF) {
                    printf("Oops EOF?\n");
                    return;
                }
            } while (c != '0' && c != '1');
            if (c == '1') {
                bits |= 0x80;
            }
        }
        image[i] = bits;
    }
    printf("Read %d pixels\n", xSize * ySize);
    fclose(fd);
    fd = fopen("z.jpg", "w");
}

void header2(int header) {
    fputc(header, fd);    
}

void headerClose() {
    fclose(fd);
}
