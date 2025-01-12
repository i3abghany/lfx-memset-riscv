#include <stdio.h>
#include <stdlib.h>

#include "expect.h"

#define BUFF_SIZE 256

extern void memset_aligned(void *ptr, int value, unsigned int num);

void init_buffer(unsigned char *buffer, unsigned int size) {
  for (int i = 0; i < size; i++)
    buffer[i] = 'A';
}

void test_func(char *ptr, unsigned int start, unsigned int end, int value) {
  unsigned int size = end - start;
  char expected = value & 0xFF;
  static int test_no = 0;

  EXPECT(start <= end, "test error: start is greater than end");
  EXPECT(size <= BUFF_SIZE, "test error: size is greater than buffer size");

  init_buffer(ptr, BUFF_SIZE);
  memset_aligned(ptr + start, value, size);

  for (int i = 0; i < BUFF_SIZE; i++) {
    if (i < start || i >= end)
      EXPECT(ptr[i] == 'A', "memset wrote outside of memset range");
    else
      EXPECT(ptr[i] == expected,
             "memset did not write the expected value within range");
  }

  printf("%d - test passed: start=%d, end=%d\n", ++test_no, start, end);
}

int main() {
  unsigned char buffer[BUFF_SIZE];
  srand(0x1337);

  for (int i = 0; i < BUFF_SIZE; i++) {
    test_func(buffer, 0, i, rand());
    test_func(buffer, i, BUFF_SIZE, rand());
  }

  for (int i = 0; i < BUFF_SIZE / 2; i++) {
    test_func(buffer, i, BUFF_SIZE - i, rand());
  }
}