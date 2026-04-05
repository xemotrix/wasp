#pragma once

#include "token.h"

Token lex_token(char **src);
Token peek_token(char *src);
