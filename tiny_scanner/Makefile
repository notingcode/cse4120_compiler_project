CC = gcc

LFLAGS = -ll

CFLAGS = 

hw1_binary : main.o util.o lex.yy.o cm.tab.o
	$(CC) $(CFLAGS) -g -o hw1_binary main.o util.o lex.yy.o cm.tab.o $(LFLAGS)

util.o: util.c util.h globals.h cm.tab.h
	$(CC) $(CFLAGS) -c -o util.o util.c

main.o: main.c globals.h util.h scan.h cm.tab.h
	$(CC) $(CFLAGS) -c -o main.o main.c

lex.yy.c : lex/tiny.l
	lex lex/tiny.l

lex.yy.o : lex.yy.c util.h globals.h scan.h
	$(CC) -c -o lex.yy.o lex.yy.c

cm.tab.c cm.tab.h : yacc/cm.y
	bison -d yacc/cm.y

cm.tab.o : cm.tab.c cm.tab.h
	$(CC) $(CFLAGS) -c cm.tab.c
	
.PHONY:
	clean

clean:
	rm *.o hw1_binary lex.yy.c cm.tab.c *_20181605.txt
