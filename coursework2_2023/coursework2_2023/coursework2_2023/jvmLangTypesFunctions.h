/* File: jvmLang.h
   File that is to be included in .y parser file that provides
   some useful defintions and functions.
*/
#include <stdio.h>
#ifndef _jvm_Lang_types_functions_h
#define _jvm_Lang_types_functions_h
/* Definition of the supported types*/
typedef enum {type_error, 
              type_integer, type_real, type_boolean, type_void, 
              type_int_array, type_float_array, 
              type_string} ParType;

// These are not token declarations but used internally in the parser.
typedef enum {OP_GT, OP_LT, OP_EQ} RelationType;

// Function Declarations
// Types
ParType typeDefinition(ParType Arg1, ParType Arg2);
void printType(ParType Arg1);
const char * typePrefix(ParType Arg1);
const char * typeDescriptor(ParType Arg1);

// method preample
void create_preample(char *className);
// Labels
int Label();
int currentLabel();

void insertLabel(int l);
// Instructions
void pushInteger(int x);
void insertGOTO(int l);
void insertOPERATION(ParType expType,char *operation);
void insertLOAD(ParType expType, int varPosition);
void insertSTORE(ParType expType, int varPosition);
void insertLDC(char *value);
void insertICMPOP(RelationType operator, int label);
void insertIFOP(RelationType operator,int label);
void insertINSTRUCTION(char * instruction);
void insertINVOKEVITRUAL(char *className, ParType argType, ParType returnType);
void insertINVOKESTATIC(char *className, ParType argType, ParType returnType);
void insertIINC(int varPosition, int value);

// New Functions
void insertALOAD_ARRAY_ELEM(ParType expType);
void insertASTORE_ARRAY_ELEM(ParType expType);


#endif
