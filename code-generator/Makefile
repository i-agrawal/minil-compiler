# Ishan Agrawal
# iagra001@ucr.edu

CC = g++
LEX = flex
YACC = bison
YFLG = -v -d

.DEFAULT: generator

generator: lex.yy.c mini_l.tab.c
	$(CC) -o $@ $^ -std=c++11

lex.yy.c: mini_l.lex mini_l.tab.h
	$(LEX) -o $@ $<

mini_l.tab.c mini_l.tab.h: mini_l.y
	$(YACC) $(YFLG) $<

.PHONY: clean

clean:
	rm -rf *.c *.output *.h