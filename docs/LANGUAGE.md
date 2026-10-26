# Language guide

## Program and values

```text
initializing program :
begin-
    int a, b;
    set a to 5;
    set b to a add 2;
    show(b);
-end
```

Integers default to zero. Names use letters, digits, and underscores, start
with a letter or underscore, and contain at most 127 characters. Keywords
are case-sensitive. An optional `connect name` header is ignored.
Statements usually end with `;`; blocks and function definitions do not.
The program marker also accepts `initializing program` without the colon.

Comments use `#` to end of line or `## ... ##` across lines.
Block comments do not nest.

## Operators

| Precedence, low to high | Operators | Meaning |
| --- | --- | --- |
| 1 | `equal` | Equality, yielding 0 or 1 |
| 2 | `lt`, `gt`, `lte`, `gte` | Integer comparisons, yielding 0 or 1 |
| 3 | `add`, `sub` | Addition and subtraction |
| 4 | `mul`, `div`, `mod` | Multiplication, truncating integer division, remainder |
| 5 | `not` | Prefix logical negation |
| 6 | `increment`, `decrement` | Postfix value plus/minus one |

Binary operators associate left to right. Parentheses override precedence.
`not (a equal b)` expresses inequality. A negative value can be written
`0 sub value`. Postfix increment/decrement compute a value without assigning
it; write `set a to a increment;` to update a variable.

Assignment uses `set name to expression;`. The compatibility form
`name = expression;` is also accepted. Symbolic arithmetic/comparison operators
such as `+`, `*`, and `!` are not accepted.

`show(expression);` and `show : expression;` both print `show: value`.

## Branches and loops

```text
when (a lt b)
begin-
    show(a);
-end
eor (a equal b)
begin-
    show(0);
-end
or
begin-
    show(b);
-end
```

Zero is false; other integers are true. Only one selected branch executes.
There can be any number of `eor` branches and an optional final `or`.
Each block has local scope.

`loop(condition) begin- ... -end` reevaluates the condition before every
iteration. The body must change the relevant variables if termination depends
on them; for example:

```text
int i;
loop(i lt 3)
begin-
    show(i);
    set i to i add 1;
-end
```

`loop(start, end, step) begin- ... -end` evaluates its bounds and positive
step once. The end is exclusive. Direction is inferred from the bounds:
`loop(1, 4, 1)` runs three times, as does `loop(4, 1, 1)`.
Equal bounds run zero times. This form supplies a repetition count and does not
expose an implicit counter variable.

## Functions

```text
func product(int left, int right)
begin-
    int result;
    set result to left mul right;
    show(result);
-end
product(6, 7);
```

Functions are declared at program scope and called as statements. Arguments are
integers passed by value, left to right. Functions have local frames and can
recurse; the current call-depth limit is 256. They may access global variables
whose declarations have executed before the call. Function definitions may
appear after their calls. Return values and nested definitions are not supported.

## Switch

```text
switch(a)
begin-
    case 0: show(10);
    case 1: begin- show(20); show(21); -end
    default: show(99);
-end
```

Case labels are nonnegative integer literals. Only the matching case executes;
otherwise the optional default executes. There is no fall-through. A case body
is one statement or a block. Duplicate cases/defaults are semantic errors.

## Built-ins and errors

`fact(n)`, `min(a, b)`, `max(a, b)`, `isprime(n)`, and `exp(a, b)`
are expressions. Factorial accepts 0 through 12. Integer power requires a
nonnegative exponent, uses checked integer arithmetic, and defines `exp(0, 0)`
as 1. Primality returns false for values below 2.

The current value range is the C implementation's `int` range. Out-of-range
literals, overlong names, syntax errors, undeclared variables, invalid function
arguments, and duplicate declarations fail with source-line diagnostics.
All static checks complete before execution. Runtime arithmetic errors stop
execution and return exit status 1; earlier output is retained.

`float` and `ch` declarations are recognized but rejected until implemented.
`array <int> name(size);` records a positive-size array declaration; element
storage/access is not implemented, and arrays cannot be used as scalar values.
