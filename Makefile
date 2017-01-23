LEX=lex
YACC=bison
CFLAGS=-Wall
CC=gcc

all:parse

parse:grammar.c scanner.c utils.c
	$(CC) $(CFLAGS) -o $@ $^

grammar.c:grammar.y
	$(YACC) -t -d -o $@ --defines=grammar.tab.h $^

%.c:%.l
	$(LEX) -o $@ $^

clean:
	rm -f grammar.c scanner.c *~ parse grammar.tab.h
	rm -f ex1 ex2
