
#include "jvmLangTypesFunctions.h"
#include "codeFacilities.h"
#include <stdio.h>
#include <stdlib.h>

extern FILE *yyout;
extern int yyerror(const char *);

#define MAX_INST_LEN 200
/* ********************************************************************************** */
/* Function Definitions for Syntax and Semantic Analysis */
/* Type inferece regarding arithmetic expressions. Strong typing
   no coersion.  */
ParType typeDefinition(ParType Arg1, ParType Arg2)
{
	if (Arg1 == type_integer && Arg2 == type_integer) {return type_integer;}
	else if (Arg1 == type_real && Arg2 == type_real) {return type_real;}
	else {yyerror("Type missmatch"); return type_error;}
}

/* Returns the correct type prefix on commands.
  This is based on the definition of the enumerated type ParType
*/
const char *  typePrefix(ParType Arg1)
{
	  if (Arg1 > 6) {fprintf(stderr,"Type %d cannot act as a prefix!",Arg1);
		            yyerror("Internal Compiler error!"); exit(-1);}
	  static char * typePrefices[] = {"error", "i", "f", "b","", "a", "a"};
	  return typePrefices[Arg1];
}

/* Returns the type descriptor for the JVM Commands.
 Depends on the defintion of ParType enum */
const char *  typeDescriptor(ParType Arg1)
{
   static char * typePrefices[] = {"error", "I", "F","Z","V","[I","[F","Ljava.lang.String;"};
   return typePrefices[Arg1];
}

void printType(ParType Arg1)
{
   if (Arg1 == type_integer) {fprintf(yyout,"i");}
   if (Arg1 == type_real) {fprintf(yyout,"f");}
}

/* Managing Labels*/
int current_label = 1;
/* Creating a new label, a number, means increasing the label number as well */
int Label()
{
  return current_label++;
}

int currentLabel()
{
	return current_label;
}

/* Creating a label (outputing) with a
 specific label passed as a parameter. If the label is greater that 0.
If not (for instance 0, or -1) it means that we do not need a label.*/
void insertLabel(int l){
	 char instruction[MAX_INST_LEN];
	 sprintf(instruction,"#_%d:",l);
   addInstruction(instruction,NO_LABEL);
}

/* Inserts a GOTO Label statement with the appropriate label number.*/
void insertGOTO(int l){
    addInstruction("goto #_",l);
}

void insertOPERATION(ParType expType, char *operation){
	 char instruction[MAX_INST_LEN];
   sprintf(instruction,"%s%s",typePrefix(expType),operation);
   addInstruction(instruction,NO_LABEL);
}

void insertIINC(int varPosition, int value){
	 char instruction[MAX_INST_LEN];
   sprintf(instruction,"iinc %d %d",varPosition,value);
   addInstruction(instruction,NO_LABEL);
}

void insertLOAD(ParType expType, int varPosition){
	 char instruction[MAX_INST_LEN];
   sprintf(instruction,"%sload %d",typePrefix(expType),varPosition);
	 addInstruction(instruction,NO_LABEL);
}

void insertSTORE(ParType expType, int varPosition){
	char instruction[MAX_INST_LEN];
	sprintf(instruction,"%sstore %d",typePrefix(expType),varPosition);
	addInstruction(instruction,NO_LABEL);
}

/* Load Command for array elements. ou should indicate the TYPE of array elements*/
void insertALOAD_ARRAY_ELEM(ParType expType){
	 char instruction[MAX_INST_LEN];
   sprintf(instruction,"%saload",typePrefix(expType));
	 addInstruction(instruction,NO_LABEL);
}
/* Store Command for array elements*/
void insertASTORE_ARRAY_ELEM(ParType expType){
	char instruction[MAX_INST_LEN];
	sprintf(instruction,"%sastore",typePrefix(expType));
	addInstruction(instruction,NO_LABEL);
}


void insertLDC(char *value){
	char instruction[MAX_INST_LEN];
  sprintf(instruction,"ldc %s",value);
	addInstruction(instruction,NO_LABEL);
}

void insertICMPOP(RelationType operator, int label){

  switch (operator) {
      case OP_GT: addInstruction("if_icmpgt #_", label);break;
      case OP_LT: addInstruction("if_icmplt #_", label);break;
      case OP_EQ: addInstruction("if_icmpeq #_", label); break;
   }

}

/* Adding an instruction as a string*/
void insertINSTRUCTION(char * instruction){
  addInstruction(instruction,NO_LABEL);
}

void insertINVOKEVITRUAL(char *className, ParType argType, ParType returnType)
{
	char instruction[MAX_INST_LEN];
	sprintf(instruction,"invokevirtual %s(%s)%s",className,
	               typeDescriptor(argType),typeDescriptor(returnType));
	addInstruction(instruction,NO_LABEL);
}

void insertINVOKESTATIC(char *className, ParType argType, ParType returnType)
{
	char instruction[MAX_INST_LEN];
	sprintf(instruction,"invokestatic %s(%s)%s",className,
	               typeDescriptor(argType),typeDescriptor(returnType));
	addInstruction(instruction,NO_LABEL);
}


void insertIFOP(RelationType operator,int label){
switch (operator) {
 case OP_GT: addInstruction("ifgt #_", label); break;
 case OP_LT: addInstruction("iflt #_", label); break;
 case OP_EQ: addInstruction("ifeq #_", label); break;
   }
}

/* Optimized for JVM (iconst?/bipush/sipush)*/
void pushInteger(int x){
	char instruction[MAX_INST_LEN];
	if (x == -1) sprintf(instruction,"iconst_m1");
	else if (x >=0 && x <=5) sprintf(instruction,"iconst_%d",x);
	else if (x > -128 && x < 127) sprintf(instruction,"bipush %d",x);
	else sprintf(instruction,"sipush %d",x);
	addInstruction(instruction,NO_LABEL);
}

/* Function that prints preample code in class file.  */
void create_preample(char *className){
	char instruction[MAX_INST_LEN];
	sprintf(instruction,".class public %s ",className);
	addInstruction(instruction,NO_LABEL);
	addInstruction(".super java/lang/Object\n",NO_LABEL);
	addInstruction(".method public static main([Ljava/lang/String;)V",NO_LABEL);
	/* this is an overkill but will do for educational purposes */
	addInstruction(" .limit locals 30 \n .limit stack 30\n",NO_LABEL);

}
