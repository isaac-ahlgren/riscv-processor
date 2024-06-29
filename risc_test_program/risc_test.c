int main(void)__attribute__ ((section (".text.start")));
int a = 126;
int b = 246;

void fib(int n1, int n2, int N, int* arr) {
    int val;
    if (N == 0) {
        return;
    }
    val = n1 + n2;
    *arr = val;
    fib(n2, val, --N, ++arr);
    return;
}

int main() {
    asm volatile ("lui sp,0x8; addi s0,sp,64;");
    int c = a + b;
    int nums[10];
    fib(0, 1, 2, nums);
    
    return c;
}
