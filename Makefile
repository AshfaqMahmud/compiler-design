CC ?= cc
CFLAGS ?= -std=c11 -Wall -Wextra -Wpedantic
LEX = flex
YACC = bison

TARGET := compiler
PARSER := main.tab.c
PARSER_HEADER := main.tab.h
LEXER := lex.yy.c
SOURCES := ast.c semantic.c runtime.c driver.c

.PHONY: all run test clean

all: $(TARGET)

$(PARSER): main.y ast.h
	$(YACC) -d main.y

$(PARSER_HEADER): $(PARSER)
	@test -f $@ || $(YACC) -d main.y

$(LEXER): main.l $(PARSER_HEADER)
	$(LEX) main.l

$(TARGET): $(PARSER) $(LEXER) $(SOURCES) ast.h
	$(CC) $(CFLAGS) $(PARSER) $(LEXER) $(SOURCES) -o $(TARGET)

run: $(TARGET)
	./$(TARGET) input.txt

test:
	sh tests/run.sh

clean:
	rm -f $(TARGET) $(PARSER) $(PARSER_HEADER) $(LEXER) *.output
