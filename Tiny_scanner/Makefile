CC = gcc

LFLAGS = -ll

CFLAGS = 

hw1_20181605.exe : main.o util.o lex.yy.o
	$(CC) $(CFLAGS) -g -o hw1_20181605.exe main.o util.o lex.yy.o $(LFLAGS)

util.o: util.c util.h globals.h
	$(CC) $(CFLAGS) -c -o util.o util.c

#scan.o: scan.c globals.h util.o
#	$(CC) $(CFLAGS) -c -o scan.o scan.c

main.o: main.c globals.h util.o
	$(CC) $(CFLAGS) -c -o main.o main.c

lex.yy.c : lex/tiny.l
	lex lex/tiny.l

lex.yy.o : lex.yy.c
	$(CC) -c -o lex.yy.o lex.yy.c

.PHONY:
	clean

clean:
	rm *.o hw1_20181605.exe lex.yy.c hw1_20181605.txt
