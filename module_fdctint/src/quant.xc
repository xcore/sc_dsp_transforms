#include "fdctint.h"

void quantDCT(int preprocessedQuant[65], const unsigned char quantisationTable[64]) {
    for(int i = 0; i < 64; i++) {
        preprocessedQuant[i] = (4*(0x08000000/quantisationTable[i]));
    }
    preprocessedQuant[64] = 0;
}
