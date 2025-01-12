#pragma once

#include <stdio.h>
#include <stdlib.h>

#define EXPECT(x, msg)                                                         \
  do {                                                                         \
    if (!(x)) {                                                                \
      fprintf(stderr, "expect failed: %s: %s\n", #x, msg);                     \
      exit(1);                                                                 \
    }                                                                          \
  } while (0)
