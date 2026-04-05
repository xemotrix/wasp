#pragma once

#include <stdio.h>
#include <stdlib.h>

#define UNIMPLEMENTED(...)                                                     \
  do {                                                                         \
    printf("[%s:%d] ", __FILE__, __LINE__);                                    \
    printf("UNIMPLEMENTED: ");                                                 \
    printf(__VA_ARGS__);                                                       \
    printf("\n");                                                              \
    exit(1);                                                                   \
  } while (0)

#define ERROR(...)                                                             \
  do {                                                                         \
    printf("[%s:%d] ", __FILE__, __LINE__);                                    \
    printf("ERROR: ");                                                         \
    printf(__VA_ARGS__);                                                       \
    printf("\n");                                                              \
    exit(1);                                                                   \
  } while (0)
