# Compiler-design

This project explores a custom programming language implemented with
[Flex](https://github.com/westes/flex) and
[Bison](https://www.gnu.org/software/bison/). The language experiments with
readable operator names and syntax inspired by C++, Java, SQL, and 8086
assembly.

The language favors words such as `add`, `sub`, `lt`, `equal`, and
`set name to value` over operator signs. Its longer-term goal is to support
translation from natural language into programs with native execution.

The current implementation is an educational front end and AST interpreter:
lexing, parsing, semantic analysis, then execution. Its design follows the
phase separation, syntax-directed translation, symbol-table, and runtime-storage
ideas in Aho and Ullman's *Principles of Compiler Design* (1977).
Native code generation and optimization are future stages.

## Build and test

Install Flex, Bison, a C11 compiler, and Make. Python 3 is needed for tests.

```sh
make
./compiler input.txt
make test
```

## Documentation

See the [project knowledge base](docs/KNOWLEDGE_BASE.md) for the architecture,
language notes, build workflow, known limitations, and contribution guidance.
See also the [language guide](docs/LANGUAGE.md) and
[compiler design](docs/COMPILER_DESIGN.md).

The proposed C11 expansion is documented in the
[feature specification](docs/C11_FEATURE_SPEC.md) and
[phased implementation plan](docs/C11_IMPLEMENTATION_PLAN.md).
These proposals await implementation approval; the language guide describes
what works today.
