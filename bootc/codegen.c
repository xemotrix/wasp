#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "ast.h"
#include "error.h"
#include "sym.h"

int cg_lvalue(AST_Expr expr);
void cg_access(AST_Expr_Binop access, Type t);

typedef struct {
  const char *text;
  int label;
} CG_StrEntry;

typedef struct {
  CG_StrEntry *strings;
  int len;
  int cap;
} CG_StrMap;

typedef enum {
  SIZE_BYTE,
  SIZE_WORD,
  SIZE_DWORD,
  SIZE_QWORD,
} WORD_Size;

FILE *CG_F;
int CG_LBL_CTR = 0;
CG_StrMap CG_STRS;
const char *ARG_REGS[6] = {"rdi", "rsi", "rdx", "rcx", "r8", "r9"};
const char *SYSCALL_REGS[6] = {"rdi", "rsi", "rdx", "r10", "r8", "r9"};
const char *OP_REGS[][3] = {
    [SIZE_BYTE] = {"al", "bl", "cl"},
    [SIZE_WORD] = {"ax", "bx", "cx"},
    [SIZE_DWORD] = {"eax", "ebx", "ecx"},
    [SIZE_QWORD] = {"rax", "rbx", "rcx"},
};

WORD_Size cg_op_word_size(Type t) {
  if (t.kind == TYPE_KIND_PTR)
    return SIZE_QWORD;

  switch (t.type.base) {
  case TYPE_CHAR:
    return SIZE_BYTE;
  case TYPE_BOOL:
    return SIZE_BYTE;
  case TYPE_INT:
    return SIZE_QWORD;
  case TYPE_VOID:
  default:
    UNIMPLEMENTED("void or unknown register");
  }
}

const char *cg_op_word_size_str(Type t) {
  WORD_Size size = cg_op_word_size(t);
  switch (size) {
  case SIZE_BYTE:
    return "BYTE";
  case SIZE_WORD:
    return "WORD";
  case SIZE_DWORD:
    return "DWORD";
  case SIZE_QWORD:
    return "QWORD";
  default:
    UNIMPLEMENTED("word size");
  }
}
const char *cg_op_register(Type t, int idx) {
  if (idx > 1)
    ERROR("register idx not supported\n");

  return OP_REGS[cg_op_word_size(t)][idx];
}

void cg_block(Block b, char break_lbl[16], char continue_lbl[16]);
int cg_lbl() { return ++CG_LBL_CTR; }

int save_const_string(AST_Expr_Lit_String s) {
  int lbl = cg_lbl();
  if (CG_STRS.len == CG_STRS.cap) {
    CG_STRS.cap *= 2;
    CG_STRS.strings =
        realloc(CG_STRS.strings, CG_STRS.cap * sizeof(CG_StrEntry));
  }
  CG_StrEntry e;
  e.text = s.text;
  e.label = lbl;
  CG_STRS.strings[CG_STRS.len++] = e;
  return lbl;
}

void cg_init_maps() {
  CG_STRS.len = 0;
  CG_STRS.cap = 4;
  CG_STRS.strings = malloc(CG_STRS.cap * sizeof(CG_StrEntry));
}

void cg_expr(AST_Expr expr);

void cg_head() {
  fprintf(CG_F, "global _start\n"
                "section .text\n");
}

void cg_entry() {
  fprintf(CG_F, "\n_start:\n"
                "\tmov rdi, [rsp]\n"
                "\tlea rsi, [rsp+8]\n"
                "\tcall main\n"
                "\tmov rdi, rax\n"
                "\tmov rax, 60\n"
                "\tsyscall");
}

void cg_unop(AST_Expr_Unop unop, Type t) {
  const Symbol *s;
  switch (unop.op) {
  case TOK_TILDE:
    cg_expr(*unop.expr);
    fprintf(CG_F, "\tpop rax\n"
                  "\tnot rax\n"
                  "\tpush rax\n");
    break;
  case TOK_BANG:
    cg_expr(*unop.expr);
    fprintf(CG_F, "\tpop rax\n"
                  "\txor rbx, rbx\n"
                  "\tcmp rax, 0\n"
                  "\tsete bl\n"
                  "\tpush rbx\n");
    break;
  case TOK_AMPERSAND:
    switch (unop.expr->kind) {
    case AST_EXPR_BINOP:
      // codegen the content as an lvalue to get the address on the stack
      cg_lvalue(*unop.expr);
      break;
    case AST_EXPR_VAR:
      s = sym_search(unop.expr->expr.var.sym_idx);
      if (s->kind == SYM_KIND_STACK_ARG && s->t.kind == TYPE_KIND_STRUCT) {
        fprintf(CG_F,
                "\tlea rax, [rbp-%d]\n"
                "\tpush QWORD [rax]\n",
                s->offset);
      } else {
        fprintf(CG_F,
                "\tlea rax, [rbp-%d]\n"
                "\tpush rax\n",
                s->offset);
      }
      break;
    default:
      ERROR("unsupported reference to expression of kind %d", unop.expr->kind);
    }
    break;
  case TOK_ASTERISK:
    cg_expr(*unop.expr);
    switch (unop.expr->ty.type.ptr->kind) {
    case TYPE_KIND_STRUCT:
      // do nothing as we want the address on the stack
      break;
    default:
      fprintf(CG_F, "\tpop rax\n");
      fprintf(CG_F, "\tpush QWORD [rax]\n");
      break;
    }
    break;
  case TOK_MINUS:
    cg_expr(*unop.expr);
    fprintf(CG_F, "\tpop rax\n"
                  "\tneg rax\n"
                  "\tpush rax\n");
    break;
  case TOK_PLUS:
    break;
  default:
    UNIMPLEMENTED("unop");
  }
}

void cg_subscript_reference(AST_Expr_Binop binop, Type t) {
  assert(binop.op == TOK_LSQBR);
  cg_expr(*binop.left);
  cg_expr(*binop.right);
  fprintf(CG_F, "\tpop rax\n"   // idx (int)
                "\tpop rbx\n"); // ptr
  int size = size_of_type(t);
  fprintf(CG_F,
          "\timul rax, %d\n"
          "\tadd rbx, rax\n"
          "\tpush rbx\n",
          size);
}

void cg_subscript(AST_Expr_Binop binop, Type t) {
  cg_subscript_reference(binop, t);

  if (t.kind != TYPE_KIND_STRUCT) {
    fprintf(CG_F, "\tpop rax\n"
                  "\tpush QWORD [rax]\n");
  }
}

void cg_binop(AST_Expr_Binop binop, Type t) {
  if (binop.op == TOK_PERIOD)
    return cg_access(binop, t);
  if (binop.op == TOK_LSQBR)
    return cg_subscript(binop, t);

  cg_expr(*binop.left);
  cg_expr(*binop.right);

  fprintf(CG_F, "\tpop rbx\n"
                "\tpop rax\n");

  const char *reg_a = cg_op_register(binop.left->ty, 0);
  const char *reg_b = cg_op_register(binop.right->ty, 1);
  const char *instruction;

  const int OPTYPE_ARITH = 1;
  const int OPTYPE_BOOL = 2;
  int op_type = 0;

  switch (binop.op) {
  case TOK_EQUALSEQUALS:
    instruction = "sete";
    op_type = OPTYPE_BOOL;
    break;
  case TOK_BANGEQUALS:
    instruction = "setne";
    op_type = OPTYPE_BOOL;
    break;
  case TOK_GT:
    instruction = "setg";
    op_type = OPTYPE_BOOL;
    break;
  case TOK_GTE:
    instruction = "setge";
    op_type = OPTYPE_BOOL;
    break;
  case TOK_LT:
    instruction = "setl";
    op_type = OPTYPE_BOOL;
    break;
  case TOK_LTE:
    instruction = "setle";
    op_type = OPTYPE_BOOL;
    break;
  case TOK_SHIFT_LEFT:
    fprintf(CG_F, "\tmov rcx, rbx\n");
    reg_b = "cl";
    instruction = "shl";
    op_type = OPTYPE_ARITH;
    break;
  case TOK_SHIFT_RIGHT:
    fprintf(CG_F, "\tmov rcx, rbx\n");
    reg_b = "cl";
    instruction = "shr";
    op_type = OPTYPE_ARITH;
    break;
  case TOK_AMPERSAND:
  case TOK_AND:
    instruction = "and";
    op_type = OPTYPE_ARITH;
    break;
  case TOK_BIT_OR:
  case TOK_OR:
    instruction = "or";
    op_type = OPTYPE_ARITH;
    break;
  case TOK_PLUS:
    instruction = "add";
    op_type = OPTYPE_ARITH;
    break;
  case TOK_MINUS:
    instruction = "sub";
    op_type = OPTYPE_ARITH;
    break;
  case TOK_ASTERISK:
    instruction = "imul";
    op_type = OPTYPE_ARITH;
    break;
  case TOK_SLASH:
    fprintf(CG_F, "\tcqo\n" // sign extend rax to RDX:RAX
                  "\tidiv rbx\n"
                  "\tpush rax\n");
    return;
  case TOK_PERCENT:
    fprintf(CG_F, "\tcqo\n" // sign extend rax to RDX:RAX
                  "\tidiv rbx\n"
                  "\tpush rdx\n");
    return;
  default:
    ERROR("invalid binop op %d\n", binop.op);
  }
  if (op_type == OPTYPE_ARITH) {
    fprintf(CG_F,
            "\t%s %s, %s\n"
            "\tpush rax\n",
            instruction, reg_a, reg_b);
  } else if (op_type == OPTYPE_BOOL) {
    fprintf(CG_F,
            "\txor rcx, rcx\n"
            "\tcmp %s, %s\n"
            "\t%s cl\n"
            "\tpush rcx\n",
            reg_a, reg_b, instruction);
  }
}

void cg_syscall(AST_Expr_Call call) {
  for (int i = 1; i < call.args_len; i++) {
    cg_expr(call.args[i]);
    fprintf(CG_F, "\tpop %s\n", SYSCALL_REGS[i - 1]);
  }

  cg_expr(call.args[0]);
  fprintf(CG_F, "\tpop rax\n"
                "\tsyscall\n"
                "\tpush rax\n");
}

void cg_call(AST_Expr_Call call) {
  if (call.is_syscall)
    return cg_syscall(call);

  assert(call.fun_expr->kind == AST_EXPR_VAR);
  const Symbol *fun_sym = sym_search(call.fun_expr->expr.var.sym_idx);
  assert(fun_sym->kind == SYM_KIND_FUN);

  for (int i = 0; i < call.args_len; i++) {
    AST_Expr arg = call.args[i];
    cg_expr(arg);
    if (arg.ty.kind == TYPE_KIND_STRUCT) {
      const Symbol *s = sym_search(call.temporary_sym_idxs[i]);
      fprintf(CG_F,
              "\tpop rax\n"            // ptr to start of original struct
              "\tlea rbx, [rbp-%d]\n", // allocated temporary
              s->offset);

      fprintf(CG_F,
              "\tmov rsi, rax\n" // src
              "\tmov rdi, rbx\n" // dst
              "\tmov rcx, %d\n"  // n bytes
              "\trep movsb\n",   // copy
              s->sizeb);
      fprintf(CG_F, "\tpush QWORD rbx\n"); // push the address of the temporary
    }
  }

  int sret_reg_off = 0;
  if (fun_sym->fun->return_type.kind == TYPE_KIND_STRUCT) {
    sret_reg_off++;
    const Symbol *sret_sym = sym_search(call.temporary_sret_sym_idx);
    fprintf(CG_F, "\tlea %s, [rbp-%d]\n", ARG_REGS[0], sret_sym->offset);
  }

  for (int i = call.args_len - 1; i >= 0; i--)
    fprintf(CG_F, "\tpop %s\n", ARG_REGS[i + sret_reg_off]);

  char *fun_name = call.fun_expr->expr.var.name;
  int fun_name_len = call.fun_expr->expr.var.name_len;

  fprintf(CG_F, "\tcall %.*s\n", fun_name_len, fun_name);
  Type ret = fun_sym->fun->return_type;

  if (ret.kind != TYPE_KIND_BASE || ret.type.base != TYPE_VOID)
    fprintf(CG_F, "\tpush rax\n");
}

int cg_get_access_offset(AST_Expr_Binop access) {
  assert(access.op == TOK_PERIOD);
  const Symbol *s;
  switch (access.left->kind) {
  case AST_EXPR_VAR:
    s = sym_search(access.left->expr.var.sym_idx);
    if (s->kind == SYM_KIND_STACK_ARG)
      return access.offsetb;
    return s->offset - access.offsetb;
  case AST_EXPR_BINOP:
    if (access.left->expr.binop.op == TOK_PERIOD)
      return cg_get_access_offset(access.left->expr.binop) - access.offsetb;
    if (access.left->expr.binop.op == TOK_LSQBR)
      return access.offsetb;
    ERROR("unsupported left hand operand");
  default:
    return access.offsetb;
  }
}

/*
 * Leaves a reference to the target in the stack
 * Structs are referenced by their lowest address
 */
void cg_access_reference(AST_Expr_Binop access, Type t) {
  assert(access.op == TOK_PERIOD);
  if (access.left->ty.kind == TYPE_KIND_PTR) {
    cg_expr(*access.left);
  } else {
    cg_lvalue(*access.left);
  }
  fprintf(CG_F,
          "\tpop rax\n"
          "\tadd rax, %d\n"
          "\tpush rax\n",
          access.offsetb);
}

void cg_access(AST_Expr_Binop access, Type t) {
  cg_access_reference(access, t);
  if (t.kind != TYPE_KIND_STRUCT) {
    // if it's a <=word size field, push the contents
    // not the address
    fprintf(CG_F, "\tpop rax\n"
                  "\tpush QWORD [rax]\n");
  }
}

void cg_expr(AST_Expr expr) {
  const Symbol *s;
  int lbl;
  switch (expr.kind) {
  case AST_EXPR_VAR:
    s = sym_search(expr.expr.var.sym_idx);
    if (s->kind == SYM_KIND_STACK) {
      if (s->t.kind != TYPE_KIND_STRUCT)
        fprintf(CG_F, "\tpush QWORD [rbp-%d]\n", s->offset);
      else
        // if it is a struct we leave a pointer to it's start
        // on the stack
        fprintf(CG_F,
                "\tlea rax, [rbp-%d]\n"
                "\tpush rax\n",
                s->offset);
      break;
    }

    if (s->kind == SYM_KIND_STACK_ARG) {
      if (s->t.kind != TYPE_KIND_STRUCT)
        fprintf(CG_F, "\tpush QWORD [rbp-%d]\n", s->offset);
      else
        fprintf(CG_F,
                "\tlea rax, [rbp-%d]\n"
                "\tpush QWORD [rax]\n",
                s->offset);
      break;
    }
    assert(s->kind == SYM_KIND_VAR || s->kind == SYM_KIND_CONST);
    fprintf(CG_F, "\tpush QWORD [GLBL_%.*s]\n", expr.expr.var.name_len,
            expr.expr.var.name);
    break;
  case AST_EXPR_BINOP:
    cg_binop(expr.expr.binop, expr.ty);
    break;
  case AST_EXPR_UNOP:
    cg_unop(expr.expr.unop, expr.ty);
    break;
  case AST_EXPR_CALL:
    cg_call(expr.expr.call);
    break;
  case AST_EXPR_LIT_INT:
    if (expr.expr.lit_int.value >= 0x80000000) {
      fprintf(CG_F,
              "\tmov rax, %lu\n"
              "\tpush rax\n",
              expr.expr.lit_int.value);
    } else {
      fprintf(CG_F, "\tpush %lu\n", expr.expr.lit_int.value);
    }
    break;
  case AST_EXPR_LIT_BOOL:
    fprintf(CG_F, "\tpush %d\n", expr.expr.lit_bool.value);
    break;
  case AST_EXPR_LIT_CHAR:
    fprintf(CG_F, "\tpush %d\n", expr.expr.lit_char.value);
    break;
  case AST_EXPR_LIT_STRING:
    lbl = save_const_string(expr.expr.lit_string);
    char bfr[16];
    sprintf(bfr, "STR_%d", lbl);
    fprintf(CG_F, "\tpush %s\n", bfr);
    break;
  default:
    UNIMPLEMENTED("expr");
  }
}

void cg_label(char *str_lbl) {
  fprintf(CG_F, "%s:\n", str_lbl);
  return;
}

int cg_lvalue(AST_Expr expr) {
  const Symbol *s;
  switch (expr.kind) {
  case AST_EXPR_VAR:
    s = sym_search(expr.expr.var.sym_idx);
    switch (s->kind) {
    case SYM_KIND_STACK_ARG:
      if (s->t.kind == TYPE_KIND_STRUCT) {
        fprintf(CG_F,
                "\tlea rax, [rbp-%d]\n"
                "\tpush QWORD [rax]\n",
                s->offset);
        // here we can't use s->sizeb because
        // that size is the size of the ptr
        // and we want to return the actual size
        // to copy it later
        return size_of_type(s->t);
      }
      // else fall throught to SYM_KIND_STACK
    case SYM_KIND_STACK:
      fprintf(CG_F,
              "\tlea rax, [rbp-%d]\n"
              "\tpush rax\n",
              s->offset);
      return s->sizeb;
    case SYM_KIND_VAR:
      fprintf(CG_F, "\tpush QWORD GLBL_%.*s\n", s->def.var_name_len,
              s->def.var_name);
      return s->sizeb;
    case SYM_KIND_CONST:
      ERROR("trying to write to CONST");
    case SYM_KIND_FUN:
      ERROR("trying to write to FUN");
    }
  case AST_EXPR_BINOP:
    if (expr.expr.binop.op == TOK_PERIOD) {
      cg_access_reference(expr.expr.binop, expr.ty);
      return size_of_type(expr.ty);
    }
    if (expr.expr.binop.op == TOK_LSQBR) {
      cg_subscript_reference(expr.expr.binop, expr.ty);
      return size_of_type(expr.ty);
    }
    ERROR("trying to codegen for non asignable expression");
  case AST_EXPR_UNOP:
    // only derreferences allowed. So we just CG the inner
    // expression without derreferences.
    cg_expr(*expr.expr.unop.expr);
    return size_of_type(expr.ty);
  default:
    ERROR("trying to codegen for non asignable expression");
  }
}

void cg_stmt(AST_Stmt stmt, char break_lbl[16], char continue_lbl[16]) {
  const Symbol *s;
  AST_Stmt_Declare def;
  char str_lbl[16];
  char str_lbl2[16];
  switch (stmt.kind) {
  case AST_STMT_DEFINE:
    def = stmt.stmt.define;
    s = sym_search(def.sym_idx);
    fprintf(CG_F, "\t; define %.*s\n", def.var_name_len, def.var_name);

    if (!def.expr)
      break;

    cg_expr(*def.expr);
    if (def.expr->ty.kind == TYPE_KIND_STRUCT) {
      fprintf(CG_F,
              "\tpop rbx\n"            // address to the start of the source.
              "\tlea rax, [rbp-%d]\n", // destination
              s->offset);

      fprintf(CG_F,
              "\tmov rsi, rbx\n" // src
              "\tmov rdi, rax\n" // dst
              "\tmov rcx, %d\n"  // n bytes
              "\trep movsb\n",   // copy
              s->sizeb);
    } else {
      fprintf(CG_F,
              "\tpop rax\n"
              "\tmov QWORD [rbp-%d], rax\n",
              s->offset);
    }
    break;
  case AST_STMT_ASSIGN:
    printf("");
    int lsize = cg_lvalue(stmt.stmt.assign.lvalue);
    cg_expr(stmt.stmt.assign.rvalue);
    fprintf(CG_F, "\tpop rax\n"   // src
                  "\tpop rbx\n"); // dest
    switch (stmt.stmt.assign.t.kind) {
    case TYPE_KIND_PTR:
      fprintf(CG_F, "\tmov [rbx], rax\n");
      break;
    case TYPE_KIND_BASE:
      if (lsize == 8) {
        fprintf(CG_F, "\tmov [rbx], rax\n");
        break;
      }
      if (lsize == 1) {
        fprintf(CG_F, "\tmov BYTE [rbx], al\n");
        break;
      }
      UNIMPLEMENTED("other small base types");
    case TYPE_KIND_STRUCT:
      fprintf(CG_F,
              "\tmov rsi, rax\n" // src
              "\tmov rdi, rbx\n" // dst
              "\tmov rcx, %d\n"  // n bytes
              "\trep movsb\n",   // copy
              lsize);
      break;
    }
    break;
  case AST_STMT_IF:
    cg_expr(*stmt.stmt.iff.cond);
    sprintf(str_lbl, "IF_%d", cg_lbl());
    fprintf(CG_F,
            "\tpop ax\n"
            "\tcmp al, 0\n"
            "\tje %s\n",
            str_lbl);
    cg_block(*stmt.stmt.iff.block, break_lbl, continue_lbl);
    cg_label(str_lbl);

    break;
  case AST_STMT_WHILE:
    sprintf(str_lbl, "WHC_%d", cg_lbl());
    sprintf(str_lbl2, "WHE_%d", cg_lbl());

    cg_label(str_lbl);
    cg_expr(*stmt.stmt.whilee.cond);
    fprintf(CG_F,
            "\tpop rax\n"
            "\tcmp rax, 0\n"
            "\tje %s\n",
            str_lbl2);
    cg_block(*stmt.stmt.whilee.block, str_lbl2, str_lbl);
    fprintf(CG_F, "\tjmp %s\n", str_lbl);
    cg_label(str_lbl2);
    break;
  case AST_STMT_RAW_EXPR:
    cg_expr(stmt.stmt.raw_expr);
    if (stmt.stmt.raw_expr.ty.kind != TYPE_KIND_BASE ||
        stmt.stmt.raw_expr.ty.type.base != TYPE_VOID)
      fprintf(CG_F, "\tpop r13\n"); // discard the value from the stack
                                    // TODO: manage different sizes
    break;
  case AST_STMT_RETURN:
    if (stmt.stmt.returnn.expr) {
      cg_expr(*stmt.stmt.returnn.expr);
      fprintf(CG_F, "\tpop rax\n");
      if (stmt.stmt.returnn.sret_idx > 0) {
        const Symbol *s = sym_search(stmt.stmt.returnn.sret_idx);
        int sizeb = size_of_type(stmt.stmt.returnn.expr->ty);
        fprintf(CG_F, "\tmov rbx, [rbp-%d]\n", s->offset);
        fprintf(CG_F,
                "\tmov rsi, rax\n" // src
                "\tmov rdi, rbx\n" // dst
                "\tmov rcx, %d\n"  // n bytes
                "\trep movsb\n",   // copy
                sizeb);
        fprintf(CG_F, "\tmov rax, rbx\n");
      }
    }
    fprintf(CG_F, "\tmov rsp, rbp\n"
                  "\tpop rbp\n"
                  "\tret\n");
    break;
  case AST_STMT_BREAK:
    if (!break_lbl)
      ERROR("trying to break from nothing");
    fprintf(CG_F, "\tjmp %s\n", break_lbl);
    break;
  case AST_STMT_CONTINUE:
    if (!continue_lbl)
      ERROR("trying to continue from nothing");
    fprintf(CG_F, "\tjmp %s\n", continue_lbl);
    break;
  }
}

void cg_block(Block b, char break_lbl[16], char continue_lbl[16]) {
  for (int i = 0; i < b.stmts_len; i++) {
    cg_stmt(b.stmts[i], break_lbl, continue_lbl);
  }
};

void cg_fun_def(AST_Def_Fun fun) {
  fprintf(CG_F,
          "\n%.*s:\n"
          "\tpush rbp\n"
          "\tmov rbp, rsp\n"
          "\tsub rsp, %d\n",
          fun.name_len, fun.name, fun.locals_stack_size);

  if (fun.num_args > 6) {
    // TODO: rest of args come in the stack
    UNIMPLEMENTED("args>6");
  }

  int sret_reg_off = 0;
  if (fun.return_type.kind == TYPE_KIND_STRUCT) {
    fprintf(CG_F, "\tmov [rbp-8], %s\n", ARG_REGS[0]);
    sret_reg_off++;
  }
  for (int i = 0; i < fun.num_args; i++) {
    int off = sym_search(fun.arg_sym_idxs[i])->offset;
    fprintf(CG_F, "\tmov [rbp-%d], %s\n", off, ARG_REGS[i + sret_reg_off]);
  }

  cg_block(fun.block, NULL, NULL);
}

void cg_data_def(AST_Stmt_Declare d) {
  if (d.t.kind == TYPE_KIND_PTR && d.t.type.ptr->type.base == TYPE_CHAR) {
    fprintf(CG_F, "\tGLBL_%.*s: db \"%s\", 0\n", d.var_name_len, d.var_name,
            d.expr->expr.lit_string.text);
    return;
  }

  if (d.t.kind == TYPE_KIND_PTR) {
    fprintf(CG_F, "\tGLBL_%.*s: dq %lu\n", d.var_name_len, d.var_name,
            d.expr->expr.lit_int.value);
    return;
  }

  if (d.t.kind == TYPE_KIND_BASE) {
    switch (d.t.type.base) {
    case TYPE_BOOL:
      fprintf(CG_F, "\tGLBL_%.*s: db %d\n", d.var_name_len, d.var_name,
              d.expr->expr.lit_bool.value);
      break;
    case TYPE_INT:
      fprintf(CG_F, "\tGLBL_%.*s: dq %lu\n", d.var_name_len, d.var_name,
              d.expr->expr.lit_int.value);
      break;
    case TYPE_CHAR:
      fprintf(CG_F, "\tGLBL_%.*s: db '%c'\n", d.var_name_len, d.var_name,
              d.expr->expr.lit_char.value);
      break;
    case TYPE_VOID:
      UNIMPLEMENTED("VOID data def");
    }
    return;
  }
  ERROR("Error type can't be constant %s\n", ast_fmt_type(d.t));
}

void cg_rodata() {
  // TODO: create string table while lexing
  fprintf(CG_F, "\n\nsection .rodata\n");
  if (CG_STRS.len > 0) {
    for (int i = 0; i < CG_STRS.len; i++) {
      CG_StrEntry s = CG_STRS.strings[i];
      fprintf(CG_F, "\tSTR_%d: db \"", s.label);
      int j = 0;
      while (1) {
        char c = s.text[j++];
        if (c == '\0')
          break;
        if (c <= '\r' || c == '"') {
          fprintf(CG_F, "\", %d, \"", c);
          continue;
        }
        fprintf(CG_F, "%c", c);
      }
      fprintf(CG_F, "\", 0\n");
    }
  }

  const SymT *st = sym_all();
  for (int i = 0; i < st->len; i++) {
    if (st->symbols[i].kind == SYM_KIND_CONST) {
      AST_Stmt_Declare d = st->symbols[i].def;
      cg_data_def(d);
    }
  }
}

void cg_data() {
  fprintf(CG_F, "\nsection .data\n");
  const SymT *st = sym_all();

  for (int i = 0; i < st->len; i++) {
    if (st->symbols[i].kind == SYM_KIND_VAR) {
      AST_Stmt_Declare d = st->symbols[i].def;
      cg_data_def(d);
    }
  }
}

void gen_asm(AST ast) {
  CG_F = fopen("out.s", "w");
  if (!CG_F)
    ERROR("unable to open out.s\n");

  cg_init_maps();
  cg_head();

  for (int i = 0; i < ast.defs_len; i++) {
    if (ast.defs[i].kind != AST_DEF_FUN)
      continue;
    cg_fun_def(ast.defs[i].def.fun);
  }
  cg_entry();
  cg_rodata();
  cg_data();
  fclose(CG_F);
}
