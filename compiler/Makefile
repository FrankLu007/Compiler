all:
	yacc -d -v parser.y
	lex lex.l
	gcc -O3 lex.yy.c y.tab.c -ly -lfl
clean:
	rm -f lex.yy.c y.tab.c y.tab.h parser