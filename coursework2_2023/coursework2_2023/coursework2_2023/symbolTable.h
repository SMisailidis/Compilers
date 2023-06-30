#ifndef _symbol_table_h
#define _symbol_table_h

// Include File Necessary for the tytpe definitions.
#include "jvmLangTypesFunctions.h"

#define MAX_VAR_LEN 80
/* The following is the element of the symbol table. For simpicity reasons the symbol table is a linked list.
A variable contains the name (as found on the source file), a type (type_integer,type real) and a position in
the local varaiables space (JVM). */
typedef struct st_var {
	char *varname;
	ParType vartype;
	int position; /*Its position on the variable environment of JVM.*/
	struct st_var *next_st_var;
} ST_ENTRY_TYPE;

typedef ST_ENTRY_TYPE *ST_TABLE_TYPE;
/* Symbol Table Definitions and Related Includes*/
// Using the SGLib Library
#include "sglib.h"
/* definition required by the Lib (sglib.h ) for the linked lists used in the symbol table.  */
#define ST_COMPARATOR(e1,e2) (strcmp(e1->varname,e2->varname))

/* *** Function Declarations regarding the symbol table. */
// Since this needs to change the symbol_table pass a pointer.
int addvar(ST_TABLE_TYPE *symbol_table, char *VariableName,ParType TypeDecl);
// Accessing the Symbol Table
int lookup(ST_TABLE_TYPE symbol_table, char *VariableName);
ParType lookup_type(ST_TABLE_TYPE symbol_table, char *VariableName);
int lookup_position(ST_TABLE_TYPE symbol_table, char *VariableName);
void print_symbol_table(ST_TABLE_TYPE symbol_table);

#endif
