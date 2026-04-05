#include <stdio.h>
#include <stdlib.h>

#include "ast.h"
#include "codegen.h"
#include "parser.h"
#include "sem.h"

char *read_file(const char *filename);

int main(int argc, char *argv[]) {

  if (argc != 2) {
    printf("ERROR: must provide source file.\n");
    return 1;
  }
  const char *filename = argv[1];

  printf("the filename is: %s\n", filename);
  char *contents = read_file(filename);
  if (!contents) {
    printf("ERROR: failed to read file");
    return 1;
  }

  AST ast = parse(&contents);
  printf("Success parsing\n");
  type_check(&ast);
  printf("Success typechecking\n");
  gen_asm(ast);
  printf("Success codegen\n");

  return 0;
}

char *read_file(const char *filename) {
  FILE *f = fopen(filename, "r");
  if (!f)
    return NULL;

  fseek(f, 0, SEEK_END);
  long size = ftell(f);
  rewind(f);
  char *buffer = malloc(size + 1);
  if (!buffer) {
    fclose(f);
    return NULL;
  }
  fread(buffer, 1, size, f);
  buffer[size] = '\0';
  fclose(f);
  return buffer;
}
