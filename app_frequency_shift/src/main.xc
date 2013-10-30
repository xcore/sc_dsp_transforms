#include "hann.h"
#include "sine.h"
#include "fftreal.h"
#include "stdio.h"

#define N 256

#define M 64
#define SINE sine_64

int data[N+M];
int dataOut[N+M];

int mysin(int x) {
    x = x % 360;

    if (x <= 90) {
        return sine_4096[x * 1024/90];
    }
    if (x <= 180) {
        return sine_4096[(180-x) * 1024/90];
    }
    if (x <= 270) {
        return -sine_4096[(x-180) * 1024/90];
    }
    return -sine_4096[(360-x) * 1024/90];
}

extern void add(int answer[2], int r1, int i1, int r2, int i2);

int line[2*(N/M+1)][N+M];

int main(void) {
    for(int i = 0; i < N+M; i++) {
 //       data[i] += mysin(i*10) >> 3;
    }
    for(int i = 0; i < N+M; i++) {
        data[i] += mysin(i*70) >> 3;
    }
    for(int i = 0; i < N+M; i++) {
        data[i]  = 100000;
    }
    for (int i = 0; i < N; i+=M) {
        int re1[M], re2[M], im1[M], im2[M];
//        if (i == M) continue;
//        if (i == 3*M) break;
        windowHann(re1, data, i,     M, SINE);
        windowHann(re2, data, i+M/2, M, SINE);
        for(int j = 0; j < M; j++) {
            printf("%9d %9d %9d %9d\n", re1[j], re2[j], im1[j], im2[j]);
        }
        fftTwoRealsForward(re1, re2, im1, im2, M, SINE);
        for(int j = 0; j < M; j++) {
//            printf("%9d %9d %9d %9d\n", re1[j], re2[j], im1[j], im2[j]);
        }
        for(int j = 2; j < M/2; j++) {
            int x[2];
            add(x, re1[j/2], im1[j/2], re1[j], im1[j]);
            re1[j/2] = x[0];
            im1[j/2] = x[1];
            re1[j] = 0; im1[j] = 0;
            add(x, re2[j/2], im2[j/2], re2[j], im2[j]);
            re2[j/2] = x[0];
            im2[j/2] = x[1];
            re2[j] = 0; im2[j] = 0;
        }
        for(int j = 1; j < M/2; j++) {
            re1[M-j] = re1[j];
            re2[M-j] = re2[j];
            im1[M-j] = -im1[j];
            im2[M-j] = -im2[j];
        }
        for(int j = 0; j < M; j++) {
//            printf("%9d %9d %9d %9d\n", re1[j], re2[j], im1[j], im2[j]);
        }
        fftTwoRealsInverse(re1, re2, im1, im2, M, SINE);
        for(int j = 0; j < M; j++) {
            line[i/M*2][i+j] = re1[j];
            line[i/M*2+1][i+j+M/2] = re2[j];
           // printf("* * * %3d %9d %9d\n", i+j, re1[j], im1[j]);
           // printf("* * * %3d %9d %9d\n", i+j+M/2, re2[j], im2[j]);
            dataOut[i+j] += re1[j];
            dataOut[i+j+M/2] += re2[j];
        }
//        break;
    }

    for(int i = 0; i < N+M; i++) {
        printf("%3d %9d %9d ", i, data[i], dataOut[i]);
        for(int j = 0; j < 2*(N/M+1); j++) {
            printf(" %9d", line[j][i]);
        }
        printf("\n");
    }
    return 0;
}
