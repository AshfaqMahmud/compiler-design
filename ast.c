#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static Node *allocations;
Node *program_root;
int diagnostic_errors;

Node *node_new(NodeKind kind, int line, Node *a, Node *b, Node *c, Node *d)
{
    Node *node = calloc(1, sizeof(*node));
    if (!node) {
        fputs("out of memory\n", stderr);
        exit(EXIT_FAILURE);
    }
    node->kind = kind;
    node->line = line;
    node->a = a; node->b = b; node->c = c; node->d = d;
    node->allocation_next = allocations;
    allocations = node;
    return node;
}

Node *node_named(NodeKind kind, int line, const char *name, Node *a, Node *b)
{
    Node *node = node_new(kind, line, a, b, NULL, NULL);
    snprintf(node->name, sizeof(node->name), "%s", name);
    return node;
}

Node *node_value(NodeKind kind, int line, int value)
{
    Node *node = node_new(kind, line, NULL, NULL, NULL, NULL);
    node->value = value;
    return node;
}

Node *node_operator(NodeKind kind, int line, int op, Node *a, Node *b)
{
    Node *node = node_new(kind, line, a, b, NULL, NULL);
    node->op = op;
    return node;
}

Node *node_append(Node *list, Node *item)
{
    if (!list) return item;
    Node *tail = list;
    while (tail->next) tail = tail->next;
    tail->next = item;
    return list;
}

Node *node_type(Node *list, int type)
{
    for (Node *node = list; node; node = node->next) node->type = type;
    return list;
}

void ast_free(void)
{
    while (allocations) {
        Node *next = allocations->allocation_next;
        free(allocations);
        allocations = next;
    }
    program_root = NULL;
}
