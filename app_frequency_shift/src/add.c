#include "math.h"
#include "stdio.h"

void add(int answer[2], int r1, int i1, int r2, int i2) {
    double a1, a2;
    double l1, l2;

    if (r2 == 0 && i2 == 0) {
        answer[0] = r1;
        answer[1] = i1;
        return;
    }
    if (r1 == 0 && i1 == 0) {
        answer[0] = r2;
        answer[1] = i2;
        return;
    }

//    printf("points %d %d %d %d\n", r1, i1, r2, i2);
    a1 = atan2(r1, i1);
    a2 = atan2(r2, i2);
    l1 = hypot(r1, i1);
    l2 = hypot(r2, i2);
//    printf("%f %f %f %f\n", a1, a2, l1, l2);
    l1 += l2;
    a1 += a2;
    if (l1 > (double) 0x3fffffff) {
        printf("************************************* L1: %f\n", l1);
    }
    answer[0] = sin(a1) * l1;
    answer[1] = cos(a1) * l1;
//    printf("-> %d %d %f %f  \n", answer[0], answer[1], a1, l1);
//    a1 = atan2(answer[0], answer[1]);
//    printf(" =   %f\n", a1);
}
