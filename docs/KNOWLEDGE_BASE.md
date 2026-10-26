# Project knowledge base

## Purpose

Build a small language with word operators inspired by assembly mnemonics:
`add`, `sub`, `mul`, `div`, `lt`, `gt`, `lte`, `gte`, `equal`, and `not`.
The longer-term goal is a target for natural-language translation with native
execution. Natural-language translation and native code generation are not
implemented yet.

The current executable is an AST interpreter with separate compiler front-end
phases. It follows the architecture described in [compiler design](COMPILER_DESIGN.md).
The supported syntax and runtime behavior are in the [language guide](LANGUAGE.md).

The proposed expansion to C11 capabilities is specified in the
[C11 feature specification](C11_FEATURE_SPEC.md) and
[phased implementation plan](C11_IMPLEMENTATION_PLAN.md).
The C11 baseline is selected; the proposed syntax, migration policy and
implementation tranche still await approval.

## Source map

| File | Responsibility |
| --- | --- |
| `main.l` | Flex lexical rules, token values, source locations, lexical errors |
| `main.y` | Bison grammar and syntax-directed AST construction |
| `ast.h`, `ast.c` | Tree representation, constructors, allocation lifetime |
| `semantic.c` | Scoped symbol tables, binding, static validation |
| `runtime.c` | Evaluation, control flow, call frames, checked arithmetic |
| `driver.c` | Parse/check/execute orchestration, diagnostics, exit status |
| `Makefile` | Generation, compilation, execution, test entry point |
| `input.txt` | Example program |
| `tests/` | Expected-output fixtures and pipeline regression tests |

Generated lexer/parser files and executables are ignored by Git. Edit source
files and regenerate them through Make.

## Build and verification

Dependencies: Flex, Bison, a C11 compiler, Make, and Python 3 for tests.
The lexer supplies its own EOF handling; linking `libfl` is unnecessary.

```sh
make
make run
./compiler tests/behavior.txt
make test
make clean
```

The executable uses `input.txt` if no path is supplied. The success message is
printed only after parsing, semantic checks, and execution all succeed.
Errors go to stderr and return exit status 1.

Tests verify the original execution failures, arithmetic precedence,
conditional selection, nested loops, fresh block scopes, recursive function
frames, switch selection, lexical/syntax/semantic errors, and runtime failures.
Expected-output tests check values and side effects, rather than merely
checking that the grammar accepts input.

## Current limits and next stages

- The value type is C `int`. `float` and `ch` are recognized but rejected
  during semantic analysis until real type support exists.
- Arrays support declaration metadata and size validation only. Element
  storage, reads, and writes remain to be implemented; an array cannot be
  used as a scalar.
- Functions have integer arguments and statement bodies. Return values and
  nested function definitions are not implemented.
- Punctuation remains for grouping, separators, and block markers; this is
  a language with word operators, not a punctuation-free language.
- Execution uses a tree interpreter; no native-performance claim is made.
- The next backend stages are a typed intermediate representation,
  control-flow lowering, optimization, and native or C target generation.

## Contribution rules

- Keep execution and symbol mutations out of lexer/parser actions.
- Update the language guide when syntax or semantics change.
- Add expected-output and error tests for changed behavior.
- Keep phase-specific errors observable through a nonzero exit status.
- Regenerate parser/lexer files locally; commit their source specifications.
- Keep current behavior separate from planned compiler stages in documentation.
