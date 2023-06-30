%{
#include <stdio.h>
#include <stdlib.h>
// To remove persistent warning..
int yylex();
%}

%define parse.error verbose

%token T_VAR 
%token T_ATOM 
%token T_NUMBER 
%token T_COMP_OP
%token T_ARROW "<-"
%token T_NOT "not"
%token T_TRUE "true"

%token '.'
%token '('
%token ')'
%token ':'
%token ';'
%token '&'
%token '?'
%token '!'
%token '|'
%token ','

%left '+' '-' 
%left '&' 
%left ','
%left '.'

%nonassoc '='
%nonassoc '>'
%nonassoc '<'

%{
void yyerror (const char * msg);
%}


%%

agent : beliefs plans;

beliefs : beliefs belief | /*empty*/;

belief : predicate '.' ;

predicate : T_ATOM '(' terms ')';

plans : plans plan | /*empty*/;

plan : trig_event ':' context T_ARROW body '.';

trig_event : '+' predicate | '-' predicate | '+' goal | '-' goal;

context : T_TRUE | cliterals;

cliterals : literal | literal '&' cliterals;

literal : predicate | T_NOT '(' predicate ')' | boolExpr;

goal : '!' predicate | '?' predicate;

body : T_TRUE | actions;

actions : action | action ';' actions;

action : predicate | goal | belief_update;

belief_update : '+' predicate | '-' predicate;

terms : term | term ',' terms;

term : T_VAR | T_ATOM | T_NUMBER | T_ATOM '(' terms ')';

boolExpr : boolE | boolExpr '|' boolE;

boolE : boolarg relOp boolarg;

boolarg : T_NUMBER | T_VAR;

relOp : T_COMP_OP;


%%

#include "agentSpeak.lex.c"

void yyerror (const char * msg)
{
   printf("Error(line %d) : %s\n",line, msg); 
 
}

int main(int argc, char **argv ){
   ++argv, --argc;  /* skip over program name */
   if ( argc > 0 )
       yyin = fopen( argv[0], "r" );
   else
      yyin = stdin;

   int result = yyparse();

   if (result == 0 && yynerrs == 0)
      printf("Syntax OK!\n");
   else
      printf("There were %d errors in code. Failure!\n", yynerrs);
   return result;
}








