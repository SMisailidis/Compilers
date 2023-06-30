.PHONY: default

default: jvmLExp

jvmLExp: jvmLExp.tab.c symbolTable.o jvmLangTypesFunctions.o codeFacilities.o
	gcc -o jvmLExp jvmLExp.tab.c symbolTable.o jvmLangTypesFunctions.o codeFacilities.o -lfl

jvmLExp.lex.c: jvmLExp.l
	flex -s -ojvmLExp.lex.c jvmLExp.l

jvmLExp.tab.c: jvmLExp.y jvmLExp.lex.c jvmLangTypesFunctions.h symbolTable.h
	bison -v jvmLExp.y

symbolTable.o: symbolTable.c symbolTable.h
	gcc -c symbolTable.c

jvmLangfTypesFunctions.o: jvmLangTypesFunctions.c jvmLangTypesFunctions.h
	gcc -c jvmLangTypesFunctions.c

codeFacilities.o: codeFacilities.c codeFacilities.h
	gcc -c codeFacilities.c

clean:
	rm -f jvmLExp.lex.c
	rm -f jvmLExp.tab.c jvmLExp jvmLExp.output
	rm -f jvmLangTypesFunctions.o  symbolTable.o codeFacilities.o



cleanFiles:
	rm ./Examples/*.j
	rm ./Examples/*.class
