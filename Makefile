
CC = gcc
CFLAGS=-std=c89 -pedantic -Wall -Wextra -Werror -ggdb3 -O0

build:
	flex lexbis.l
	g++  lex.yy.c -o lex -Wall
	
run:
	./lex
	
clean:
	rm lex  lex.yy.c
