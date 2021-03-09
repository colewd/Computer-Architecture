all: masm_nr rshift.o mult.o div.o

masm_nr: mic1_symasm.o lex.yy.o
	gcc -o masm_nr mic1_symasm.o lex.yy.o
mic1_symasm.o:  mic1_symasm.c
	gcc -c -g mic1_symasm.c
lex.yy.o:  lex.yy.c
	gcc -c -g lex.yy.c
lex.yy.c: mic1_symasm.ll
	flex mic1_symasm.ll
rshift.o: a4_rshift_test.asm
	./masm_mrd < a4_rshift_test.asm > rshift.o
mult.o: a4_mult_test.asm
	./masm_mrd < a4_mult_test.asm > mult.o
div.o: a4_div_test.asm
	./masm_mrd < a4_div_test.asm > div.o

clean:
	rm lex.yy.o lex.yy.c mic1_symasm.o masm_nr rshift.o mult.o div.o
