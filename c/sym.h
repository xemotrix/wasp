#pragma once

#include "ast.h"

typedef enum {
  SYM_KIND_STACK,
  SYM_KIND_STACK_ARG,
  SYM_KIND_CONST,
  SYM_KIND_VAR,
  SYM_KIND_FUN,
} SymKind;

typedef struct {
  Type t;
  int sizeb;
  SymKind kind;
  union {
    int offset;
    AST_Stmt_Declare def;
    AST_Def_Fun *fun;
  };
} Symbol;

typedef struct {
  Symbol *symbols;
  int len;
  int cap;
} SymT;

void sym_init_tables();
void sym_push_frame();
void sym_pop_frame();
void sym_compute_type_sizes();

int size_of_type(Type t);

const SymT *sym_all();
int sym_current_frame_size();
int sym_add_temporary(Type t);

void sym_fill_index_if_struct(Type *t);
int sym_add_global_var(AST_Stmt_Declare def);
int sym_add_global_const(AST_Stmt_Declare def);

int sym_get_sret_idx();
void sym_set_sret_idx(int sret);

void sym_add_type(TypeStructDef ts);
int sym_search_type(const char *name, int name_len);
TypeStructDef sym_search_type_idx(int idx);

int sym_add_fun(AST_Def_Fun *f);
int sym_add_svar(Type t, const char *name, int name_len);
int sym_add_svar_arg(Type t, const char *name, int name_len);
const Symbol *sym_search(int sym);
int sym_stack_search(const char *name, int name_len);
