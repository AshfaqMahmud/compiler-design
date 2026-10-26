%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <limits.h>
#include "ast.h"
#include "main.tab.h"

int lexer_line = 1;
static int lexer_column = 1;
static int comment_line;
#define YY_USER_ACTION \
    yylloc.first_line = lexer_line; \
    yylloc.first_column = lexer_column; \
    for (size_t i = 0; i < (size_t)yyleng; ++i) { \
        if (yytext[i] == '\n') { ++lexer_line; lexer_column = 1; } \
        else ++lexer_column; \
    } \
    yylloc.last_line = lexer_line; \
    yylloc.last_column = lexer_column;
%}

%option noyywrap noinput nounput
%x COMMENT

identifier      [a-zA-Z_][a-zA-Z0-9_]*
number          [0-9]+

%%
"initializing program :"   { return STARTPROGRAM; }
"initializing program"     { return STARTPROGRAM; }
"begin-"                    { return CBS; }
"-end"                      { return CBE; }

"set"                       { return SET; }
"to"                        { return TO; }
"add"                       { return PLUS; }
"sub"                       { return MINUS; }
"mul"                       { return MUL; }
"div"                       { return DIV; }
"mod"                       { return MOD; }
"lt"                        { return LT; }
"gt"                        { return GT; }
"lte"                       { return LTE; }
"gte"                       { return GTE; }
"equal"                     { return EQUAL; }
"not"                       { return NOT; }
"increment"                 { return INCREMENT; }
"decrement"                 { return DECREMENT; }

"when"                      { return IF; }
"eor"                       { return ELIF; }
"or"                        { return ELSE; }
"loop"                      { return LOOP; }
"switch"                    { return SWITCH; }
"case"                      { return CASE; }
"default"                   { return DEFAULT; }

"show"                      { return SHOW; }
"fact"                      { return FACTORIAL; }
"min"                       { return MIN; }
"max"                       { return MAX; }
"isprime"                   { return ISPRIME; }
"exp"                       { return POW; }

"int"                       { return INT; }
"float"                     { return FLOAT; }
"ch"                        { return CHAR; }
"array"                     { return ARRAY; }
"func"                      { return FUNCTION; }

"##"                        { comment_line = yylloc.first_line; BEGIN(COMMENT); }
<COMMENT>"##"               { BEGIN(INITIAL); }
<COMMENT>\n                 { /* location updated by YY_USER_ACTION */ }
<COMMENT>.                  { /* comment body */ }
<COMMENT><<EOF>>            {
                                fprintf(stderr, "line %d: lexical error: unterminated comment\n", comment_line);
                                ++diagnostic_errors;
                                BEGIN(INITIAL);
                                return INVALID;
                            }
"#"[^#\n][^\n]*            { /* single-line comment */ }
"#"                         { /* empty single-line comment */ }
"connect"[ \t]+[^\n]*    { /* optional header */ }

{number}                    {
                                errno = 0;
                                long value = strtol(yytext, NULL, 10);
                                if (errno == ERANGE || value > INT_MAX) {
                                    fprintf(stderr, "line %d: lexical error: integer literal out of range\n", yylloc.first_line);
                                    ++diagnostic_errors;
                                    return INVALID;
                                }
                                yylval.val = (int)value;
                                return NUMBER;
                            }
{identifier}                {
                                if ((size_t)yyleng >= sizeof(yylval.text)) {
                                    fprintf(stderr, "line %d: lexical error: identifier exceeds 127 characters\n", yylloc.first_line);
                                    ++diagnostic_errors;
                                    return INVALID;
                                }
                                memcpy(yylval.text, yytext, (size_t)yyleng + 1);
                                return VAR;
                            }

[ \t\r\n]+                 { /* whitespace */ }
"="                         { return '='; }
[(),:;<>]                   { return yytext[0]; }

.                           {
                                fprintf(stderr, "line %d: lexical error: unknown character: %s\n", yylloc.first_line, yytext);
                                ++diagnostic_errors;
                                return INVALID;
                            }

%%
