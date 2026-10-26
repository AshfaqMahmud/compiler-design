#ifndef AST_H
#define AST_H

typedef enum {
    N_BLOCK, N_NUMBER, N_VARIABLE, N_BINARY, N_UNARY, N_BUILTIN,
    N_DECLARE, N_ARRAY, N_PARAMETER, N_ASSIGN, N_SHOW, N_EXPRESSION,
    N_IF, N_WHILE, N_RANGE, N_SWITCH, N_CASE, N_FUNCTION, N_CALL
} NodeKind;

typedef enum {
    OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_MOD, OP_LT, OP_GT, OP_LTE,
    OP_GTE, OP_EQUAL, OP_NOT, OP_INCREMENT, OP_DECREMENT,
    OP_FACT, OP_MIN, OP_MAX, OP_PRIME, OP_POW
} Operator;

typedef struct Node Node;
struct Node {
    NodeKind kind;
    int line, value, op, type;
    char name[128];
    Node *a, *b, *c, *d, *next;
    Node *binding; /* Declaration resolved by semantic analysis. */
    Node *allocation_next;
};

Node *node_new(NodeKind kind, int line, Node *a, Node *b, Node *c, Node *d);
Node *node_named(NodeKind kind, int line, const char *name, Node *a, Node *b);
Node *node_value(NodeKind kind, int line, int value);
Node *node_operator(NodeKind kind, int line, int op, Node *a, Node *b);
Node *node_append(Node *list, Node *item);
Node *node_type(Node *list, int type);
void ast_free(void);
int semantic_check(Node *program);
int execute_program(Node *program);

extern Node *program_root;
extern int diagnostic_errors;
int yyerror(const char *message);

#endif
