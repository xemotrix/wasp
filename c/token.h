#pragma once

typedef enum {
  // values
  TOK_IDEN,
  TOK_LIT_INT,
  TOK_LIT_BOOL,
  TOK_LIT_STRING,
  TOK_LIT_CHAR,

  // types
  TOK_TY_VOID,
  TOK_TY_INT,
  TOK_TY_BOOL,
  TOK_TY_CHAR,

  // Keywords
  TOK_KW_IF,
  TOK_KW_WHILE,
  TOK_KW_BREAK,
  TOK_KW_RETURN,
  TOK_KW_CONST,
  TOK_KW_VAR,
  TOK_KW_STRUCT,
  TOK_KW_CONTINUE,
  TOK_KW_FN,

  // operators
  TOK_BANG,
  TOK_TILDE,
  TOK_EQUALSEQUALS,
  TOK_BANGEQUALS,
  TOK_PERCENT,
  TOK_SLASH,
  TOK_GT,
  TOK_GTE,
  TOK_LT,
  TOK_LTE,
  TOK_AND, // &&
  TOK_OR,
  TOK_BIT_OR,
  TOK_AMPERSAND, // &
  TOK_PLUS,
  TOK_MINUS,
  TOK_SHIFT_LEFT,  // <<
  TOK_SHIFT_RIGHT, // >>
  TOK_ASTERISK,

  // Punctuation
  TOK_PERIOD,
  TOK_EQUALS,
  TOK_SEMICOLON,
  TOK_COLON,
  TOK_COMMA,
  TOK_LPAREN,
  TOK_RPAREN,
  TOK_LCURLY, // {
  TOK_RCURLY, // }
  TOK_LSQBR,  // [
  TOK_RSQBR,  // ]

  TOK_EOF, // TOK_EOF needs to be the last token to check limits
} TokenType;

typedef struct {
  TokenType type;
  char *text;
  int text_len;
} Token;
