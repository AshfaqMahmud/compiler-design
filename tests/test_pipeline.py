"""Behavioral regression tests for the language pipeline (Python standard library)."""
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parent.parent


class PipelineTests(unittest.TestCase):
    def run_source(self, body, *, complete=False):
        source = body if complete else "initializing program :\nbegin-\n" + body + "\n-end\n"
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "program.txt"
            path.write_text(source, encoding="utf-8")
            return subprocess.run(
                [str(ROOT / "compiler"), str(path)],
                text=True, capture_output=True, timeout=5,
            )

    def assert_values(self, body, values):
        result = self.run_source(body)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        expected = "".join(f"show: {value}\n" for value in values)
        self.assertEqual(result.stdout, expected + "Successful compilation.\n")

    def assert_rejected(self, body, phase, message, *, complete=False, no_output=False):
        result = self.run_source(body, complete=complete)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn(phase + " error", result.stderr)
        self.assertIn(message, result.stderr)
        self.assertRegex(result.stderr, r"line [1-9][0-9]*:")
        self.assertNotIn("Successful compilation", result.stdout)
        if no_output:
            self.assertEqual(result.stdout, "")

    def test_arithmetic_comparisons_and_precedence(self):
        self.assert_values("""
            show(2 add 3 mul 4);
            show((2 add 3) mul 4);
            show(10 sub 3 sub 2);
            show(11 div 3); show(11 mod 3);
            show(2 lt 3); show(3 gt 2); show(2 lte 2); show(2 gte 3);
            show(2 equal 2); show(not (2 equal 2));
            show(3 increment); show(3 decrement);
        """, [14, 20, 5, 3, 2, 1, 1, 1, 0, 1, 0, 4, 2])

    def test_conditional_skips_side_effects_and_errors(self):
        self.assert_values("""
            int a; set a to 7;
            when(0) begin- set a to 99; show(1 div 0); -end
            eor(1) begin- show(a); -end
            or begin- show(2 div 0); -end
            show(a);
        """, [7, 7])

    def test_else_and_nested_conditions(self):
        self.assert_values("""
            when(0) begin- show(1); -end
            eor(0) begin- show(2); -end
            eor(0) begin- show(3); -end
            or begin-
                when(1) begin- show(4); -end
                or begin- show(5); -end
            -end
        """, [4])

    def test_while_reevaluates_condition(self):
        self.assert_values("""
            int i; set i to 0;
            loop(i lt 3) begin- show(i); set i to i add 1; -end
            loop(0) begin- show(99); -end
            show(i);
        """, [0, 1, 2, 3])

    def test_ranges_directions_and_empty_range(self):
        self.assert_values("""
            int count;
            loop(1, 6, 2) begin- set count to count add 1; -end
            loop(5, 0, 2) begin- set count to count add 1; -end
            loop(2, 2, 1) begin- show(99); -end
            show(count);
        """, [6])

    def test_loop_block_scope_is_fresh_each_iteration(self):
        self.assert_values("""
            int total;
            loop(0, 3, 1) begin-
                int local; set local to local add 1;
                set total to total add local;
            -end
            show(total);
        """, [3])

    def test_nested_loops(self):
        self.assert_values("""
            int count;
            loop(0, 2, 1) begin-
                loop(0, 3, 1) begin- set count to count add 1; -end
            -end
            show(count);
        """, [6])

    def test_functions_arguments_locals_and_forward_calls(self):
        self.assert_values("""
            int global; set global to 9;
            report(3, 4);
            report(5, 6);
            func report(int a, int b) begin-
                int local; set local to a mul b;
                show(local); show(global);
            -end
            func unused() begin- show(1 div 0); -end
        """, [12, 9, 30, 9])

    def test_recursive_function_frames(self):
        self.assert_values("""
            countdown(3);
            func countdown(int n) begin-
                when(n gt 0) begin- show(n); countdown(n sub 1); -end
            -end
        """, [3, 2, 1])

    def test_function_uses_lexical_global_scope(self):
        self.assert_values("""
            int x; set x to 10;
            func report() begin- show(x); -end
            func caller(int x) begin- report(); show(x); -end
            caller(20);
        """, [10, 20])

    def test_block_shadowing(self):
        self.assert_values("""
            int x; set x to 1;
            when(1) begin- int x; set x to 2; show(x); -end
            show(x);
        """, [2, 1])

    def test_switch_selects_case_and_zero_is_valid(self):
        self.assert_values("""
            switch(0) begin-
                case 0: show(10);
                case 1: show(1 div 0);
                default: show(99);
            -end
            switch(8) begin-
                case 1: show(1 div 0);
                default: begin- show(20); show(21); -end
            -end
        """, [10, 20, 21])

    def test_builtins(self):
        self.assert_values("""
            show(fact(0)); show(fact(5));
            show(min(4, 5)); show(max(4, 5));
            show(isprime(0)); show(isprime(1)); show(isprime(2)); show(isprime(97));
            show(isprime(98)); show(exp(2, 10)); show(exp(7, 0));
        """, [1, 120, 4, 5, 0, 0, 1, 1, 0, 1024, 1])

    def test_comments(self):
        self.assert_values("""
            # single line
            ## multi
            line # content
            ## show(3);
        """, [3])

    def test_all_static_errors_precede_execution(self):
        self.assert_rejected("show(123); when(0) begin- show(missing); -end",
                             "semantic", "undeclared variable", no_output=True)

    def test_scope_escape(self):
        self.assert_rejected("when(1) begin- int local; -end show(local);",
                             "semantic", "undeclared variable", no_output=True)

    def test_duplicate_and_unsupported_declarations(self):
        for source, message in [
            ("int x, x;", "duplicate declaration"),
            ("float x;", "only int"),
            ("ch x;", "only int"),
            ("array <int> a(0);", "array size must be positive"),
            ("array <int> a(2); show(a);", "expected a scalar"),
        ]:
            with self.subTest(source=source):
                self.assert_rejected(source, "semantic", message, no_output=True)

    def test_function_errors(self):
        for source, message in [
            ("missing();", "undefined function"),
            ("func f(int a) begin- -end f();", "wrong number"),
            ("func f(int a, int a) begin- -end", "duplicate declaration"),
            ("func f() begin- func g() begin- -end -end", "program scope"),
        ]:
            with self.subTest(source=source):
                self.assert_rejected(source, "semantic", message, no_output=True)

    def test_duplicate_cases(self):
        self.assert_rejected("switch(0) begin- case 0: 1; case 0: 2; -end",
                             "semantic", "duplicate switch", no_output=True)

    def test_runtime_errors(self):
        for source, message in [
            ("show(2 div 0);", "division by zero"),
            ("show(2 mod 0);", "modulo by zero"),
            ("show(2147483647 add 1);", "integer overflow"),
            ("show(50000 mul 50000);", "integer overflow"),
            ("show(exp(2, 31));", "integer overflow"),
            ("show(fact(13));", "factorial"),
            ("show(fact(0 sub 1));", "factorial"),
            ("show(exp(2, 0 sub 1));", "nonnegative"),
            ("loop(0, 3, 0) begin- show(1); -end", "step must be positive"),
            ("func f() begin- f(); -end f();", "call depth"),
        ]:
            with self.subTest(source=source):
                self.assert_rejected(source, "runtime", message)

    def test_no_execution_on_syntax_error(self):
        self.assert_rejected("show(123); int ;", "syntax", "unexpected", no_output=True)

    def test_no_execution_on_trailing_input(self):
        self.assert_rejected("initializing program begin- show(123); -end trailing",
                             "syntax", "unexpected", complete=True, no_output=True)

    def test_lexical_errors(self):
        for source, message in [
            ("show(1 + 2);", "unknown character"),
            ("show(999999999999999999999999);", "out of range"),
            ("int " + "x" * 128 + ";", "identifier exceeds"),
            ("## comment with no closing delimiter", "unterminated comment"),
        ]:
            with self.subTest(message=message):
                self.assert_rejected(source, "lexical", message, no_output=True)

    def test_missing_file(self):
        result = subprocess.run([str(ROOT / "compiler"), "/nonexistent/compiler-test.txt"],
                                text=True, capture_output=True, timeout=5)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")
        self.assertTrue(result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
