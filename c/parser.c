#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "ast.h"
#include "error.h"
#include "lexer.h"
#include "token.h"

Block parse_block(char **src, Token t);
AST_Expr parse_expr(char **src, Token t);

AST_Expr parse_var(Token t) {
  AST_Expr e;
  e.kind = AST_EXPR_VAR;
  e.expr.var.name = t.text;
  e.expr.var.name_len = t.text_len;
  return e;
}

AST_Expr parse_lit_char(Token t) {
  AST_Expr e;
  e.kind = AST_EXPR_LIT_CHAR;
  if (t.text[1] != '\\') {
    e.expr.lit_char.value = t.text[1];
    return e;
  }
  switch (t.text[2]) {
  case '\'':
    e.expr.lit_char.value = '\'';
    break;
  case '\\':
    e.expr.lit_char.value = '\\';
    break;
  case 'n':
    e.expr.lit_char.value = '\n';
    break;
  case 't':
    e.expr.lit_char.value = '\t';
    break;
  case 'r':
    e.expr.lit_char.value = '\r';
    break;
  case '0':
    e.expr.lit_char.value = '\0';
    break;
  }
  return e;
}

AST_Expr parse_lit_string(Token t) {
  AST_Expr e;
  e.kind = AST_EXPR_LIT_STRING;
  e.expr.lit_string.text = malloc(t.text_len - 1);

  int dest_i = 0;
  for (int i = 1; i < t.text_len - 1; i++) {
    char c = t.text[i];
    if (c != '\\') {
      e.expr.lit_string.text[dest_i++] = c;
      continue;
    }
    switch (t.text[++i]) {
    case 'n':
      e.expr.lit_string.text[dest_i++] = '\n';
      break;
    case '"':
      e.expr.lit_string.text[dest_i++] = '"';
      break;
    case 't':
      e.expr.lit_string.text[dest_i++] = '\t';
      break;
    case 'r':
      e.expr.lit_string.text[dest_i++] = '\r';
      break;
    case '0':
      e.expr.lit_string.text[dest_i++] = '\0';
      break;
    }
  }
  e.expr.lit_string.text[dest_i] = '\0';
  return e;
}

AST_Expr parse_lit_bool(Token t) {
  AST_Expr e;
  e.kind = AST_EXPR_LIT_BOOL;
  if (memcmp(t.text, "true", 4) == 0) {
    e.expr.lit_bool.value = 1;
    return e;
  } else if (memcmp(t.text, "false", 5) == 0) {
    e.expr.lit_bool.value = 0;
    return e;
  }
  ERROR("invalid boolean literal");
}

AST_Expr parse_lit_int(Token t) {
  char *num_str = malloc((1 + t.text_len) * sizeof(char));
  memcpy(num_str, t.text, t.text_len);
  num_str[t.text_len] = '\0';
  unsigned long num = atol(num_str);
  free(num_str);
  return (AST_Expr){
      .kind = AST_EXPR_LIT_INT,
      .expr.lit_int = {.value = num},
  };
}

AST_Expr parse_call(char **src, Token t, AST_Expr fun_expr) {
  AST_Expr expr;
  expr.kind = AST_EXPR_CALL;

  assert(fun_expr.kind == AST_EXPR_VAR);
  expr.expr.call.fun_expr = malloc(sizeof(AST_Expr));
  *expr.expr.call.fun_expr = fun_expr;
  expr.expr.call.is_syscall =
      (fun_expr.expr.var.name_len == 7 &&
       memcmp(fun_expr.expr.var.name, "syscall", 7) == 0);

  t = lex_token(src);
  if (t.type != TOK_LPAREN)
    ERROR("Expected '('");

  int args_cap = 2;
  expr.expr.call.args = malloc(args_cap * sizeof(AST_Expr));
  expr.expr.call.args_len = 0;
  while (1) {
    t = lex_token(src);
    if (t.type == TOK_RPAREN)
      break;
    if (t.type == TOK_EOF)
      ERROR("Expected ')' or expression but found EOF");
    if (expr.expr.call.args_len >= args_cap) {
      args_cap *= 2;
      expr.expr.call.args =
          realloc(expr.expr.call.args, args_cap * sizeof(AST_Expr));
    }
    expr.expr.call.args[expr.expr.call.args_len] = parse_expr(src, t);
    expr.expr.call.args_len++;
    t = lex_token(src);
    if (t.type == TOK_COMMA)
      continue;
    if (t.type == TOK_RPAREN)
      break;
    ERROR("Expected ',' or ')'");
  }

  return expr;
}

const int PREFIX_PREC[] = {
    [TOK_BANG] = 20,      //
    [TOK_TILDE] = 20,     //
    [TOK_PLUS] = 20,      //
    [TOK_MINUS] = 20,     //
    [TOK_AMPERSAND] = 20, //
    [TOK_ASTERISK] = 20,  //
    [TOK_EOF] = 0,        //
};

const int POSTFIX_PREC[] = {
    [TOK_LPAREN] = 10, // funcalls
    [TOK_LSQBR] = 10,  // array subscript
    [TOK_EOF] = 0,     //
};

const int INFIX_PREC[] = {
    [TOK_PERIOD] = 10,       //
    [TOK_ASTERISK] = 40,     //
    [TOK_PERCENT] = 40,      //
    [TOK_SLASH] = 40,        //
    [TOK_PLUS] = 50,         //
    [TOK_MINUS] = 50,        //
    [TOK_SHIFT_LEFT] = 60,   //
    [TOK_SHIFT_RIGHT] = 60,  //
    [TOK_LT] = 70,           //
    [TOK_LTE] = 70,          //
    [TOK_GT] = 70,           //
    [TOK_GTE] = 70,          //
    [TOK_EQUALSEQUALS] = 80, //
    [TOK_BANGEQUALS] = 80,   //
    [TOK_AMPERSAND] = 90,    //
    [TOK_BIT_OR] = 100,      //
    [TOK_AND] = 110,         //
    [TOK_OR] = 120,          //
    [TOK_EOF] = 0,           //
};
#define MAX_PREC 999

bool is_atomic(TokenType tt) {
  switch (tt) {
  case TOK_LIT_INT:
  case TOK_LIT_BOOL:
  case TOK_LIT_STRING:
  case TOK_LIT_CHAR:
  case TOK_IDEN:
    return true;
  default:
    return false;
  }
}

AST_Expr parse_expr_with_prec(char **src, Token t, int prec) {
  AST_Expr left;
  int pre_prec = PREFIX_PREC[t.type];

  if (is_atomic(t.type)) {
    switch (t.type) {
    case TOK_LIT_INT:
      left = parse_lit_int(t);
      break;
    case TOK_LIT_BOOL:
      left = parse_lit_bool(t);
      break;
    case TOK_LIT_STRING:
      left = parse_lit_string(t);
      break;
    case TOK_LIT_CHAR:
      left = parse_lit_char(t);
      break;
    case TOK_IDEN:
      left = parse_var(t);
      break;
    default:
      ERROR("unreachable");
    }
  } else if (t.type == TOK_LPAREN) {
    t = lex_token(src);
    left = parse_expr(src, t);
    t = lex_token(src);
    if (t.type != TOK_RPAREN)
      ERROR("Expected ')' found %d", t.type);
  } else if (pre_prec) {
    left.kind = AST_EXPR_UNOP;
    left.expr.unop.op = t.type;
    t = lex_token(src);
    left.expr.unop.expr = malloc(sizeof(AST_Expr));
    *left.expr.unop.expr = parse_expr_with_prec(src, t, pre_prec);
  }

  Token op;
  AST_Expr res = left;

  while (1) {
    op = peek_token(*src);
    // postfix operators:
    int postf_prec = POSTFIX_PREC[op.type];
    if (postf_prec) {
      if (postf_prec >= prec)
        break;
      switch (op.type) {
      case TOK_LPAREN:
        res = parse_call(src, t, left);
        break;
      case TOK_LSQBR:
        lex_token(src);
        t = lex_token(src);
        AST_Expr new_res;
        new_res.kind = AST_EXPR_BINOP;
        new_res.expr.binop.left = malloc(sizeof(AST_Expr));
        *new_res.expr.binop.left = res;
        new_res.expr.binop.op = op.type;
        new_res.expr.binop.right = malloc(sizeof(AST_Expr));
        *new_res.expr.binop.right = parse_expr(src, t);
        t = lex_token(src);
        if (t.type != TOK_RSQBR)
          ERROR("Missing closing ']'");
        res = new_res;
        break;
      default:
        ERROR("unreachable %d", op.type);
      }
      continue;
    }

    // infix operators:
    int inf_prec = INFIX_PREC[op.type];
    if (inf_prec) {
      if (inf_prec >= prec)
        break;

      t = lex_token(src);
      AST_Expr new_res;
      new_res.kind = AST_EXPR_BINOP;
      new_res.expr.binop.left = malloc(sizeof(AST_Expr));
      *new_res.expr.binop.left = res;
      new_res.expr.binop.op = t.type;

      t = lex_token(src);
      new_res.expr.binop.right = malloc(sizeof(AST_Expr));
      *new_res.expr.binop.right = parse_expr_with_prec(src, t, inf_prec);
      res = new_res;
      continue;
    }
    break;
  }
  return res;
}

AST_Expr parse_expr(char **src, Token t) {
  return parse_expr_with_prec(src, t, MAX_PREC);
}

Type parse_type(char **src, Token t) {
  if (t.type == TOK_ASTERISK) {
    t = lex_token(src);
    return ast_new_ptr_type(parse_type(src, t));
  }
  if (t.type == TOK_IDEN) {
    Type ty;
    ty.kind = TYPE_KIND_STRUCT;
    ty.type.struct_name.name = t.text;
    ty.type.struct_name.name_len = t.text_len;
    return ty;
  }

  BaseType bt;
  switch (t.type) {
  case TOK_TY_VOID:
    bt = TYPE_VOID;
    break;
  case TOK_TY_CHAR:
    bt = TYPE_CHAR;
    break;
  case TOK_TY_BOOL:
    bt = TYPE_BOOL;
    break;
  case TOK_TY_INT:
    bt = TYPE_INT;
    break;
  default:
    ERROR("Expected type");
  }
  Type ty = ast_new_base_type(bt);
  return ty;
}

AST_Stmt parse_stmt_define(char **src, Token t) {
  AST_Stmt stmt;
  stmt.kind = AST_STMT_DEFINE;
  stmt.stmt.define.var_name = t.text;
  stmt.stmt.define.var_name_len = t.text_len;
  lex_token(src); // skip the ':' (should already be checked for)
  t = lex_token(src);
  switch (t.type) {
  case TOK_TY_BOOL:
  case TOK_TY_INT:
  case TOK_TY_VOID:
  case TOK_TY_CHAR:
  case TOK_ASTERISK:
  case TOK_IDEN:
    stmt.stmt.define.t = parse_type(src, t);
    break;
  default:
    ERROR("Expected type after ':'");
  }
  t = lex_token(src);
  if (t.type == TOK_SEMICOLON) {
    stmt.stmt.define.expr = 0;
    return stmt;
  }
  if (t.type != TOK_EQUALS)
    ERROR("Expected '=' after type in definition");
  t = lex_token(src);
  stmt.stmt.define.expr = malloc(sizeof(AST_Expr));
  *stmt.stmt.define.expr = parse_expr(src, t);
  t = lex_token(src);
  if (t.type != TOK_SEMICOLON)
    ERROR("Expected ';'");
  return stmt;
}

AST_Stmt parse_stmt_assign_or_raw_expr(char **src, Token t) {
  AST_Stmt stmt;
  AST_Expr lvalue = parse_expr(src, t);

  t = lex_token(src);

  if (t.type == TOK_SEMICOLON) {
    stmt.kind = AST_STMT_RAW_EXPR;
    stmt.stmt.raw_expr = lvalue;
    return stmt;
  }

  if (t.type != TOK_EQUALS)
    ERROR("Expected '=' or ';' after lvalue");

  stmt.kind = AST_STMT_ASSIGN;
  stmt.stmt.assign.lvalue = lvalue;
  t = lex_token(src);
  stmt.stmt.assign.rvalue = parse_expr(src, t);
  t = lex_token(src);
  if (t.type != TOK_SEMICOLON)
    ERROR("Expected ';'");

  return stmt;
}

AST_Stmt parse_stmt_while(char **src, Token t) {
  AST_Stmt stmt;
  stmt.kind = AST_STMT_WHILE;
  t = lex_token(src);
  stmt.stmt.whilee.cond = malloc(sizeof(AST_Expr));
  *stmt.stmt.whilee.cond = parse_expr(src, t);
  t = lex_token(src);
  stmt.stmt.whilee.block = malloc(sizeof(Block));
  *stmt.stmt.whilee.block = parse_block(src, t);
  return stmt;
}

AST_Stmt parse_stmt_if(char **src, Token t) {
  AST_Stmt stmt;
  stmt.kind = AST_STMT_IF;
  t = lex_token(src);
  stmt.stmt.iff.cond = malloc(sizeof(AST_Expr));
  *stmt.stmt.iff.cond = parse_expr(src, t);
  stmt.stmt.iff.block = malloc(sizeof(Block));
  t = lex_token(src);
  *stmt.stmt.iff.block = parse_block(src, t);
  return stmt;
}

AST_Stmt parse_stmt_return(char **src, Token t) {
  AST_Stmt stmt;
  stmt.kind = AST_STMT_RETURN;
  t = lex_token(src);
  if (t.type == TOK_SEMICOLON) {
    stmt.stmt.returnn.expr = NULL;
    return stmt;
  }
  stmt.stmt.returnn.expr = malloc(sizeof(AST_Expr));
  *stmt.stmt.returnn.expr = parse_expr(src, t);
  t = lex_token(src);
  if (t.type != TOK_SEMICOLON)
    ERROR("Expected ';'");
  return stmt;
}

AST_Stmt parse_stmt(char **src, Token t) {
  switch (t.type) {
  case TOK_KW_BREAK:
    t = lex_token(src);
    if (t.type != TOK_SEMICOLON)
      ERROR("expected semicolon after break");
    return (AST_Stmt){.kind = AST_STMT_BREAK};
  case TOK_KW_CONTINUE:
    t = lex_token(src);
    if (t.type != TOK_SEMICOLON)
      ERROR("expected semicolon after continue");
    return (AST_Stmt){.kind = AST_STMT_CONTINUE};
  case TOK_KW_RETURN:
    return parse_stmt_return(src, t);
  case TOK_KW_IF:
    return parse_stmt_if(src, t);
  case TOK_KW_WHILE:
    return parse_stmt_while(src, t);
  case TOK_IDEN:
    printf("");
    Token pt = peek_token(*src);
    if (pt.type == TOK_COLON)
      return parse_stmt_define(src, t);
    return parse_stmt_assign_or_raw_expr(src, t);
  case TOK_ASTERISK:
    return parse_stmt_assign_or_raw_expr(src, t);
  default:
    ERROR("invalid statement");
  }
}

Block parse_block(char **src, Token t) {
  if (t.type != TOK_LCURLY)
    ERROR("Blocks should start with '{'");
  Block b;
  b.stmts_len = 0;
  b.stmt_cap = 4;
  b.stmts = malloc(b.stmt_cap * sizeof(AST_Stmt));
  if (!b.stmts)
    ERROR("malloc error");
  while (1) {
    t = lex_token(src);
    if (t.type == TOK_RCURLY)
      break;
    if (t.type == TOK_EOF)
      ERROR("Expected '}' or statement");
    if (b.stmts_len >= b.stmt_cap) {
      b.stmt_cap *= 2;
      b.stmts = realloc(b.stmts, b.stmt_cap * sizeof(AST_Stmt));
      if (!b.stmts)
        ERROR("realloc error");
    }
    b.stmts[b.stmts_len++] = parse_stmt(src, t);
  }
  return b;
}

AST_Def parse_def_fun(char **src, Token t) {
  AST_Def def;
  def.kind = AST_DEF_FUN;

  AST_Def_Fun *fun = &def.def.fun;

  // parse name
  t = lex_token(src);
  fun->name = t.text;
  fun->name_len = t.text_len;
  t = lex_token(src);
  if (t.type != TOK_LPAREN)
    ERROR("Expected '('");

  // parse args
  int arg_names_cap = 2;
  fun->num_args = 0;
  fun->arg_names = malloc(arg_names_cap * sizeof(char *));
  fun->arg_name_lens = malloc(arg_names_cap * sizeof(int));
  fun->arg_types = malloc(arg_names_cap * sizeof(Type));
  fun->arg_sym_idxs = malloc(arg_names_cap * sizeof(int));

  while (1) {
    t = lex_token(src);
    if (t.type == TOK_RPAREN)
      break;
    if (t.type == TOK_EOF)
      ERROR("Expected ')' or fun arg but reached EOF");
    if (t.type != TOK_IDEN)
      ERROR("Expected Identifier");
    if (fun->num_args >= arg_names_cap) {
      arg_names_cap *= 2;
      fun->arg_names = realloc(fun->arg_names, arg_names_cap * sizeof(char *));
      fun->arg_name_lens =
          realloc(fun->arg_name_lens, arg_names_cap * sizeof(int));
      fun->arg_types = realloc(fun->arg_types, arg_names_cap * sizeof(Type));
      fun->arg_sym_idxs =
          realloc(fun->arg_sym_idxs, arg_names_cap * sizeof(int));
    }

    fun->arg_names[fun->num_args] = t.text;
    fun->arg_name_lens[fun->num_args] = t.text_len;

    t = lex_token(src);
    if (t.type != TOK_COLON)
      ERROR("expected ':'");
    t = lex_token(src);
    Type ty = parse_type(src, t);
    fun->arg_types[fun->num_args++] = ty;

    t = lex_token(src);
    if (t.type == TOK_COMMA)
      continue;
    if (t.type == TOK_RPAREN)
      break;
    ERROR("Expected ',' or ')' in function signature");
  }

  t = lex_token(src);
  if (t.type == TOK_LCURLY) {
    Type void_t;
    void_t.kind = TYPE_KIND_BASE;
    void_t.type.base = TYPE_VOID;
    fun->return_type = void_t;
  } else {
    fun->return_type = parse_type(src, t);
    t = lex_token(src);
  }

  fun->block = parse_block(src, t);
  return def;
}

AST_Def parse_def_varconst(char **src, Token t) {
  AST_Def d;
  if (t.type == TOK_KW_CONST)
    d.kind = AST_DEF_CONST;
  if (t.type == TOK_KW_VAR)
    d.kind = AST_DEF_VAR;

  t = lex_token(src);
  AST_Stmt stmt = parse_stmt_define(src, t);
  AST_Expr_Kind kind = stmt.stmt.define.expr->kind;
  if (kind != AST_EXPR_LIT_INT && kind != AST_EXPR_LIT_STRING &&
      kind != AST_EXPR_LIT_CHAR && kind != AST_EXPR_LIT_BOOL)
    ERROR("consts can't be anything other than literals");
  d.def.global = stmt.stmt.define;
  return d;
}

AST_Def parse_def_struct(char **src, Token t) {
  AST_Def def;
  def.kind = AST_DEF_TYPE;
  t = lex_token(src);
  if (t.type != TOK_IDEN)
    ERROR("Expected identifier after 'struct'");
  def.def.stru.name = t.text;
  def.def.stru.name_len = t.text_len;
  t = lex_token(src);
  if (t.type != TOK_LCURLY)
    ERROR("Expected '{' after struct identifier");

  int cap = 2;
  def.def.stru.field_names = malloc(cap * sizeof(char *));
  def.def.stru.field_name_lens = malloc(cap * sizeof(int));
  def.def.stru.types = malloc(cap * sizeof(Type));

  int n_args = 0;
  while (true) {
    if (n_args >= cap) {
      cap *= 2;
      def.def.stru.field_names =
          realloc(def.def.stru.field_names, cap * sizeof(char *));
      def.def.stru.field_name_lens =
          realloc(def.def.stru.field_name_lens, cap * sizeof(int));
      def.def.stru.types = realloc(def.def.stru.types, cap * sizeof(Type));
    }
    t = lex_token(src);
    if (t.type == TOK_RCURLY)
      break;
    if (t.type != TOK_IDEN)
      ERROR("Expected identifier in struct definition");
    def.def.stru.field_names[n_args] = t.text;
    def.def.stru.field_name_lens[n_args] = t.text_len;

    t = lex_token(src);
    if (t.type != TOK_COLON)
      ERROR("Expected ':' after identifier in struct definition");
    t = lex_token(src);
    def.def.stru.types[n_args] = parse_type(src, t);
    t = lex_token(src);
    if (t.type != TOK_SEMICOLON)
      ERROR("Expected ';' after type in struct definition");
    n_args++;
  }

  def.def.stru.n_fields = n_args;
  return def;
}

AST_Def parse_def(char **src, Token t) {
  switch (t.type) {
  case TOK_KW_CONST:
  case TOK_KW_VAR:
    return parse_def_varconst(src, t);
  case TOK_KW_STRUCT:
    return parse_def_struct(src, t);
  case TOK_KW_FN:
    return parse_def_fun(src, t);
  default:
    ERROR("Expected function definition starting with fn");
    // unreachable
    return (AST_Def){};
  }
}

AST parse(char **src) {
  AST ast;
  int cap = 2;
  ast.defs = malloc(cap * sizeof(AST_Def));
  ast.defs_len = 0;
  Token t;
  while (1) {
    t = lex_token(src);
    if (t.type == TOK_EOF)
      break;
    if (ast.defs_len >= cap) {
      cap *= 2;
      ast.defs = realloc(ast.defs, cap * sizeof(AST_Def));
    }
    ast.defs[ast.defs_len++] = parse_def(src, t);
  }
  return ast;
}
