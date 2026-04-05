#pragma once

#include <stdbool.h>
#include <stdint.h>

#include "token.h"

/**********************
  TYPES
***********************/
typedef enum {
  TYPE_VOID,
  TYPE_BOOL,
  TYPE_INT,
  TYPE_CHAR,
} BaseType;

typedef enum {
  TYPE_KIND_BASE,
  TYPE_KIND_PTR,
  TYPE_KIND_STRUCT,
} TypeKind;

typedef struct Type Type;

typedef struct {
  char *name;
  int name_len;
  char **field_names;
  int *field_name_lens;
  Type *types;
  int n_fields;
  int sizeb;
} TypeStructDef;

typedef struct {
  char *name;
  char name_len;
  int sym_idx; // filled at semantic analysis
} TypeStructName;

typedef struct Type {
  TypeKind kind;
  union {
    BaseType base;
    Type *ptr;
    TypeStructName struct_name;
  } type;
} Type;

Type ast_new_base_type(BaseType bt);
Type ast_new_ptr_type(Type inner_t);
char *ast_fmt_type(Type t);

/**********************
  EXPRESSIONS
***********************/
typedef struct AST_Expr AST_Expr;

typedef enum {
  AST_EXPR_LIT_BOOL,
  AST_EXPR_LIT_CHAR,
  AST_EXPR_LIT_INT,
  AST_EXPR_LIT_STRING,
  AST_EXPR_VAR,
  AST_EXPR_BINOP,
  AST_EXPR_UNOP,
  AST_EXPR_CALL,
} AST_Expr_Kind;

typedef struct {
  char *name;
  int name_len;
  int sym_idx;
} AST_Expr_Var;

typedef struct {
  unsigned long value;
} AST_Expr_Lit_Int;

typedef struct {
  int value;
} AST_Expr_Lit_Bool;

typedef struct {
  char *text;
} AST_Expr_Lit_String;

typedef struct {
  char value;
} AST_Expr_Lit_Char;

typedef struct {
  TokenType op;
  AST_Expr *left;
  AST_Expr *right;
  int offsetb; // used to compute total offset on struct access (.)
} AST_Expr_Binop;

typedef struct {
  TokenType op;
  AST_Expr *expr;
} AST_Expr_Unop;

typedef struct {
  AST_Expr *fun_expr;
  AST_Expr *args;
  int args_len;
  bool is_syscall;
  int *temporary_sym_idxs;
  int temporary_sret_sym_idx;
} AST_Expr_Call;

typedef struct AST_Expr {
  AST_Expr_Kind kind;
  union {
    AST_Expr_Var var;
    AST_Expr_Lit_Int lit_int;
    AST_Expr_Lit_Bool lit_bool;
    AST_Expr_Lit_String lit_string;
    AST_Expr_Lit_Char lit_char;
    AST_Expr_Binop binop;
    AST_Expr_Unop unop;
    AST_Expr_Call call;
  } expr;
  Type ty;
} AST_Expr;

/**********************
  STMTs
***********************/

typedef enum {
  AST_STMT_DEFINE,
  AST_STMT_ASSIGN,
  AST_STMT_IF,
  AST_STMT_WHILE,
  AST_STMT_RETURN,
  AST_STMT_RAW_EXPR,
  AST_STMT_BREAK,
  AST_STMT_CONTINUE,
} AST_Stmt_Kind;

typedef struct AST_Stmt AST_Stmt;

typedef struct {
  AST_Stmt *stmts;
  int stmts_len;
  int stmt_cap;
} Block;

typedef struct {
  AST_Expr lvalue;
  AST_Expr rvalue;
  int sym_idx;
  Type t;
} AST_Stmt_Assign;

typedef struct {
  char *var_name;
  int var_name_len;
  Type t;
  AST_Expr *expr;
  int sym_idx;
} AST_Stmt_Declare;

typedef struct {
  AST_Expr *cond;
  Block *block;
} AST_Stmt_If;

typedef struct {
  AST_Expr *cond;
  Block *block;
} AST_Stmt_While;

typedef struct {
  AST_Expr *expr;
  int sret_idx;
} AST_Stmt_Return;

typedef struct AST_Stmt {
  AST_Stmt_Kind kind;
  union {
    AST_Stmt_Assign assign;
    AST_Stmt_Declare define;
    AST_Stmt_If iff;
    AST_Stmt_While whilee;
    AST_Stmt_Return returnn;
    AST_Expr raw_expr;
  } stmt;
} AST_Stmt;

/**********************
  DEFINITIONS
***********************/

typedef enum {
  AST_DEF_FUN,
  AST_DEF_CONST,
  AST_DEF_VAR,
  AST_DEF_TYPE,
} AST_Def_Kind;

typedef struct {
  char *name;
  int name_len;
  int num_args;
  char **arg_names;
  int *arg_name_lens;
  Type *arg_types;
  Type return_type;
  Block block;
  int *arg_sym_idxs;
  int locals_stack_size;
  int sret_sym_idx;
} AST_Def_Fun;

typedef struct {
  AST_Def_Kind kind;
  union {
    AST_Def_Fun fun;
    AST_Stmt_Declare global;
    TypeStructDef stru;
  } def;
} AST_Def;

/**********************
  AST
***********************/

typedef struct {
  AST_Def *defs;
  int defs_len;
} AST;
