#include <stdint.h>

#define ANSWER (uint32_t*) 0x100

int merge_sort(uint32_t* numbers, uint32_t* work_array, uint32_t num);
int main(void);

uint32_t nums[] = {1};
uint32_t wk_array[1];

uint32_t copy(uint32_t* src, uint32_t* dst, uint32_t size) {
    for (uint32_t i = 0; i < size; i++) {
        dst[i] = src[i];
    }
    return 1;
}

// Biggest to smallest sort
void sort(uint32_t* numbers, uint32_t* work_array, uint32_t num) {
    merge_sort(&numbers[0], &work_array[0], num/2);
    merge_sort(&numbers[num/2], &work_array[num/2], num/2);
    uint32_t i = 0;
    uint32_t j = num/2;
    for (uint32_t k = 0; k < num; k++) {
        if ((i < num/2 && numbers[i] > numbers[j]) || j >= num) {
            work_array[k] = numbers[i++];
         }
         else {
             work_array[k] = numbers[j++];
         }
    }
    copy(work_array, numbers, num);
}

int merge_sort(uint32_t* numbers, uint32_t* work_array, uint32_t num) {
    if (num == 1) {
        return 1;
    }
    else {
        sort(numbers, work_array, num);
    }
    return 1;
}

__attribute__((naked, section (".text.main")))
int main() {
    asm volatile ("lui sp, 0x8");
    uint32_t* answer_arr = ANSWER;
    merge_sort(nums, wk_array, 1);
    for (int i = 0; i < 1; i++) {
        *(answer_arr+i) = nums[i];
    }
    while(1);
} 
