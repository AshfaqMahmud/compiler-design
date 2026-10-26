# C11 feature specification

Status: proposed specification for approval. C11 is the selected baseline.
The syntax, compatibility policy, and implementation choices below are proposals.
This document does not mark any new compiler feature as implemented.

## 1. Product contract

Provide C11's programming capabilities through the project's word-based language,
then generate native executables through a C11 backend. Keep operators such as
`add`, `sub`, `lt`, and `equal`, and readable assignment such as
`set count to 10;`.

Target ISO/IEC 9899:2011. Use the public WG14
[N1570 committee draft](https://open-std.org/JTC1/SC22/WG14/www/docs/n1570.pdf)
as the clause-level engineering reference; it is a draft, not the published ISO
edition. Track the 2012 technical corrigendum and later relevant defect resolutions
in a versioned interpretation register rather than silently adopting C17/C23 rules.
[WG14's revision register](https://www.open-std.org/jtc1/sc22/wg14/www/projects.html)
identifies the C11 publication and related materials.

The deliverable is a language with C11 semantic coverage and C ABI interoperability.
Changing keywords and reserving additional operator words means its source syntax
is not ISO C. Accepting arbitrary unmodified C source in our own front end is a
separate compatibility project; ordinary C files may initially be compiled by the
host compiler for linking. Generated C must satisfy the selected C11 target profile.
Do not advertise an ISO C implementation solely because generated code builds.

The complete feature goal includes the conditional facilities below. Mandatory
hosted coverage and optional capabilities receive separate completion gates;
an unavailable host facility remains an explicit gap in the full-feature goal.

## 2. Proposed execution and compatibility policy

- Default future profile: `word-c11`, following C11 semantics with word syntax.
- Preserve today's behavior under an explicit `legacy` profile during migration.
  Do not silently change existing programs or classify legacy behavior as C11.
- Initial native target: the build host's ABI and supported C11 compiler/library.
  Validate macOS arm64 and Linux x86-64 as separate target profiles before claiming
  support for either; cross-compilation and Windows are later target additions.
- Emit C11 source and invoke a configured host compiler for object generation,
  native optimization, assembly, and linking. Record compiler, libc, flags,
  include paths, ABI, and capability probes in the target manifest.
- Host libraries supply library implementations. Our front end still owns correct
  declarations, types, expression semantics, preprocessing integration, and diagnostics.
- Keep the AST interpreter as a regression oracle for its supported subset.
  Full C11 execution need not be duplicated in the interpreter.

Proposed future commands: `--profile word-c11|legacy`, `--check`, `--emit-c`,
`--emit-ir`, `-c`, `-o`, and `--run`. These flags do not exist yet.

## 3. Language coverage ledger

Every ID must gain individual subrequirements, positive/negative tests, relevant
N1570 clauses, implementation location, and target evidence during its phase.
The phase labels refer to the [implementation plan](C11_IMPLEMENTATION_PLAN.md).
All rows currently mean planned or partial prototype behavior, not C11 completion.

| ID | Required coverage | Primary phase / reference |
| --- | --- | --- |
| C01 | Source/execution character sets; universal character names; integer bases and suffixes; decimal/hex floating constants; character, string, wide and Unicode literals; escapes; adjacent strings; comments; C-token trigraph/digraph handling; translation limits | P2, P8 / 5.2, 6.4 |
| C02 | Signed/unsigned integer families, plain/signed/unsigned char, short/long/long long, Boolean, real floating families, void, implementation-supported extended types | P2 / 6.2.5, 6.7.2 |
| C03 | Integer promotions, usual arithmetic conversions, scalar/Boolean conversion, pointer conversions, casts, constant expressions, literal typing | P2, P4 / 6.3, 6.6 |
| C04 | Every unary, binary, postfix, assignment, conditional and comma operation; precedence, associativity, lvalues and side effects; short-circuit and sequencing | P2–P4 / 6.5 |
| C05 | File/block/function/prototype scopes; ordinary/tag/member/label namespaces; compatible/composite types; declaration visibility and redeclaration rules | P1, P3, P5 / 6.2, 6.7 |
| C06 | Automatic, static, allocated and thread storage duration; internal/external/no linkage; extern/static/auto/register; tentative definitions; initialization and object lifetime | P3, P4, P8, P10 / 6.2.2–4, 6.7, 6.9 |
| C07 | Full recursive declarators/type names; typedef; const/volatile/restrict; inline; anonymous or named declarator components; qualifier constraints | P2–P5, P9 / 6.7 |
| C08 | Typed functions, prototypes, void parameters, return values, recursion, function pointers, variadic calls, default argument promotions, compatible declarations, C11's still-permitted old-style forms | P3, P4, P9 / 6.7.6.3, 6.9.1 |
| C09 | if/else, while, do/while, for, switch with fall-through, case/default labels, break/continue, return, goto, labels, compound/null/expression statements | P3 / 6.8 |
| C10 | Pointer values, address/dereference, pointer arithmetic/difference, null pointers, arrays and decay, multidimensional/incomplete arrays, array parameters, bounds/lifetime rules | P4 / 6.3, 6.5, 6.7.6 |
| C11 | Structures, unions, enums, member access, bit-fields, anonymous members, flexible array members, incomplete tags and self-reference | P5 / 6.7.2 |
| C12 | Scalar/aggregate initialization, designated initializers, compound literals, brace elision, storage-dependent initialization, aggregate assignment/passing/return | P4, P5 / 6.5.2.5, 6.7.9 |
| C13 | sizeof including unevaluated operands and VLA exceptions; object layout/alignment, padding, offsetof, explicit alignment | P4, P5, P9, P10 / 6.2.6–8, 6.5.3.4, 6.7.5 |
| C14 | Translation phases, tokenization, header inclusion, object/function/variadic macros, rescanning, stringization/pasting, conditional preprocessing, line/error/pragma/null directives, predefined macros, _Pragma | P8 / 5.1.1.2, 6.10 |
| C15 | Multiple translation units, separate compilation, compatible external declarations, host ABI layouts/calls, native C imports/exports and linking | P6, P8 / 5.1, 6.2.2, 6.9 |
| C16 | Hosted entry/exit, arguments and environment, all standard library header families, variadic APIs, allocation and I/O interoperability | P6, P8, P9 / 5.1.2.2, clause 7 |
| C17 | _Generic, _Static_assert, _Alignas/_Alignof, _Noreturn, associated headers and constraints; generic associations must not evaluate unselected operands | P9 / 6.5.1.1, 6.7 |
| C18 | Atomic objects/operations, fences and ordering, threads/mutexes/conditions, thread-local storage and the C11 memory model | P10 / 5.1.2.4, 6.7, 7.17, 7.26 |
| C19 | VLAs/variably modified types, complex arithmetic, conditional imaginary support, floating-point environment and Annex F/G capabilities | P10 / 6.7.6, 7.3, 7.6, annexes F/G |
| C20 | Required diagnostics, reserved identifiers, documented implementation-defined choices, minimum limits, unspecified/undefined behavior policy | Every phase, P11 audit / clauses 4–6, annex J |
| C21 | Bounds-checking interfaces and analyzability as separately advertised extensions; no simulated compliance when the host lacks them | P10 / annexes K/L |

Obsolescent C11 constructs remain in the coverage ledger. Extensions outside C11
(C++ features, GNU statement expressions, C23 features, inline assembly, POSIX-only
APIs) require separate extension records and are not counted as C11 requirements.

## 4. Word syntax proposal

Exact grammar is frozen in P0. These spellings are a reviewable starting point;
they preserve C11 operation semantics rather than performing text replacement.

| C operation | Proposed source spelling |
| --- | --- |
| Arithmetic +, -, *, /, % | `add`, `sub`, `mul`, `div`, `mod` |
| Unary + / - | `positive` / `negative` |
| <, >, <=, >=, ==, != | `lt`, `gt`, `lte`, `gte`, `equal`, `not_equal` |
| !, &&, logical OR | `not`, `logical_and`, `logical_or` |
| ~, &, bitwise OR, ^ | `bit_not`, `bit_and`, `bit_or`, `bit_xor` |
| <<, >> | `shift_left`, `shift_right` |
| Assignment expression = | Infix `assign`; `set target to value;` remains statement sugar |
| Compound assignments | `add_assign`, `sub_assign`, `mul_assign`, `div_assign`, `mod_assign`, `and_assign`, `or_assign`, `xor_assign`, `shift_left_assign`, `shift_right_assign` |
| Prefix/postfix ++ / -- | Prefix/postfix `increment` / `decrement`, with actual lvalue updates |
| Address and indirection | `address_of(value)`, `deref(pointer)` |
| Array and members | `array[index]`, `object member field`, `pointer ptr_member field` |
| Cast / sizeof / alignment | `cast(type, value)`, `sizeof(...)`, `alignof(type)` |
| Conditional ?: | Special form `select(condition, true_value, false_value)` |
| Sequenced comma expression | Infix `then_eval`; ordinary commas still separate arguments |

Compound assignments must evaluate their target once. Logical operations and
`select` evaluate only the required operands. C11 precedence and associativity
apply after normalization. `or` remains the existing else spelling;
`logical_or` avoids giving it two meanings.

Parentheses, brackets, commas, semicolons, quotes, and current block markers
remain available. Readable declaration constructors for pointers, arrays and
function types must cover every recursive C declarator shape without requiring
operator signs. Their exact spelling is a P0 grammar deliverable.

Illustrative future source, not executable today:

```text
func sum(int left, int right) returns int
begin-
    return left add right;
-end

func main(void) returns int
begin-
    int answer;
    set answer to sum(20, 22);
    return answer sub 42;
-end
```

Operator words reserve additional identifiers in word source. Provide a quoted
external-name mechanism so C symbols with those spellings remain importable.
The C header input path must preserve C identifiers instead of blindly treating
each `add` or `not` as an operator.

## 5. Required semantic migration

| Prototype behavior | Proposed word-c11 behavior |
| --- | --- |
| Local integers automatically zeroed | C11 storage-duration initialization rules; no implicit zero for ordinary uninitialized automatic objects |
| Switch implicitly stops after selected case | C11 label/fall-through semantics; explicit break |
| Postfix increment computes a value only | Mutates a modifiable lvalue and yields its previous value |
| Functions registered automatically before all calls | Declaration/prototype visibility follows C11; provide prototypes for forward calls |
| No return values; arguments evaluated left to right | Typed returns/calls and C11 sequencing guarantees; do not promise an argument evaluation order |
| Always trap signed arithmetic overflow | C11 behavior in normal mode; checked arithmetic available as an explicitly documented diagnostic mode |
| Script-style wrapper and ignored connect header | Explicit translation units and hosted main; preserve script wrapper as legacy/convenience lowering |
| Fixed 256-call interpreter limit | Native target resource/translation limits documented independently; no language-wide fixed recursion cap |
| All integer operations use compiler host int | Target-specific type model, conversions, layouts and constant evaluation |

Legacy tests must continue to assert legacy behavior. New C11 tests must never
use undefined behavior as a deterministic output oracle. Unspecified behavior
tests check permitted outcomes; implementation-defined behavior uses the recorded
target manifest. Static constraints receive diagnostics; detecting every runtime
undefined behavior is not promised.

Existing `fact`, `min`, `max`, `isprime`, `show`, and integer `exp` remain
language extensions, with separate name resolution from native library symbols.
In particular, integer `exp(a,b)` must not shadow the C math library's `exp(x)`.

## 6. Library and conditional-feature inventory

Integrate and test host library facilities rather than rebuilding libc.
Each header below needs a declaration/macro bridge and relevant call tests,
including ABI-sensitive types and callbacks. Merely emitting an include is not
sufficient evidence of support.

| Library area | Headers to cover | Main phases |
| --- | --- | --- |
| Assertions, errors, limits, integer formats and common types | assert.h, errno.h, limits.h, float.h, stdint.h, inttypes.h, stddef.h, stdbool.h, iso646.h | P8–P9 |
| I/O, allocation/utilities, strings | stdio.h, stdlib.h, string.h | P8–P9 |
| Classification, locale, time, Unicode/wide characters | ctype.h, locale.h, time.h, uchar.h, wchar.h, wctype.h | P9 |
| Mathematics and floating environment | math.h, fenv.h, tgmath.h, complex.h | P9–P10 |
| Control transfer, signals and variadic APIs | setjmp.h, signal.h, stdarg.h | P9 |
| Alignment and no-return declarations | stdalign.h, stdnoreturn.h | P9 |
| Atomics and threads | stdatomic.h, threads.h | P10 |

Track each conditional capability per target, including what the front end can
express, what the backend implements, and what the host library supplies.

| Capability | Goal and availability contract |
| --- | --- |
| VLAs and variably modified types | Implement where supported; report absence with the corresponding C11 feature mechanism |
| Atomic types/operations | Preserve memory orders; probe library/linker requirements; do not equate availability with lock-freedom |
| C11 threads | Test the actual threads.h contract; a POSIX-only wrapper is not automatically equivalent |
| Complex/imaginary arithmetic | Record exact available type families and Annex G level |
| Annex F floating behavior | Require verified backend flags, environment and library behavior before advertising |
| Annex K bounds-checking interfaces | Use a verified implementation or explicitly report unavailable |
| Annex L analyzability | Separate implementation and evidence gate; checked arithmetic alone does not establish it |

Do not forward host support macros unchanged when our front end cannot support
the corresponding feature. A target missing any requested optional capability
must not be presented as having fulfilled the full-feature goal.

## 7. Completion criteria

A feature is complete only when grammar, semantic rules, lowering, native
behavior, diagnostics, tests and documentation agree. Keep an auditable ledger
for the individual clauses under each C ID, including conditional exclusions.

Before a hosted-coverage release: audit mandatory clauses and required library
coverage, publish target limits/ABI choices, verify separate compilation, run
defined-behavior differential tests against C11 compilers, and retain negative
diagnostic tests. Before a full-feature release: additionally close every
conditional capability promised for that release's target profiles.

Native execution does not itself prove C-like performance. Benchmark matched
algorithms, equivalent types, optimization flags and target hardware; report
the measurements and emitted code before making speed claims.
