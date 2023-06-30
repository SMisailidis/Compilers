%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Flex Declarations
/* Just for being able to show the line number were the error occurs.*/
extern int line;
extern FILE *yyout;
int yylex();
/* Error Related Functions and Macros*/
int yyerror(const char *);
int no_errors;
/* Error Messages Macros*/
#define ERR_VAR_DECL(VAR,LINE) fprintf(stderr,"Variable :: %s on line %d. ",VAR,LINE); yyerror("Var already defined")
#define ERR_VAR_MISSING(VAR,LINE) fprintf(stderr,"Variable %s NOT declared, n line %d.",VAR,LINE); yyerror("Variable Declation fault.")

// Type Definitions and JVM command related Functions
#include "jvmLangTypesFunctions.h"
// Symbol Table definitions and Functions
#include "symbolTable.h"
/* Defining the Symbol table. A simple linked list. */
ST_TABLE_TYPE symbolTable;
#include "codeFacilities.h"

%}
/* Output informative error messages (bison Option) */
%define parse.error verbose

%union{

   char *lexical;
   ParType tokentype;
   struct {
    	ParType type;
    	char * place;} se;
  RelationType relopIndex;
  struct {
   	NUMBER_LIST_TYPE trueLbl;
   	NUMBER_LIST_TYPE falseLbl;
	} condLabels;

}

/* Token declarations and their respective types */

%token <tokentype> T_type

%token <lexical> T_int
%token <lexical> T_float
%token <lexical> T_id

%token T_start "start"
%token T_end "end"
%token T_forall "forall"
%token T_print "print"
%token T_in "in"

%token T_float ".."
%token '('
%token ')'
%token '['
%token ']'

%left '+'
%left '*'

/* The type of non-terminal symbols*/

%type<se> term
%type<se> expr
%type<se> type_expr
%type<se> non_type_expr
%type<se> non_parenthesis_expr
%type<se> parenthesis_expr
%type<se> print_expr
%type<se> operation

%%
program:
  "start" T_id
  {
	create_preample($2);
	symbolTable=NULL;
  }
  stmts "end"
  {
	insertINSTRUCTION("return");
	insertINSTRUCTION(".end method\n");
  }
    ;

stmts: /*empty*/
  | stmts stmt
  ;

stmt:
  '(' command ')'
  ;

command:
  T_print print_expr
  | assignments
  ;

assignments:
  T_id expr
  {
	addvar(&symbolTable,$1,$2.type);
	insertSTORE($2.type, lookup_position(symbolTable,$1));
  }
  | T_id '[' T_forall T_id T_in T_int T_float T_int ']'
  {

	int start = atoi($6);
	int end = atoi($8);
	int size = end - start + 1;
	pushInteger(size);
    
	insertINSTRUCTION("newarray int");
	addvar(&symbolTable, $1, type_int_array);
	insertSTORE(type_int_array, lookup_position(symbolTable, $1));
    
	pushInteger(0);
	addvar(&symbolTable, $4, type_integer);
	insertSTORE(type_integer, lookup_position(symbolTable, $4));
	insertGOTO(2);
    
	insertLabel(currentLabel());
	Label();

	insertLOAD(type_int_array, lookup_position(symbolTable, $1));
	insertLOAD(type_integer, lookup_position(symbolTable, $4));
    
	insertLOAD(type_integer, lookup_position(symbolTable, $4));
	pushInteger(start);
	insertOPERATION(type_integer, "add");
	insertASTORE_ARRAY_ELEM(type_integer);
	insertIINC(lookup_position(symbolTable, $4), 1);
    
	insertLabel(currentLabel());
    	
	insertLOAD(type_integer, lookup_position(symbolTable, $4));
	pushInteger(size-1);
	insertINSTRUCTION("if_icmple #_1");
  }
  ;
 
print_expr:
  expr
  {
	insertINSTRUCTION("getstatic java/lang/System/out Ljava/io/PrintStream;");
	insertINSTRUCTION("swap");
	insertINVOKEVITRUAL("java/io/PrintStream/println",$1.type,type_void) ;
  }
  ;

expr:
  parenthesis_expr
  | non_parenthesis_expr
  ;

parenthesis_expr:
  '(' non_type_expr ')' { $$ = $2; }
  | '(' type_expr ')' { $$ = $2; }
  ;

non_parenthesis_expr:
  non_type_expr
  | type_expr
  ;

type_expr:
  T_type expr
  {
	$$.type = $1;
	if ($$.type != $2.type) {
  	if ($$.type == type_integer)
    	insertINSTRUCTION("f2i");
  	else
    	insertINSTRUCTION("i2f");
	}
  }
  ;

non_type_expr:
  term
  | operation
  ;

operation:
  expr expr '+'
  {
	$$.type = typeDefinition($1.type, $2.type);
	insertOPERATION($$.type, "add");
  }
  | expr expr '*'
  {
	$$.type = typeDefinition($1.type, $2.type);
	insertOPERATION($$.type, "mul");
  }
  ;

term:
  T_id
  {
	if (!($$.type = lookup_type(symbolTable,$1))) {
  	ERR_VAR_MISSING($1,line);
	}
	$$.place = $1;
	insertLOAD($$.type,lookup_position(symbolTable,$1));
  }
  | T_int
  {
	$$.place = $1;
	$$.type = type_integer;
	pushInteger(atoi($1));
  }
  | T_float
  {
	$$.place = $1;
	$$.type = type_real;
	insertLDC($1);
  }
  | T_id '[' T_int ']'
  {
	if (!(lookup_type(symbolTable,$1)==type_int_array)) {
  	ERR_VAR_MISSING($1, line);
	}
	$$.type = type_integer;
	insertLOAD(type_int_array,lookup_position(symbolTable,$1));
	pushInteger(atoi($3));
	insertALOAD_ARRAY_ELEM(type_integer);
  }
  ;

%%



/* The usual yyerror */
int yyerror (const char * msg)
{
  fprintf(stderr, "PARSE ERROR: %s.on line %d.\n ", msg,line);
  no_errors++;
}

/* Other error Functions*/
/* The lexer... */
#include "jvmLExp.lex.c"

/* Main */
int main(int argc, char **argv ){

   ++argv, --argc;  /* skip over program name */
   if ( argc > 0 && (yyin = fopen( argv[0], "r")) == NULL)
	{
  	fprintf(stderr,"File %s NOT FOUND in current directory.\n Using stdin.\n",argv[0]);
  	yyin = stdin;
	}
   if ( argc > 1) {yyout = fopen(argv[1], "w");}
   else {
  	fprintf(stderr,"No second argument defined. Output to screen.\n\n");
  	yyout = stdout;
	}

	// Calling the parser
   int result = yyparse();

   fprintf(stderr,"Errors found %d.\n",no_errors);
   if (no_errors == 0)
  	{print_int_code(yyout);}
   fclose(yyout);
   /// Need to remove even empty file.
   if (no_errors != 0 && yyout != stdout) {
 	remove(argv[1]);
  	fprintf(stderr,"No Code Generated.\n");}
   print_symbol_table(symbolTable); /* uncomment for debugging. */

  return result;
}


