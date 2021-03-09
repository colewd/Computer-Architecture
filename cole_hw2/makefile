all:
	main: main.cpp
		g++ main.cpp -o main

all: main.o
	g++ main.o -o main
main: main.cpp
	g++ main.cpp -Wall -Werror -ansi -pedantic -c

clean:
	rm -rf *.o *.a main
