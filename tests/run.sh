#!/bin/sh
# Run from the repository root: sh tests/run.sh
set -u

make || exit 1
test_dir=$(mktemp -d) || exit 1
trap 'rm -f "$test_dir/stdout" "$test_dir/stderr"; rmdir "$test_dir"' EXIT HUP INT TERM
failures=0

./compiler tests/behavior.txt > "$test_dir/stdout" 2> "$test_dir/stderr"
result=$?
printf '\nBehavior test (expected versus actual):\n'
if [ "$result" -eq 0 ] && diff -u tests/behavior.expected "$test_dir/stdout" && [ ! -s "$test_dir/stderr" ]; then
    printf 'PASS: behavior\n'
else
    printf 'FAIL: behavior (exit %s)\n' "$result"
    cat "$test_dir/stderr"
    failures=$((failures + 1))
fi

for source in tests/division_by_zero.txt tests/undeclared_variable.txt; do
    ./compiler "$source" > "$test_dir/stdout" 2> "$test_dir/stderr"
    result=$?
    if [ "$result" -eq 1 ] && [ -s "$test_dir/stderr" ] && ! grep -q 'Successful compilation' "$test_dir/stdout"; then
        printf 'PASS: %s rejects invalid program\n' "$source"
    else
        printf 'FAIL: %s (expected rejection, got exit %s)\n' "$source" "$result"
        cat "$test_dir/stdout" "$test_dir/stderr"
        failures=$((failures + 1))
    fi
done

printf '\n%s of 3 test groups failed.\n' "$failures"
python3 tests/test_pipeline.py || failures=$((failures + 1))
[ "$failures" -eq 0 ]
