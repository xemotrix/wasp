#include "ast.h"
#include <stdio.h>
#include <stdlib.h>

Type ast_new_base_type(BaseType bt) {
  Type t;
  t.kind = TYPE_KIND_BASE;
  t.type.base = bt;
  return t;
}

Type ast_new_ptr_type(Type inner_t) {
  Type t;
  t.kind = TYPE_KIND_PTR;
  t.type.ptr = malloc(sizeof(Type));
  *t.type.ptr = inner_t;
  return t;
}

char *ast_fmt_type(Type t) {
  char *bfr = malloc(128);
  int c = 0;
  while (t.kind == TYPE_KIND_PTR) {
    bfr[c++] = '*';
    t = *t.type.ptr;
  }
  if (c > 16) {
    printf("more than 16 indirections?? WTF");
    exit(1);
  }
  if (t.kind == TYPE_KIND_STRUCT) {
    sprintf(bfr + c, "%.*s", t.type.struct_name.name_len,
            t.type.struct_name.name);
    return bfr;
  }
  switch (t.type.base) {
  case TYPE_VOID:
    sprintf(bfr + c, "void");
    break;
  case TYPE_BOOL:
    sprintf(bfr + c, "bool");
    break;
  case TYPE_INT:
    sprintf(bfr + c, "int");
    break;
  case TYPE_CHAR:
    sprintf(bfr + c, "char");
    break;
  default:
    printf("unknown base type %d", t.type.base);
    exit(1);
  }
  return bfr;
}
