#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "error.h"
#include "sym.h"

typedef struct {
  const char *name;
  int name_len;
  int sym_idx;
} SSSEntry;

typedef struct {
  SSSEntry *entries;
  int sizeb;
  int len;
  int cap;
  int sret_offset;
} SSSFrame;

typedef struct {
  SSSFrame *frames;
  int len;
  int cap;
} ScopedSymbolStack;

typedef struct {
  TypeStructDef *structs;
  int len;
  int cap;
} TypeTable;

int to_stack_size(int size) {
  // rounds up to multiples of 8
  return (size + 7) & ~7;
}

TypeTable TT;
SymT ST;
ScopedSymbolStack SSS;

int size_of_type(Type t) {
  switch (t.kind) {
  case TYPE_KIND_STRUCT:
    if (t.type.struct_name.sym_idx >= TT.len)
      ERROR("struct idx (%d) out of range (%d)\n", t.type.struct_name.sym_idx,
            TT.len);
    return TT.structs[t.type.struct_name.sym_idx].sizeb;
  case TYPE_KIND_PTR:
    return 8;
  case TYPE_KIND_BASE:
    switch (t.type.base) {
    case TYPE_CHAR:
      return 1;
    case TYPE_BOOL:
      return 1;
    case TYPE_INT:
      return 8;
    case TYPE_VOID:
      ERROR("void has no size\n");
    }
  default:
    UNIMPLEMENTED("type kind size");
  }
};

void sym_add_type(TypeStructDef ts) {
  if (TT.len >= TT.cap) {
    TT.cap *= 2;
    TT.structs = realloc(TT.structs, TT.cap * sizeof(TypeStructDef));
  }
  ts.sizeb = -1; // mark it as unknown for now
  TT.structs[TT.len++] = ts;
  return;
}

TypeStructDef sym_search_type_idx(int idx) { return TT.structs[idx]; }
int sym_search_type(const char *name, int name_len) {
  for (int i = 0; i < TT.len; i++) {
    TypeStructDef t = TT.structs[i];
    if (t.name_len == name_len && strncmp(name, t.name, name_len) == 0)
      return i;
  }
  ERROR("couldn't find type '%.*s'\n", name_len, name);
}

void sym_compute_type_sizes() {
  int n_finished = 0;
  int last_round_total_finished = 0;
  while (n_finished != TT.len) {
    for (int t_i = 0; t_i < TT.len; t_i++) {
      if (TT.structs[t_i].sizeb != -1)
        continue;
      int size_accum = 0;
      int fields_finished = 0;
      for (int f_i = 0; f_i < TT.structs[t_i].n_fields; f_i++) {
        Type t = TT.structs[t_i].types[f_i];
        TypeStructDef st;
        switch (t.kind) {
        case TYPE_KIND_PTR:
          size_accum += 8;
          fields_finished++;
          break;
        case TYPE_KIND_BASE:
          switch (t.type.base) {
          case TYPE_VOID:
            ERROR("can't compute the size of void");
          case TYPE_BOOL:
            size_accum += 1;
            break;
          case TYPE_INT:
            size_accum += 8;
            break;
          case TYPE_CHAR:
            size_accum += 1;
            break;
          }
          fields_finished++;
          break;
        case TYPE_KIND_STRUCT:
          st = sym_search_type_idx(sym_search_type(
              t.type.struct_name.name, t.type.struct_name.name_len));
          if (st.sizeb == -1)
            break;
          size_accum += st.sizeb;
          fields_finished++;
          break;
        }
      }

      if (fields_finished == TT.structs[t_i].n_fields) {
        int sizeb = (size_accum + 7) & ~7;
        printf("computed size of struct '%.*s': %d\n", TT.structs[t_i].name_len,
               TT.structs[t_i].name, size_accum);
        n_finished++;
        TT.structs[t_i].sizeb = sizeb;
      }
    }
    if (last_round_total_finished == n_finished)
      ERROR("couldn't resolve type sizes, maybe you have recursive "
            "definitions?\n");

    last_round_total_finished = n_finished;
  }
  printf("Success computing type sizes\n");
}

void sym_push_frame() {
  if (SSS.len >= SSS.cap) {
    SSS.cap *= 2;
    SSS.frames = realloc(SSS.frames, SSS.cap * sizeof(SSSFrame));
  }
  SSSFrame *new_frame = &SSS.frames[SSS.len++];
  new_frame->cap = 16;
  new_frame->len = 0;
  new_frame->sret_offset = -1;
  if (SSS.len == 1) {
    new_frame->sizeb = 0;
  } else {
    new_frame->sizeb = SSS.frames[SSS.len - 2].sizeb;
  }
  new_frame->entries = malloc(new_frame->cap * sizeof(SSSEntry));
}

void sym_pop_frame() {
  if (SSS.len == 0)
    ERROR("can't pop from empty ScopedSymbolStack\n");
  SSS.len--;
}

void sym_init_tables() {
  ST.cap = 32;
  ST.len = 0;
  ST.symbols = malloc(ST.cap * sizeof(Symbol));

  TT.cap = 32;
  TT.len = 0;
  TT.structs = malloc(TT.cap * sizeof(TypeStructDef));

  SSS.cap = 32;
  SSS.len = 0;
  SSS.frames = malloc(SSS.cap * sizeof(SSSFrame));
}

Symbol *new_sym() {
  if (ST.len >= ST.cap) {
    ST.cap *= 2;
    ST.symbols = realloc(ST.symbols, ST.cap * sizeof(Symbol));
  }
  return &ST.symbols[ST.len++];
}

SSSFrame *current_frame() { return &SSS.frames[SSS.len - 1]; }
SSSFrame *current_function_frame() {
  assert(SSS.len > 1);
  return &SSS.frames[1];
}

int sym_get_sret_idx() { return current_function_frame()->sret_offset; }
void sym_set_sret_idx(int sret) {
  current_function_frame()->sret_offset = sret;
}

SSSEntry *new_entry() {
  SSSFrame *f = current_frame();
  if (f->len >= f->cap) {
    f->cap *= 2;
    f->entries = realloc(f->entries, f->cap * sizeof(SSSEntry));
  }
  return &f->entries[f->len++];
}

void sym_fill_index_if_struct(Type *t) {
  switch (t->kind) {
  case TYPE_KIND_BASE:
    return;
  case TYPE_KIND_STRUCT:
    t->type.struct_name.sym_idx =
        sym_search_type(t->type.struct_name.name, t->type.struct_name.name_len);
    return;
  case TYPE_KIND_PTR:
    sym_fill_index_if_struct(t->type.ptr);
    return;
  }
  ERROR("unreachable unknown type kind %d", t->kind);
}

int sym_add_varconst(AST_Stmt_Declare def, SymKind kind) {
  int idx = ST.len;
  Symbol *sym = new_sym();
  sym_fill_index_if_struct(&def.t);
  sym->t = def.t;
  sym->kind = kind;
  sym->def = def;
  sym->sizeb = size_of_type(def.t);

  assert(SSS.len == 1);
  SSSEntry *e = new_entry();
  e->name = def.var_name;
  e->name_len = def.var_name_len;
  e->sym_idx = idx;

  return idx;
}

int sym_add_global_var(AST_Stmt_Declare def) {
  return sym_add_varconst(def, SYM_KIND_VAR);
}

int sym_add_global_const(AST_Stmt_Declare def) {
  return sym_add_varconst(def, SYM_KIND_CONST);
}

int sym_add_fun(AST_Def_Fun *fun) {
  int idx = ST.len;
  Symbol *sym = new_sym();
  sym->kind = SYM_KIND_FUN;
  sym->fun = fun;

  SSSEntry *e = new_entry();
  e->name = fun->name;
  e->name_len = fun->name_len;
  e->sym_idx = idx;
  return idx;
}

int sym_current_frame_size() { return current_frame()->sizeb; }

int sym_create_sym(Type t, SymKind kind) {
  int idx = ST.len;
  Symbol *sym = new_sym();
  sym_fill_index_if_struct(&t);
  sym->t = t;
  sym->kind = kind;
  sym->sizeb = size_of_type(t);

  assert(SSS.len > 1);
  SSSFrame *ff = current_function_frame();
  ff->sizeb += to_stack_size(sym->sizeb);
  sym->offset = ff->sizeb;
  return idx;
}

int sym_add_temporary(Type t) { return sym_create_sym(t, SYM_KIND_STACK); }

int sym_add_svar_arg(Type t, const char *name, int name_len) {
  int idx = ST.len;
  Symbol *sym = new_sym();
  sym_fill_index_if_struct(&t);
  sym->t = t;
  sym->kind = SYM_KIND_STACK_ARG;
  sym->sizeb = 8; // arguments are always allocated as 8 bytes

  assert(SSS.len > 1);
  SSSFrame *ff = current_function_frame();
  ff->sizeb += to_stack_size(sym->sizeb);
  sym->offset = ff->sizeb;

  SSSEntry *e = new_entry();
  e->name = name;
  e->name_len = name_len;
  e->sym_idx = idx;
  return idx;
}

int sym_add_svar(Type t, const char *name, int name_len) {
  int idx = sym_create_sym(t, SYM_KIND_STACK);
  SSSEntry *e = new_entry();
  e->name = name;
  e->name_len = name_len;
  e->sym_idx = idx;
  return idx;
}

const Symbol *sym_search(int idx) { return &ST.symbols[idx]; }
int sym_stack_search(const char *name, int name_len) {
  for (int i = SSS.len - 1; i >= 0; i--) {
    SSSFrame f = SSS.frames[i];
    for (int j = f.len - 1; j >= 0; j--) {
      if (name_len == f.entries[j].name_len &&
          strncmp(name, f.entries[j].name, name_len) == 0) {
        return f.entries[j].sym_idx;
      }
    }
  }
  ERROR("Couldn't find symbol '%.*s'\n", name_len, name);
}

const SymT *sym_all() { return &ST; }
