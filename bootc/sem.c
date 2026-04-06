#include <assert.h>
#include <stdbool.h>
#include <string.h>

#include "ast.h"
#include "error.h"
#include "sym.h"

bool tc_can_unify(Type from, Type to) {
  return size_of_type(from) == size_of_type(to);
}

void tc_expr(AST_Expr *expr);

Type tc_call(AST_Expr_Call *c) {
  if (c->is_syscall) {
    for (int i = 0; i < c->args_len; i++) {
      tc_expr(&c->args[i]);
    }
    return ast_new_base_type(TYPE_INT);
  }
  assert(c->fun_expr->kind == AST_EXPR_VAR);
  char *fun_name = c->fun_expr->expr.var.name;
  int fun_name_len = c->fun_expr->expr.var.name_len;
  int sym_idx = sym_stack_search(fun_name, fun_name_len);
  const Symbol *s = sym_search(sym_idx);
  c->fun_expr->expr.var.sym_idx = sym_idx;
  if (s->kind != SYM_KIND_FUN)
    ERROR("symbol is not a function");
  AST_Def_Fun *f = s->fun;
  if (c->args_len != f->num_args)
    ERROR("function '%.*s' requires %d args but %d provided\n", fun_name_len,
          fun_name, f->num_args, c->args_len);

  c->temporary_sym_idxs = malloc(c->args_len * sizeof(int));
  for (int i = 0; i < c->args_len; i++) {
    AST_Expr *arg = &c->args[i];
    tc_expr(arg);
    if (arg->ty.kind == TYPE_KIND_STRUCT) {
      c->temporary_sym_idxs[i] = sym_add_temporary(arg->ty);
    } else {
      c->temporary_sym_idxs[i] = -1;
    }
    sym_fill_index_if_struct(&f->arg_types[i]);
    sym_fill_index_if_struct(&c->args[i].ty);
    if (!tc_can_unify(f->arg_types[i], c->args[i].ty)) {
      char *expected = ast_fmt_type(f->arg_types[i]);
      char *provided = ast_fmt_type(c->args[i].ty);
      ERROR("Expected argument of type %s but %s provided\n", expected,
            provided);
    }
    c->args[i].ty = f->arg_types[i];
  }

  if (f->return_type.kind == TYPE_KIND_STRUCT) {
    c->temporary_sret_sym_idx = sym_add_temporary(f->return_type);
  } else {
    c->temporary_sret_sym_idx = -1;
  }

  return f->return_type;
}

Type tc_access(AST_Expr_Binop *access) {
  tc_expr(access->left);
  bool valid_left = (access->left->kind == AST_EXPR_BINOP &&
                     (access->left->expr.binop.op == TOK_PERIOD ||
                      access->left->expr.binop.op == TOK_LSQBR)) ||
                    (access->left->kind == AST_EXPR_VAR);
  if (!valid_left) {
    ERROR("expression of kind %d is not accessible\n", access->left->kind);
  }

  Type left_t = access->left->ty;
  while (left_t.kind == TYPE_KIND_PTR)
    left_t = *left_t.type.ptr; // auto derreference

  if (left_t.kind != TYPE_KIND_STRUCT)
    ERROR("can't access type that is not a struct '%s'\n",
          ast_fmt_type(left_t));

  TypeStructDef ts = sym_search_type_idx(left_t.type.struct_name.sym_idx);

  if (access->right->kind != AST_EXPR_VAR)
    ERROR("invalid access expression: %d", access->right->kind);
  char *field = access->right->expr.var.name;
  int field_len = access->right->expr.var.name_len;

  int accum_offset = 0;
  for (int i = 0; i < ts.n_fields; i++) {
    sym_fill_index_if_struct(&ts.types[i]);
    if (!(field_len == ts.field_name_lens[i] &&
          strncmp(ts.field_names[i], field, field_len) == 0)) {
      accum_offset += size_of_type(ts.types[i]);
      continue;
    }
    access->offsetb = accum_offset;
    return ts.types[i];
  }
  ERROR("type %s doesn't have field '%.*s'", ast_fmt_type(left_t), field_len,
        field);
}

Type tc_subscript(AST_Expr_Binop *binop) {
  assert(binop->op == TOK_LSQBR);
  tc_expr(binop->left);
  Type left_t = binop->left->ty;

  if (left_t.kind != TYPE_KIND_PTR)
    ERROR("can't subscript non pointer like an array");

  tc_expr(binop->right);
  if (binop->right->ty.kind != TYPE_KIND_BASE ||
      binop->right->ty.type.base != TYPE_INT)
    ERROR("can't subscript array with non int expression");
  return *left_t.type.ptr;
}

Type tc_binop(AST_Expr_Binop *binop) {
  AST_Expr *l = binop->left;
  AST_Expr *r = binop->right;
  switch (binop->op) {
  case TOK_EQUALSEQUALS:
  case TOK_BANGEQUALS:
    tc_expr(l);
    tc_expr(r);
    if (!tc_can_unify(l->ty, r->ty) && !tc_can_unify(r->ty, l->ty)) {
      char *l_str = ast_fmt_type(l->ty);
      char *r_str = ast_fmt_type(r->ty);
      ERROR("can't compare different types %s and %s with == or !=\n", l_str,
            r_str);
    }
    return ast_new_base_type(TYPE_BOOL);
  case TOK_GT:
  case TOK_GTE:
  case TOK_LT:
  case TOK_LTE:
    tc_expr(l);
    tc_expr(r);
    if (!tc_can_unify(l->ty, r->ty))
      ERROR("can't compare different typed sizes types with op %d\n",
            binop->op);

    return ast_new_base_type(TYPE_BOOL);
  case TOK_AND:
  case TOK_OR:
    tc_expr(l);
    tc_expr(r);
    if (!tc_can_unify(l->ty, ast_new_base_type(TYPE_BOOL)) ||
        !tc_can_unify(r->ty, ast_new_base_type(TYPE_BOOL)))
      ERROR("can't perform op %d on non booleans\n", binop->op);

    return ast_new_base_type(TYPE_BOOL);
  case TOK_PLUS:
  case TOK_MINUS:
  case TOK_ASTERISK:
  case TOK_PERCENT:
  case TOK_SLASH:
  case TOK_SHIFT_LEFT:
  case TOK_SHIFT_RIGHT:
  case TOK_BIT_OR:
  case TOK_AMPERSAND:
    tc_expr(l);
    tc_expr(r);
    if (!tc_can_unify(l->ty, ast_new_base_type(TYPE_INT)) ||
        !tc_can_unify(r->ty, ast_new_base_type(TYPE_INT)))
      ERROR("can't perform arithmetic op %d on non ints\n", binop->op);

    return l->ty;
  case TOK_PERIOD:
    return tc_access(binop);
  case TOK_LSQBR:
    return tc_subscript(binop);
  default:
    ERROR("invalid operator %d\n", binop->op);
  }
}

Type tc_unop(AST_Expr_Unop *unop) {
  tc_expr(unop->expr);
  switch (unop->op) {
  case TOK_MINUS:
  case TOK_PLUS:
    if (unop->expr->ty.kind != TYPE_KIND_BASE ||
        unop->expr->ty.type.base != TYPE_INT)
      ERROR("invalid unop");
    return unop->expr->ty;
  case TOK_AMPERSAND:
    return ast_new_ptr_type(unop->expr->ty);
    break;
  case TOK_BANG:
  case TOK_TILDE:
    return unop->expr->ty;
    break;
  case TOK_ASTERISK:
    if (unop->expr->ty.kind != TYPE_KIND_PTR) {
      char *str_t = ast_fmt_type(unop->expr->ty);
      ERROR("can't derreference non-pointer type %s", str_t);
    }
    return *unop->expr->ty.type.ptr;
    break;
  default:
    ERROR("unimplemented unop %d\n", unop->op);
  }
}

Type tc_var(AST_Expr_Var *var) {
  int sym_idx = sym_stack_search(var->name, var->name_len);
  const Symbol *sym = sym_search(sym_idx);
  var->sym_idx = sym_idx;
  return sym->t;
}

void tc_expr(AST_Expr *expr) {
  switch (expr->kind) {
  case AST_EXPR_LIT_INT:
    expr->ty = ast_new_base_type(TYPE_INT);
    break;
  case AST_EXPR_LIT_CHAR:
    expr->ty = ast_new_base_type(TYPE_CHAR);
    break;
  case AST_EXPR_LIT_BOOL:
    expr->ty = ast_new_base_type(TYPE_BOOL);
    break;
  case AST_EXPR_LIT_STRING:
    expr->ty = ast_new_ptr_type(ast_new_base_type(TYPE_CHAR));
    break;
  case AST_EXPR_VAR:
    expr->ty = tc_var(&expr->expr.var);
    break;
  case AST_EXPR_UNOP:
    expr->ty = tc_unop(&expr->expr.unop);
    break;
  case AST_EXPR_BINOP:
    expr->ty = tc_binop(&expr->expr.binop);
    break;
  case AST_EXPR_CALL:
    expr->ty = tc_call(&expr->expr.call);
    break;
  default:
    ERROR("unimplemented expr %d\n", expr->kind);
  }
}

void tc_block(Block *b, Type ret);

void tc_stmt(AST_Stmt *stmt, Type ret) {
  AST_Stmt_Declare *decl;
  switch (stmt->kind) {
  case AST_STMT_DEFINE:
    decl = &stmt->stmt.define;
    sym_fill_index_if_struct(&decl->t);
    decl->sym_idx = sym_add_svar(decl->t, decl->var_name, decl->var_name_len);
    if (!decl->expr)
      break;
    tc_expr(decl->expr);
    sym_fill_index_if_struct(&decl->expr->ty);
    sym_fill_index_if_struct(&decl->t);
    if (!tc_can_unify(decl->expr->ty, decl->t)) {
      char *expected = ast_fmt_type(decl->t);
      char *found = ast_fmt_type(decl->expr->ty);
      ERROR("expected type %s, but found %s in definition\n", expected, found);
    }
    break;
  case AST_STMT_ASSIGN:
    tc_expr(&stmt->stmt.assign.lvalue);
    AST_Expr *lvalue = &stmt->stmt.assign.lvalue;

    switch (lvalue->kind) {
    case AST_EXPR_VAR:
      if (sym_search(lvalue->expr.var.sym_idx)->kind == SYM_KIND_CONST)
        ERROR("Can't write to const");
      stmt->stmt.assign.sym_idx = lvalue->expr.var.sym_idx;
      break;
    case AST_EXPR_BINOP:
      if (lvalue->expr.binop.op == TOK_PERIOD) {
        lvalue->ty = tc_access(&lvalue->expr.binop);
        break;
      }
      if (lvalue->expr.binop.op == TOK_LSQBR) {
        lvalue->ty = tc_subscript(&lvalue->expr.binop);
        break;
      }
      ERROR("Expression is not assignable");
    case AST_EXPR_UNOP:
      if (lvalue->expr.unop.op != TOK_ASTERISK)
        ERROR("Expression is not assignable");
      break;
    default:
      ERROR("Left expression is not assignable");
    }

    AST_Expr *rvalue = &stmt->stmt.assign.rvalue;
    tc_expr(rvalue);

    sym_fill_index_if_struct(&lvalue->ty);
    sym_fill_index_if_struct(&rvalue->ty);

    if (!tc_can_unify(lvalue->ty, rvalue->ty)) {
      char *l_t = ast_fmt_type(lvalue->ty);
      char *r_t = ast_fmt_type(rvalue->ty);
      ERROR("can't assign expression of type %s, to destination of type %s\n",
            r_t, l_t);
    }
    stmt->stmt.assign.t = lvalue->ty;
    break;
  case AST_STMT_IF:
    sym_push_frame();
    tc_expr(stmt->stmt.iff.cond);
    if (!tc_can_unify(stmt->stmt.iff.cond->ty, ast_new_base_type(TYPE_BOOL))) {
      char *found = ast_fmt_type(stmt->stmt.iff.cond->ty);
      ERROR("Expected bool in if condition, found %s\n", found);
    }
    tc_block(stmt->stmt.iff.block, ret);
    sym_pop_frame();
    break;
  case AST_STMT_WHILE:
    sym_push_frame();
    tc_expr(stmt->stmt.whilee.cond);
    if (!tc_can_unify(stmt->stmt.whilee.cond->ty,
                      ast_new_base_type(TYPE_BOOL))) {
      char *found = ast_fmt_type(stmt->stmt.whilee.cond->ty);
      ERROR("Expected bool in while condition, found %s\n", found);
    }
    tc_block(stmt->stmt.whilee.block, ret);
    sym_pop_frame();
    break;
  case AST_STMT_RETURN:
    if (ret.kind == TYPE_KIND_BASE && ret.type.base == TYPE_VOID &&
        stmt->stmt.returnn.expr != NULL)
      ERROR("Expected void return");

    // -1 for non structs
    stmt->stmt.returnn.sret_idx = sym_get_sret_idx();

    if (stmt->stmt.returnn.expr) {
      tc_expr(stmt->stmt.returnn.expr);
      if (!tc_can_unify(stmt->stmt.returnn.expr->ty, ret)) {
        char *expected = ast_fmt_type(ret);
        char *found = ast_fmt_type(stmt->stmt.returnn.expr->ty);
        ERROR("must return type %s, but returned %s\n", expected, found);
      }
    }
    break;
  case AST_STMT_RAW_EXPR:
    tc_expr(&stmt->stmt.raw_expr);
    break;
  case AST_STMT_BREAK:
  case AST_STMT_CONTINUE:
    break;
  }
}

void tc_block(Block *b, Type ret) {
  for (int i = 0; i < b->stmts_len; i++)
    tc_stmt(&b->stmts[i], ret);
}

void tc_fun(AST_Def_Fun *fun) {
  sym_push_frame();
  if (fun->return_type.kind == TYPE_KIND_STRUCT) {
    sym_fill_index_if_struct(&fun->return_type);
    int sret_idx =
        sym_add_temporary(ast_new_ptr_type(ast_new_base_type(TYPE_VOID)));
    sym_set_sret_idx(sret_idx);
    fun->sret_sym_idx = sret_idx;
  }
  for (int i = 0; i < fun->num_args; i++) {
    sym_fill_index_if_struct(&fun->arg_types[i]);
    fun->arg_sym_idxs[i] = sym_add_svar_arg(
        fun->arg_types[i], fun->arg_names[i], fun->arg_name_lens[i]);
  }

  tc_block(&fun->block, fun->return_type);
  fun->locals_stack_size = sym_current_frame_size();

  Block *b = &fun->block;
  // insert last "return;" for void functions
  if (fun->return_type.kind == TYPE_KIND_BASE &&
      fun->return_type.type.base == TYPE_VOID &&
      b->stmts[b->stmts_len - 1].kind != AST_STMT_RETURN) {
    AST_Stmt ret_stmt;
    ret_stmt.kind = AST_STMT_RETURN;
    ret_stmt.stmt.returnn.expr = NULL;
    if (b->stmt_cap <= b->stmts_len)
      b->stmts = realloc(b->stmts, ++b->stmt_cap * sizeof(AST_Stmt));
    b->stmts[b->stmts_len++] = ret_stmt;
  }

  // check that some last return exists
  if (b->stmts[b->stmts_len - 1].kind != AST_STMT_RETURN)
    ERROR("function without return");

  sym_pop_frame();
}

void tc_def(AST_Def *def) {
  switch (def->kind) {
  case AST_DEF_CONST:
  case AST_DEF_VAR:
  case AST_DEF_TYPE:
    return;
  case AST_DEF_FUN:
    tc_fun(&def->def.fun);
    break;
  }
}

void define_top_level(AST *ast) {
  for (int i = 0; i < ast->defs_len; i++) {
    AST_Def *d = &ast->defs[i];
    switch (d->kind) {
    case AST_DEF_FUN:
      sym_add_fun(&d->def.fun);
      break;
    case AST_DEF_TYPE:
      sym_add_type(d->def.stru);
      break;
    case AST_DEF_VAR:
      tc_expr(d->def.global.expr);
      sym_add_global_var(d->def.global);
      break;
    case AST_DEF_CONST:
      tc_expr(d->def.global.expr);
      sym_add_global_const(d->def.global);
      break;
    }
  }
}

void type_check(AST *ast) {
  sym_init_tables();
  sym_push_frame();
  define_top_level(ast);
  sym_compute_type_sizes();
  for (int i = 0; i < ast->defs_len; i++) {
    tc_def(&ast->defs[i]);
  }
  sym_pop_frame();
}
