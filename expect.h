#pragma once

#include <stdio.h>
#include <stdlib.h>

#define EXPECT(x, msg)                                                         \
  do {                                                                         \
    if (!(x)) {                                                                \
      printf("Assertion failed: %s\n", msg);                                   \
      exit(1);                                                                 \
    }                                                                          \
  } while (0)
