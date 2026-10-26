#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Symbol {
    Node *declaration;
    struct Symbol *next;
} Symbol;

typedef struct Scope {
    Symbol *symbols;
    struct Scope *parent;
} Scope;

static void error(Node *node, const char *message, const char *name)
{
    fprintf(stderr, "line %d: semantic error: %s%s%s\n", node->line,
            message, name ? ": " : "", name ? name : "");
    ++diagnostic_errors;
}

static void clear_scope(Scope *scope)
{
    while (scope->symbols) {
        Symbol *next = scope->symbols->next;
        free(scope->symbols);
        scope->symbols = next;
    }
}

static Node *lookup(Scope *scope, const char *name)
{
    for (; scope; scope = scope->parent)
        for (Symbol *symbol = scope->symbols; symbol; symbol = symbol->next)
            if (strcmp(symbol->declaration->name, name) == 0)
                return symbol->declaration;
    return NULL;
}

static void declare(Scope *scope, Node *node)
{
    for (Symbol *symbol = scope->symbols; symbol; symbol = symbol->next) {
        if (strcmp(symbol->declaration->name, node->name) == 0) {
            error(node, "duplicate declaration", node->name);
            return;
        }
    }
    if (node->kind != N_FUNCTION && node->type != 0)
        error(node, "only int declarations are currently supported", node->name);
    if (node->kind == N_ARRAY && node->value <= 0)
        error(node, "array size must be positive", node->name);
    Symbol *symbol = malloc(sizeof(*symbol));
    if (!symbol) { fputs("out of memory\n", stderr); exit(EXIT_FAILURE); }
    symbol->declaration = node;
    symbol->next = scope->symbols;
    scope->symbols = symbol;
}

static void bind_scalar(Scope *scope, Node *node)
{
    node->binding = lookup(scope, node->name);
    if (!node->binding) error(node, "undeclared variable", node->name);
    else if (node->binding->kind != N_DECLARE && node->binding->kind != N_PARAMETER)
        error(node, "expected a scalar variable", node->name);
}

static void check_expression(Scope *scope, Node *node)
{
    if (!node) return;
    if (node->kind == N_VARIABLE) bind_scalar(scope, node);
    check_expression(scope, node->a);
    check_expression(scope, node->b);
}

static void check_statement(Scope *scope, Node *node);

static void check_list(Scope *scope, Node *list)
{
    for (Node *node = list; node; node = node->next)
        check_statement(scope, node);
}

static void check_statement(Scope *scope, Node *node)
{
    if (!node) return;
    switch (node->kind) {
    case N_BLOCK: {
        Scope child = {NULL, scope};
        check_list(&child, node->a);
        clear_scope(&child);
        break;
    }
    case N_DECLARE:
    case N_ARRAY:
        declare(scope, node);
        break;
    case N_ASSIGN:
        bind_scalar(scope, node);
        check_expression(scope, node->a);
        break;
    case N_SHOW:
    case N_EXPRESSION:
        check_expression(scope, node->a);
        break;
    case N_IF:
        check_expression(scope, node->a);
        check_statement(scope, node->b);
        check_statement(scope, node->c);
        break;
    case N_WHILE:
        check_expression(scope, node->a);
        check_statement(scope, node->b);
        break;
    case N_RANGE:
        check_expression(scope, node->a);
        check_expression(scope, node->b);
        check_expression(scope, node->c);
        check_statement(scope, node->d);
        break;
    case N_SWITCH:
        check_expression(scope, node->a);
        for (Node *entry = node->b; entry; entry = entry->next) {
            check_statement(scope, entry->a);
            for (Node *prior = node->b; prior != entry; prior = prior->next)
                if ((entry->op && prior->op) ||
                    (!entry->op && !prior->op && entry->value == prior->value))
                    error(entry, "duplicate switch case or default", NULL);
        }
        break;
    case N_FUNCTION:
        error(node, "functions must be declared at program scope", node->name);
        break;
    case N_CALL: {
        node->binding = lookup(scope, node->name);
        if (!node->binding || node->binding->kind != N_FUNCTION) {
            error(node, "undefined function", node->name);
            break;
        }
        Node *parameter = node->binding->a;
        Node *argument = node->a;
        for (Node *arg = argument; arg; arg = arg->next) check_expression(scope, arg);
        while (parameter && argument) {
            parameter = parameter->next;
            argument = argument->next;
        }
        if (parameter || argument) error(node, "wrong number of function arguments", node->name);
        break;
    }
    default:
        error(node, "invalid statement node", NULL);
        break;
    }
}

int semantic_check(Node *program)
{
    Scope global = {NULL, NULL};
    /* Register top-level functions before checking calls (including recursion). */
    for (Node *node = program->a; node; node = node->next)
        if (node->kind == N_FUNCTION) declare(&global, node);
    for (Node *node = program->a; node; node = node->next)
        if (node->kind != N_FUNCTION) check_statement(&global, node);
    for (Node *node = program->a; node; node = node->next) {
        if (node->kind != N_FUNCTION) continue;
        Scope function = {NULL, &global};
        for (Node *parameter = node->a; parameter; parameter = parameter->next)
            declare(&function, parameter);
        check_list(&function, node->b->a);
        clear_scope(&function);
    }
    clear_scope(&global);
    return diagnostic_errors == 0;
}
