#include "ast.h"
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct Value {
    Node *declaration;
    int value;
    struct Value *next;
} Value;

typedef struct Frame {
    Value *values;
    struct Frame *parent;
} Frame;

static Frame *globals;
static int failed;
static unsigned call_depth;

static void runtime_error(Node *node, const char *message)
{
    if (!failed)
        fprintf(stderr, "line %d: runtime error: %s\n", node->line, message);
    failed = 1;
}

static void clear_frame(Frame *frame)
{
    while (frame->values) {
        Value *next = frame->values->next;
        free(frame->values);
        frame->values = next;
    }
}

static void add_value(Frame *frame, Node *declaration, int value)
{
    Value *entry = malloc(sizeof(*entry));
    if (!entry) { runtime_error(declaration, "out of memory"); return; }
    entry->declaration = declaration;
    entry->value = value;
    entry->next = frame->values;
    frame->values = entry;
}

static Value *find_value(Frame *frame, Node *node)
{
    for (; frame; frame = frame->parent)
        for (Value *entry = frame->values; entry; entry = entry->next)
            if (entry->declaration == node->binding) return entry;
    runtime_error(node, "variable accessed before its declaration executed");
    return NULL;
}

static int checked(Node *node, int64_t value)
{
    if (value < INT_MIN || value > INT_MAX) {
        runtime_error(node, "integer overflow");
        return 0;
    }
    return (int)value;
}

static int evaluate(Frame *frame, Node *node)
{
    if (failed) return 0;
    if (node->kind == N_NUMBER) return node->value;
    if (node->kind == N_VARIABLE) {
        Value *entry = find_value(frame, node);
        return entry ? entry->value : 0;
    }
    int a = evaluate(frame, node->a);
    int b = node->b ? evaluate(frame, node->b) : 0;
    if (failed) return 0;
    switch (node->op) {
    case OP_ADD: return checked(node, (int64_t)a + b);
    case OP_SUB: return checked(node, (int64_t)a - b);
    case OP_MUL: return checked(node, (int64_t)a * b);
    case OP_DIV:
    case OP_MOD:
        if (!b) { runtime_error(node, node->op == OP_DIV ? "division by zero" : "modulo by zero"); return 0; }
        if (a == INT_MIN && b == -1) {
            if (node->op == OP_MOD) return 0;
            runtime_error(node, "integer overflow"); return 0;
        }
        return node->op == OP_DIV ? a / b : a % b;
    case OP_LT: return a < b;
    case OP_GT: return a > b;
    case OP_LTE: return a <= b;
    case OP_GTE: return a >= b;
    case OP_EQUAL: return a == b;
    case OP_NOT: return !a;
    case OP_INCREMENT: return checked(node, (int64_t)a + 1);
    case OP_DECREMENT: return checked(node, (int64_t)a - 1);
    case OP_MIN: return a < b ? a : b;
    case OP_MAX: return a > b ? a : b;
    case OP_PRIME:
        if (a < 2) return 0;
        for (int i = 2; i <= a / i; ++i) if (a % i == 0) return 0;
        return 1;
    case OP_FACT: {
        if (a < 0 || a > 12) {
            runtime_error(node, "factorial requires an integer from 0 to 12"); return 0;
        }
        int result = 1;
        for (int i = 2; i <= a; ++i) result = checked(node, (int64_t)result * i);
        return result;
    }
    case OP_POW: {
        if (b < 0) { runtime_error(node, "integer exponent must be nonnegative"); return 0; }
        int result = 1;
        while (b && !failed) {
            if (b % 2) result = checked(node, (int64_t)result * a);
            b /= 2;
            if (b) a = checked(node, (int64_t)a * a);
        }
        return result;
    }
    default: runtime_error(node, "invalid expression"); return 0;
    }
}

static void execute(Frame *frame, Node *node);

static void execute_list(Frame *frame, Node *list)
{
    for (Node *node = list; node && !failed; node = node->next) execute(frame, node);
}

static void execute(Frame *frame, Node *node)
{
    if (!node || failed) return;
    switch (node->kind) {
    case N_BLOCK: {
        Frame block = {NULL, frame};
        execute_list(&block, node->a);
        clear_frame(&block);
        break;
    }
    case N_DECLARE:
        add_value(frame, node, 0);
        break;
    case N_ASSIGN: {
        int result = evaluate(frame, node->a);
        if (failed) break;
        Value *entry = find_value(frame, node);
        if (entry) entry->value = result;
        break;
    }
    case N_SHOW: {
        int value = evaluate(frame, node->a);
        if (!failed) printf("show: %d\n", value);
        break;
    }
    case N_EXPRESSION:
        (void)evaluate(frame, node->a);
        break;
    case N_IF: {
        int condition = evaluate(frame, node->a);
        if (!failed) execute(frame, condition ? node->b : node->c);
        break;
    }
    case N_WHILE:
        while (!failed && evaluate(frame, node->a)) execute(frame, node->b);
        break;
    case N_RANGE: {
        int start = evaluate(frame, node->a);
        int end = evaluate(frame, node->b);
        int step = evaluate(frame, node->c);
        if (failed) break;
        if (step <= 0) { runtime_error(node, "loop step must be positive"); break; }
        /* Half-open range; descending direction is inferred from the bounds. */
        for (int64_t i = start; !failed && (start <= end ? i < end : i > end);
             i += start <= end ? (int64_t)step : -(int64_t)step)
            execute(frame, node->d);
        break;
    }
    case N_SWITCH: {
        int selector = evaluate(frame, node->a);
        Node *selected = NULL, *fallback = NULL;
        for (Node *entry = node->b; entry; entry = entry->next) {
            if (entry->op) fallback = entry;
            else if (entry->value == selector) selected = entry;
        }
        if (!selected) selected = fallback;
        if (selected && !failed) execute(frame, selected->a);
        break;
    }
    case N_CALL: {
        if (call_depth >= 256) { runtime_error(node, "function call depth exceeded"); break; }
        Node *function = node->binding;
        Frame activation = {NULL, globals};
        Node *parameter = function->a;
        for (Node *argument = node->a; argument && !failed; argument = argument->next) {
            int value = evaluate(frame, argument);
            if (!failed) add_value(&activation, parameter, value);
            parameter = parameter->next;
        }
        ++call_depth;
        if (!failed) execute_list(&activation, function->b->a);
        --call_depth;
        clear_frame(&activation);
        break;
    }
    case N_FUNCTION:
    case N_ARRAY:
        /* Definitions have no executable body; arrays have no element operations yet. */
        break;
    default:
        runtime_error(node, "invalid statement");
        break;
    }
}

int execute_program(Node *program)
{
    Frame global = {NULL, NULL};
    globals = &global;
    failed = 0;
    call_depth = 0;
    execute_list(&global, program->a);
    clear_frame(&global);
    globals = NULL;
    return !failed;
}
