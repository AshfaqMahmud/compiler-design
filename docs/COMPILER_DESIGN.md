# Compiler architecture

## Reference and scope

The guiding reference is Alfred V. Aho and Jeffrey D. Ullman,
*Principles of Compiler Design*, Addison-Wesley, 1977,
ISBN 9780201000221. The published description lists lexical analysis,
parsing, syntax-directed translation, symbol tables, runtime storage,
error handling, optimization, and code generation:
[bibliographic record and subject overview](https://books.google.com/books/about/Principles_of_Compiler_Design.html?id=25FQAAAAMAAJ).

Our module boundaries apply those principles to this project's small language.
They are implementation choices, not a claim that the textbook specifies this
language or this particular interpreter. The full textbook has not been
reproduced here. For a publicly accessible primary-source explanation of compiler
phases, see [Alfred Aho's Columbia lecture](https://www.cs.columbia.edu/~sedwards/classes/2015/4115-fall-cvn/aho.pdf).
That lecture is a later source, not the 1977 text.

## Current pipeline

```text
source
  -> lexical analysis       main.l: tokens, values, source locations
  -> syntax analysis        main.y: AST construction
  -> semantic analysis      semantic.c: scopes, names, argument checks
  -> checked AST execution  runtime.c: evaluation and activation records
```

The driver completes parsing of the entire source, including EOF, before
semantic analysis. It completes static checks before execution. This prevents
partial output from a source file that later fails syntax or semantic checks.
Runtime errors stop subsequent execution, though prior output is retained.

## Syntax-directed construction

Bison semantic values hold AST nodes instead of computed program values.
For example, an `expression add expression` production creates a binary node;
it does not perform addition. An assignment creates a node referring to its
identifier and expression. An `if` node owns its condition and branches.

This distinction fixes the original failure: reducing an unselected branch no
longer executes assignments or output. A loop body can be evaluated repeatedly,
and a function body can remain dormant until a call.

AST nodes are allocated in a per-program allocation list. The driver frees
the entire list after success or failure, including syntax errors.

## Symbol tables and semantic analysis

A linked scope chain resolves each variable reference to its declaration node.
This binding is stored in the AST, so execution does not reinterpret identifier
names. Duplicate declarations in one scope are rejected; inner blocks may
shadow outer names. Conditions and unused function bodies are checked even if
they will not execute.

Top-level function declarations are registered before checking calls. Function
bodies have parameter/local scopes and a lexical link to the program scope.
Arity and the supported integer declaration type are checked before execution.
Arrays are distinguished from scalar variables.

## Runtime storage and control flow

Each executed block has a frame for its local values. Each function call creates
an activation record containing its argument values and locals. The frame's
lexical parent is the program scope, not the caller's local scope.

Conditions evaluate one branch. While loops reevaluate their conditions.
Range loops evaluate their bounds once and run a stored body for each step.
Functions execute only on calls; recursion uses distinct frames.

Evaluation checks division/modulo by zero, integer overflow, invalid built-in
domains, invalid range steps, and excessive function call depth. These failures
return exit status 1 and suppress the success message.

## Backend development

The checked AST is currently interpreted. It is not yet machine code or
three-address code, and the project does not yet implement the complete compiler
pipeline from the book.

The next design stages are:

1. Define typed intermediate instructions and explicit labels/branches.
2. Lower expressions and control flow into that representation.
3. Form basic blocks and validate execution against the AST interpreter.
4. Add independently tested optimization passes.
5. Generate C or native target code and compare results against interpreter tests.

This preserves the user's word-based source language while allowing execution
strategy and optimization to evolve independently.
