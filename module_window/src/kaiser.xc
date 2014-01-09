static inline int hmul(int a, int b) {
    return (a * (long long) b) >> 31;
}

void window_kaiser(int output[], int data[], int offset, int N, const int hann[]) {
    for(int i = 0; i < (N>>1); i++) {
        int s = hann[i];
        output[i] =     hmul(data[    i+offset], s);
        output[N-1-i] = hmul(data[N-1-i+offset], s);
    }
}
