%{
#include "ast.h"
#include <stddef.h>
int yylex(void);
%}

%union {
    char text[128];
    int val;
    Node *node;
}

%locations
%error-verbose
%token <val> NUMBER
%token <text> VAR
%token INVALID
%token STARTPROGRAM CBS CBE SET TO
%token PLUS MINUS MUL DIV MOD LT GT LTE GTE EQUAL NOT INCREMENT DECREMENT
%token IF ELSE ELIF LOOP SWITCH CASE DEFAULT
%token SHOW FACTORIAL MIN MAX ISPRIME POW INT FLOAT CHAR ARRAY FUNCTION
%type <node> block line statement declaration variable_list assignment
%type <node> expression conditional alternative loop_statement case_list
%type <node> function_declaration parameters parameter arguments
%type <val> datatype

%left EQUAL
%left LT GT LTE GTE
%left PLUS MINUS
%left MUL DIV MOD
%right NOT
%left INCREMENT DECREMENT
%start program

%%

program
    : STARTPROGRAM block { program_root = $2; }
    ;
block
    : CBS line CBE { $$ = node_new(N_BLOCK, @1.first_line, $2, NULL, NULL, NULL); }
    ;
line
    : { $$ = NULL; }
    | line statement { $$ = node_append($1, $2); }
    ;
statement
    : ';' { $$ = NULL; }
    | declaration ';' { $$ = $1; }
    | assignment ';' { $$ = $1; }
    | expression ';' { $$ = node_new(N_EXPRESSION, @1.first_line, $1, NULL, NULL, NULL); }
    | SHOW '(' expression ')' ';' { $$ = node_new(N_SHOW, @1.first_line, $3, NULL, NULL, NULL); }
    | SHOW ':' expression ';' { $$ = node_new(N_SHOW, @1.first_line, $3, NULL, NULL, NULL); }
    | conditional { $$ = $1; }
    | block { $$ = $1; }
    | loop_statement { $$ = $1; }
    | SWITCH '(' expression ')' CBS case_list CBE
      { $$ = node_new(N_SWITCH, @1.first_line, $3, $6, NULL, NULL); }
    | function_declaration { $$ = $1; }
    | VAR '(' arguments ')' ';' { $$ = node_named(N_CALL, @1.first_line, $1, $3, NULL); }
    | ARRAY '<' datatype '>' VAR '(' NUMBER ')' ';'
      {
          $$ = node_named(N_ARRAY, @1.first_line, $5, NULL, NULL);
          $$->type = $3; $$->value = $7;
      }
    ;
declaration
    : datatype variable_list { $$ = node_type($2, $1); }
    ;
datatype
    : INT { $$ = 0; }
    | FLOAT { $$ = 1; }
    | CHAR { $$ = 2; }
    ;
variable_list
    : VAR { $$ = node_named(N_DECLARE, @1.first_line, $1, NULL, NULL); }
    | variable_list ',' VAR
      { $$ = node_append($1, node_named(N_DECLARE, @3.first_line, $3, NULL, NULL)); }
    ;
assignment
    : VAR '=' expression { $$ = node_named(N_ASSIGN, @1.first_line, $1, $3, NULL); }
    | SET VAR TO expression { $$ = node_named(N_ASSIGN, @1.first_line, $2, $4, NULL); }
    ;
conditional
    : IF '(' expression ')' block alternative
      { $$ = node_new(N_IF, @1.first_line, $3, $5, $6, NULL); }
    ;
alternative
    : { $$ = NULL; }
    | ELSE block { $$ = $2; }
    | ELIF '(' expression ')' block alternative
      { $$ = node_new(N_IF, @1.first_line, $3, $5, $6, NULL); }
    ;
loop_statement
    : LOOP '(' expression ')' block
      { $$ = node_new(N_WHILE, @1.first_line, $3, $5, NULL, NULL); }
    | LOOP '(' expression ',' expression ',' expression ')' block
      { $$ = node_new(N_RANGE, @1.first_line, $3, $5, $7, $9); }
    ;
case_list
    : { $$ = NULL; }
    | case_list CASE NUMBER ':' statement
      { Node *entry = node_value(N_CASE, @2.first_line, $3);
        entry->a = $5; $$ = node_append($1, entry); }
    | case_list DEFAULT ':' statement
      { Node *entry = node_new(N_CASE, @2.first_line, $4, NULL, NULL, NULL);
        entry->op = 1; $$ = node_append($1, entry); }
    ;
function_declaration
    : FUNCTION VAR '(' parameters ')' block
      { $$ = node_named(N_FUNCTION, @1.first_line, $2, $4, $6); }
    ;
parameters
    : { $$ = NULL; }
    | parameter { $$ = $1; }
    | parameters ',' parameter { $$ = node_append($1, $3); }
    ;
parameter
    : datatype VAR { $$ = node_named(N_PARAMETER, @2.first_line, $2, NULL, NULL); $$->type = $1; }
    ;
arguments
    : { $$ = NULL; }
    | expression { $$ = $1; }
    | arguments ',' expression { $$ = node_append($1, $3); }
    ;
expression
    : NUMBER { $$ = node_value(N_NUMBER, @1.first_line, $1); }
    | VAR { $$ = node_named(N_VARIABLE, @1.first_line, $1, NULL, NULL); }
    | expression PLUS expression { $$ = node_operator(N_BINARY, @2.first_line, OP_ADD, $1, $3); }
    | expression MINUS expression { $$ = node_operator(N_BINARY, @2.first_line, OP_SUB, $1, $3); }
    | expression MUL expression { $$ = node_operator(N_BINARY, @2.first_line, OP_MUL, $1, $3); }
    | expression DIV expression { $$ = node_operator(N_BINARY, @2.first_line, OP_DIV, $1, $3); }
    | expression MOD expression { $$ = node_operator(N_BINARY, @2.first_line, OP_MOD, $1, $3); }
    | expression LT expression { $$ = node_operator(N_BINARY, @2.first_line, OP_LT, $1, $3); }
    | expression GT expression { $$ = node_operator(N_BINARY, @2.first_line, OP_GT, $1, $3); }
    | expression LTE expression { $$ = node_operator(N_BINARY, @2.first_line, OP_LTE, $1, $3); }
    | expression GTE expression { $$ = node_operator(N_BINARY, @2.first_line, OP_GTE, $1, $3); }
    | expression EQUAL expression { $$ = node_operator(N_BINARY, @2.first_line, OP_EQUAL, $1, $3); }
    | NOT expression { $$ = node_operator(N_UNARY, @1.first_line, OP_NOT, $2, NULL); }
    | expression INCREMENT { $$ = node_operator(N_UNARY, @2.first_line, OP_INCREMENT, $1, NULL); }
    | expression DECREMENT { $$ = node_operator(N_UNARY, @2.first_line, OP_DECREMENT, $1, NULL); }
    | '(' expression ')' { $$ = $2; }
    | FACTORIAL '(' expression ')' { $$ = node_operator(N_BUILTIN, @1.first_line, OP_FACT, $3, NULL); }
    | MIN '(' expression ',' expression ')' { $$ = node_operator(N_BUILTIN, @1.first_line, OP_MIN, $3, $5); }
    | MAX '(' expression ',' expression ')' { $$ = node_operator(N_BUILTIN, @1.first_line, OP_MAX, $3, $5); }
    | ISPRIME '(' expression ')' { $$ = node_operator(N_BUILTIN, @1.first_line, OP_PRIME, $3, NULL); }
    | POW '(' expression ',' expression ')' { $$ = node_operator(N_BUILTIN, @1.first_line, OP_POW, $3, $5); }
    ;
%%
