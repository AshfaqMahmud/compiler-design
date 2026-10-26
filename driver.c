#include "ast.h"
#include <stdio.h>
#include <stdlib.h>

int yyparse(void);
int yylex_destroy(void);
extern FILE *yyin;
extern int lexer_line;

int yyerror(const char *message)
{
    fprintf(stderr, "line %d: syntax error: %s\n", lexer_line, message);
    ++diagnostic_errors;
    return 0;
}

int main(int argc, char **argv)
{
    if (argc > 2) {
        fprintf(stderr, "usage: %s [source-file]\n", argv[0]);
        return EXIT_FAILURE;
    }
    const char *path = argc == 2 ? argv[1] : "input.txt";
    yyin = fopen(path, "r");
    if (!yyin) { perror(path); return EXIT_FAILURE; }

    int success = yyparse() == 0 && diagnostic_errors == 0;
    if (success) success = semantic_check(program_root);
    if (success) success = execute_program(program_root);
    if (success) puts("Successful compilation.");
    fclose(yyin);
    yylex_destroy();
    ast_free();
    return success ? EXIT_SUCCESS : EXIT_FAILURE;
}
