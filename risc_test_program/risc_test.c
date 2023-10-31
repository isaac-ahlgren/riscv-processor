int main(void)__attribute__ ((section (".text.start")));
int a = 126;
int b = 246;

void fib(int n1, int n2, int N, int* arr) {
    if (N == 0) {
        return;
    }
    *arr = n1;
    *(arr+1) = n2;
    *(arr+2) = n1 + n2;
    fib(n2, n1 + n2, N--, arr++);
    return;
}

int main() {
    int c = a + b;
    int nums[10];
    fib(0, 1, 10, nums);
    
    return c;
}
