# Phased C11 implementation plan

Status: proposed; implementation awaits approval. This plan implements the
[feature specification](C11_FEATURE_SPEC.md). No compiler behavior is changed
by preparing these documents.

## Approach and phase gates

Follow the project's Aho–Ullman phase separation: lexing/preprocessing, parsing,
syntax-directed tree construction, symbol/type analysis, intermediate code,
optimization, target generation and linking. Keep each layer independently
inspectable. Use a C11 source backend first, delegating native code optimization
and machine ABI lowering to a configured C compiler.

Phases are dependency gates, not fixed-duration promises. Full C11 coverage is
a substantial compiler project; estimates should follow the P0 inventory and
backend/header feasibility work. Each phase ends with a reviewable change,
evidence and updated coverage ledger. Request approval before beginning the
initial implementation tranche and before extending into an unapproved tranche.

## P0 — Freeze the contract

Depends on: approval of this proposal. Covers every feature ID as an inventory.

Deliver: versioned grammar proposal, complete operator/declarator mapping,
legacy versus word-c11 behavior matrix, required diagnostics, clause-level
coverage ledger and recorded C11 interpretation policy. Record host/compiler
versions and a proposed macOS arm64/Linux x86-64 target matrix.

Investigate the difficult boundaries early: C header parsing, typedef-name
disambiguation, preprocessing order, target type queries and emission of C11
declarators. Specify an adapter contract for imported C tokens and macros.
Do not adopt a string-replacement translator.

Exit gate: every feature cluster has subrequirements, a phase owner and test
strategy; declaration, preprocessing and foreign-name grammar choices are
reviewable; no unresolved syntax conflict blocks P1–P3.

## P1 — Compiler infrastructure and profiles

Depends on: P0. Establishes C05/C20 and foundations for later phases.

Deliver: explicit legacy/word-c11 selection; source manager with file/line/column
spans and include/macro provenance support; structured diagnostics; independent
AST/type/symbol representations; target data model; test case metadata identifying
profile and target. Migrate existing tests to explicit legacy expectations.

Define typed IR interfaces now: typed values, lvalues/addresses, loads/stores,
blocks, terminators and source provenance. Implement lowering as features arrive.
Remove reliance on generic untyped child fields as the long-term type model.

Exit gate: existing tests retain their meaning, unsupported future syntax fails
clearly, target/compiler-host types are not conflated, and every phase can report
failure without accidentally executing source.

## P2 — Scalar types and expressions

Depends on: P1. Primarily C01–C04/C07.

Deliver: character/string and numeric literal models, integer/floating type families,
qualifiers, arithmetic conversions, constant expressions, all scalar operators,
lvalue checking, assignment expressions and correct increment/decrement.
Build typed expression lowering and independent operator tests.

Exit gate: precedence, associativity, promotions, unsigned behavior, narrowing,
short-circuit selection, constant evaluation and target-dependent limits have
positive/negative tests. Literal/identifier limits satisfy the selected profile;
the current 127-character prototype limit is not assumed adequate.

## P3 — Functions and C control flow

Depends on: P2. Primarily C05/C06/C08/C09.

Deliver: typed returns, prototypes, declaration compatibility, return analysis,
function scopes, storage/linkage foundations, while/do/for, break/continue,
labels/goto, and switch fall-through. Keep range loops as separate language sugar.
Lower control flow into explicit IR branches and blocks.

Exit gate: branch/loop/return nesting and legal/illegal jumps are tested;
function visibility follows the new profile; legacy switch/increment behavior
continues only in legacy mode. A typed non-void main can be represented.

## P4 — Pointers, arrays and object lifetimes

Depends on: P2–P3. Primarily C03/C07/C08/C10/C12/C13.

Deliver: recursive declarators, typedef resolution, addresses, dereferences,
null pointers, pointer arithmetic, array decay, multidimensional/incomplete
arrays, real array storage, strings, function pointers and allocation-compatible
pointer types. Model static/automatic/allocated lifetimes and initialization.

Exit gate: writable-lvalue checks, array parameters, pointer conversions,
one-past boundaries, alignment and sizeof are represented without executing
unevaluated operands. Tests distinguish defined programs from diagnostic-mode
checks for misuse; raw memory corruption is not a success criterion.

## P5 — Aggregates and initialization

Depends on: P4. Primarily C05/C07/C11–C13.

Deliver: struct/union/enum tags and namespaces; recursive/incomplete types;
members, bit-fields, anonymous members, flexible arrays; designated/aggregate
initialization, compound literals and aggregate copy/passing/return.

Exit gate: target layouts are compared with native C probes, including size,
alignment, padding and applicable member offsets. Do not use offsetof on
bit-fields. Union behavior, initializer diagnostics and tag visibility have
dedicated tests.

## P6 — Native C11 backend and basic driver

Depends on: P3–P5; target/IR contracts start in P1. Primarily C15/C16/C20.

Deliver: typed-IR verification, structured C emission, declarations and function
prototypes, correct C expression sequencing, main/exit behavior, generated
source maps, emit-C/check/compile/run modes, object output and host-link driver.
Implement only non-lossy optimizations initially.

Exit gate: independently authored equivalent C fixtures and word programs agree
for defined behavior. Test normal and optimized builds; generated C compiles
with C11 diagnostics enabled. End-to-end programs cover arrays, pointers,
function pointers and aggregate returns.

Keep compiler status output separate from user-program stdout. Preserve source
locations when reporting host compiler or linker failures.

## P7 — Optimization and intermediate-code validation

Depends on: P6. Develops backend behavior across C01–C20.

Deliver: inspectable IR dumps, basic blocks/control-flow graphs, type/terminator
verification, conservative constant folding, unreachable block elimination and
local redundant-operation cleanup. Add data-flow analysis before optimizations
that depend on it.

Exit gate: each pass preserves outputs and side effects on the test corpus.
Volatile/atomic accesses and sequencing are preserved. Floating-point changes
must respect the chosen floating environment; no implicit fast-math policy.
Optimization is not a prerequisite for claiming syntax support.

## P8 — Preprocessing, translation units and header interoperability

Depends on: P4–P6; P7 is independent. Primarily C01/C06/C14–C16.

Deliver: preprocessing-token model, translation phase ordering, header search,
macros and conditional directives, source mapping through expansion, multiple
translation units, tentative definitions, linkage diagnostics and native C
imports/exports. Implement an explicit bridge for parsed C header declarations
and macros; system headers often contain compiler extensions requiring a
documented target adapter.

Use a host preprocessor where its token/provenance contract is sufficient.
Preserve stringization/token-paste semantics; normalize word operators after the
relevant macro expansion stage. Imported C tokens retain their C interpretation.
In word-c11 mode, reserve # for directives/macro operations and use C-style
comments; keep today's #/## comments in legacy mode. A word-form directive
surface is additional syntax to be finalized in P0.

Exit gate: macro rescanning/stringization/pasting and variadic cases pass tests;
include guards, cross-file source locations, external globals, callbacks and
multi-object linking work. Complete a real header integration path rather than
claiming general interoperability from handwritten function declarations.

## P9 — Hosted library and C11 language facilities

Depends on: P8. Primarily C08/C13/C16/C17.

Deliver: the full mandatory hosted library ledger, typed variadic calls and
stdarg access, generic selection, static assertions, alignment/no-return
facilities, wide/Unicode handling, floating environment controls, signals,
nonlocal jumps and the remaining C11 declarator/function compatibility forms.

Exit gate: every required header family has compile/call/macro evidence or a
specific applicable conditional classification. ABI-sensitive tests include
printf-style promotions, variadic aggregate handling where applicable,
setjmp/longjmp, allocation/free, callbacks and library type layouts.

## P10 — Conditional capabilities

Depends on: P8–P9. Primarily C06/C18/C19/C21.

Deliver: VLAs and variably modified types, atomic operations/memory orders,
thread-local storage, threads, complex/conditional imaginary arithmetic and
capability reporting. Complete separate host/backend/library investigations
for Annex F/G, bounds-checking interfaces and analyzability.

Exit gate: capability macros describe our complete translation path; supported
facilities have tests and any required runtime/link dependencies. Unsupported
features are listed explicitly by target. Close all promised facilities before
labeling a target full-feature.

Never substitute volatile for atomics or a few thread demonstrations for
memory-model evidence. Concurrency tests need repeated stress checks plus
structural review of generated synchronization operations.

## P11 — Coverage audit and release

Depends on: P0–P10; a mandatory-hosted milestone can precede unpromised optional
capabilities, but it must be labeled accordingly.

Deliver: clause-by-clause coverage report, implementation-defined behavior
register, target manifests, library/ABI evidence, translated conformance tests
with provenance/licenses checked, portability CI, sanitizer checks and benchmarks.
Publish remaining exclusions and distinguish raw C acceptance from semantic
coverage in word syntax.

Exit gate: no mandatory coverage gaps for the advertised hosted profile;
every optional facility has a tested capability status; no unaccounted legacy
semantic differences; reproductions exist for regressions. Performance claims
have measured compiler flags, code and target details.

## Test and delivery policy

- Give each case a feature ID, profile, expected result/diagnostic and relevant
  target assumptions. Test both success and required rejection.
- Use expected stdout, process exit and side effects; parsing alone is insufficient.
- Compare defined behavior against equivalent C programs with at least two host
  compilers when available. Compare only allowed outcomes for unspecified behavior.
- Add stage-level tests for tokens, ASTs, type decisions, IR and generated code.
- Retain legacy fixtures; new profile migration gets explicit compatibility tests.
- Run parallel clean builds, strict compiler warnings, sanitizers and isolated
  negative tests; concurrency and ABI work add their own specialized evidence.
- Stop a phase with failing acceptance criteria rather than reporting the whole
  compiler complete because its sample ran.

## Proposed first approval

Approve P0–P1 as the first implementation tranche: freeze syntax/semantics and
establish profiles, source/type infrastructure and traceability. Review that
result before authorizing P2–P3.

The selected C11 baseline and permission to prepare documents are already
confirmed. Beginning this implementation tranche is the next approval requested.
No release dates or full-C11 completion claims are implied by this plan.
