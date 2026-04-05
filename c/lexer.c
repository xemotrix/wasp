#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "error.h"
#include "token.h"

bool is_digit(char c);
bool is_alpha(char c);
bool is_whitespace(char c);
Token lex_num(char *src);
Token lex_iden(char *src);
Token lex_token(char **src);
Token lex_string(char *src);
Token lex_char(char *src);
int len_skip_comments(char *src);

Token peek_token(char *src) {
  char *ref = 0;
  while (ref != src) {
    ref = src;
    while (is_whitespace(*src))
      src++;
    src += len_skip_comments(src);
  }

  if (*src == '\0')
    return (Token){.type = TOK_EOF};

  if (is_digit(*src))
    return lex_num(src);
  if (is_alpha(*src))
    return lex_iden(src);
  if (*src == '"')
    return lex_string(src);
  if (*src == '\'')
    return lex_char(src);

  Token t;
  t.text = src;
  t.text_len = 1;

  switch (*src) {
  case '(':
    t.type = TOK_LPAREN;
    break;
  case ')':
    t.type = TOK_RPAREN;
    break;
  case '{':
    t.type = TOK_LCURLY;
    break;
  case '}':
    t.type = TOK_RCURLY;
    break;
  case '[':
    t.type = TOK_LSQBR;
    break;
  case ']':
    t.type = TOK_RSQBR;
    break;
  case '%':
    t.type = TOK_PERCENT;
    break;
  case '/':
    t.type = TOK_SLASH;
    break;
  case '+':
    t.type = TOK_PLUS;
    break;
  case '-':
    t.type = TOK_MINUS;
    break;
  case '*':
    t.type = TOK_ASTERISK;
    break;
  case ';':
    t.type = TOK_SEMICOLON;
    break;
  case ':':
    t.type = TOK_COLON;
    break;
  case ',':
    t.type = TOK_COMMA;
    break;
  case '.':
    t.type = TOK_PERIOD;
    break;
  case '~':
    t.type = TOK_TILDE;
    break;
  case '!':
    t.type = TOK_BANG;
    if (src[1] != '\0' && src[1] == '=') {
      t.text_len++;
      t.type = TOK_BANGEQUALS;
      break;
    }
    break;
  case '|':
    t.type = TOK_BIT_OR;
    if (src[1] != '\0' && src[1] == '|') {
      t.text_len++;
      t.type = TOK_OR;
      break;
    }
    break;
  case '&':
    t.type = TOK_AMPERSAND;
    if (src[1] != '\0' && src[1] == '&') {
      t.text_len++;
      t.type = TOK_AND;
      break;
    }
    break;
  case '<':
    t.type = TOK_LT;
    if (src[1] != '\0' && src[1] == '=') {
      t.text_len++;
      t.type = TOK_LTE;
    }
    if (src[1] != '\0' && src[1] == '<') {
      t.text_len++;
      t.type = TOK_SHIFT_LEFT;
    }
    break;
  case '>':
    t.type = TOK_GT;
    if (src[1] != '\0' && src[1] == '=') {
      t.text_len++;
      t.type = TOK_GTE;
    }
    if (src[1] != '\0' && src[1] == '>') {
      t.text_len++;
      t.type = TOK_SHIFT_RIGHT;
    }
    break;
  case '=':
    t.type = TOK_EQUALS;
    if (src[1] != '\0' && src[1] == '=') {
      t.text_len++;
      t.type = TOK_EQUALSEQUALS;
    }
    break;
  default:
    ERROR("unknown token '%c' (%d)\n", *src, *src);
  }
  return t;
}

bool is_whitespace(char c) {
  return c == ' ' || c == '\t' || c == '\r' || c == '\n';
}
bool is_alpha(char c) {
  return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}
bool is_digit(char c) { return c >= '0' && c <= '9'; }

Token lex_iden(char *src) {
  int c = 0;
  while (is_alpha(src[c]) || is_digit(src[c]) || src[c] == '_') {
    c++;
  }

  Token t = {
      .text_len = c,
      .text = src,
  };

  switch (c) {
  case 2:
    if (memcmp(src, "if", c) == 0) {
      t.type = TOK_KW_IF;
      return t;
    }
    if (memcmp(src, "fn", c) == 0) {
      t.type = TOK_KW_FN;
      return t;
    }
    break;
  case 3:
    if (memcmp(src, "var", c) == 0) {
      t.type = TOK_KW_VAR;
      return t;
    }
    if (memcmp(src, "int", c) == 0) {
      t.type = TOK_TY_INT;
      return t;
    }
    break;
  case 4:
    if (memcmp(src, "char", c) == 0) {
      t.type = TOK_TY_CHAR;
      return t;
    }
    if (memcmp(src, "void", c) == 0) {
      t.type = TOK_TY_VOID;
      return t;
    }
    if (memcmp(src, "bool", c) == 0) {
      t.type = TOK_TY_BOOL;
      return t;
    }
    if (memcmp(src, "true", c) == 0) {
      t.type = TOK_LIT_BOOL;
      return t;
    }
    break;
  case 5:
    if (memcmp(src, "const", c) == 0) {
      t.type = TOK_KW_CONST;
      return t;
    }
    if (memcmp(src, "while", c) == 0) {
      t.type = TOK_KW_WHILE;
      return t;
    }
    if (memcmp(src, "break", c) == 0) {
      t.type = TOK_KW_BREAK;
      return t;
    }
    if (memcmp(src, "false", c) == 0) {
      t.type = TOK_LIT_BOOL;
      return t;
    }
    break;
  case 6:
    if (memcmp(src, "struct", c) == 0) {
      t.type = TOK_KW_STRUCT;
      return t;
    }
    if (memcmp(src, "return", c) == 0) {
      t.type = TOK_KW_RETURN;
      return t;
    }
    break;
  case 8:
    if (memcmp(src, "continue", c) == 0) {
      t.type = TOK_KW_CONTINUE;
      return t;
    }
    break;
  }
  t.type = TOK_IDEN;
  return t;
}

Token lex_string(char *src) {
  Token t;
  t.text_len = 0;
  t.text = src;
  t.type = TOK_LIT_STRING;
  while (1) {
    t.text_len++;
    if (src[t.text_len] == '\0')
      ERROR("unfinished string literal");
    if (src[t.text_len] == '\\' && src[t.text_len + 1] != '\0' &&
        src[t.text_len + 1] == '"') {
      t.text_len++;
      continue;
    }
    if (src[t.text_len] == '"')
      break;
  }
  t.text_len++;
  return t;
}

Token lex_char(char *src) {
  Token t;
  t.type = TOK_LIT_CHAR;
  t.text_len = 2;
  t.text = src;
  if (src[1] == '\\') {
    switch (src[2]) {
    case 'n':
    case 'r':
    case 't':
    case '\\':
    case '\'':
    case '0':
      t.text_len++;
      break;
    default:
      ERROR("unrecognized scaped character '%c'", src[2]);
    }
  }
  if (src[t.text_len] != '\'')
    ERROR("expected closing '");

  t.text_len++;
  return t;
}

Token lex_num(char *src) {
  int len = 0;
  while (is_digit(src[len])) {
    len++;
  }
  return (Token){
      .type = TOK_LIT_INT,
      .text_len = len,
      .text = src,
  };
}

int len_skip_comments(char *src) {
  if (src[0] == 0 || src[1] == 0)
    return 0;
  if (src[0] != '/' || src[1] != '/')
    return 0;
  int i;
  for (i = 2;; i++) {
    if (src[i] == '\n' || src[i] == '\0')
      break;
  }
  return i;
}

Token lex_token(char **src) {
  char *ref = 0;
  while (ref != *src) {
    ref = *src;
    while (is_whitespace(**src))
      (*src)++;
    *src += len_skip_comments(*src);
  }

  Token t = peek_token(*src);
  printf("lexed token %02d '%.*s'\n", t.type, t.text_len, t.text);
  *src += t.text_len;
  return t;
}
