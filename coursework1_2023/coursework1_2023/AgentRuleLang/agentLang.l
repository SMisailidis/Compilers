/* This is an example of a simple LL grammar implementation */
%{
#include <stdio.h>
#include <string.h>

/* ADD your token definitions here */
#define TK_NAME 300
#define TK_OPENBRACKET 310
#define TK_CLOSEBRACKET 320
#define TK_MEM_CLEAR 330
#define TK_REL 340
#define TK_NUM 350
#define TK_FORWARD 360
#define TK_LEFT 370
#define TK_RIGHT 380
#define TK_SEMICOLON 400
#define TK_DETECTOR 410
#define TK_TRUE 420
#define TK_ARROW 430
#define TK_LEFT_LASER 440
#define TK_RIGHT_LASER 450
#define TK_FRONT_SONAR 460
/* Needed for syntax analyser*/
#define LEXEND 0

int line = 1;
%}

newline \n|\x0A|\x0D|\x0A
ws ([ \t\r]+
WORD ^[a-z0-9]+
NUMBERS [0-9]+
REL [><=]	

%%
{newline} { line++;}
{WORD} {return(TK_NAME);}
"[" {return(TK_OPENBRACKET);}
"]" {return(TK_CLOSEBRACKET);}
"mem-clear" {return(TK_MEM_CLEAR);}
";" {return(TK_SEMICOLON);}
"left-laser" {return(TK_LEFT_LASER);}
"right-laser" {return(TK_RIGHT_LASER);}
"front-sonar" {return(TK_FRONT_SONAR);}
{REL} {return(TK_REL);}
{NUMBERS} {return(TK_NUM);}
"->" {return(TK_ARROW);}
"turn left" {return(TK_LEFT);}
"turn right" {return(TK_RIGHT);}
"forward" {return(TK_FORWARD);}
"true" {return(TK_TRUE);}
%%

int token = 0;

void agent(void);
void guardedActions(void);
void guardedActionsPrime(void);
void guardedAct(void);
void action(void);

/* Add your LL functions forward here */

void error_syntax(void);
void match(int tk);

/* Add your function implementations here. */

void agent(){
   match(TK_NAME);
   match(TK_OPENBRACKET);
   guardedActions();
   match(TK_CLOSEBRACKET);
}

void guardedActions(){
   if(token != TK_MEM_CLEAR) {
      guardedAct();
      guardedActionsPrime();
      
   }
   else if(token == TK_MEM_CLEAR) {
   
      match(TK_MEM_CLEAR);
      match(TK_SEMICOLON);
      guardedActionsPrime();
   }
   else {
     error_syntax();
   }
}

void guardedActionsPrime(){
   if(token == TK_LEFT_LASER || token == TK_RIGHT_LASER || token == TK_FRONT_SONAR || token == TK_TRUE) {
      guardedAct();
      guardedActionsPrime();
   }
   else {
   	return;
   }
}

void guardedAct(){
   if(token == TK_LEFT_LASER) {
      match(TK_LEFT_LASER);
      match(TK_REL);
      match(TK_NUM);
      match(TK_ARROW);
      action();
      match(TK_SEMICOLON);
   }
   else if(token == TK_RIGHT_LASER) {

      match(TK_RIGHT_LASER);
      match(TK_REL);
      match(TK_NUM);
      match(TK_ARROW);
      action();
      match(TK_SEMICOLON);
   }
   else if(token == TK_FRONT_SONAR) {

      match(TK_FRONT_SONAR);
      match(TK_REL);
      match(TK_NUM);
      match(TK_ARROW);
      action();
      match(TK_SEMICOLON);
   }
   else if (token == TK_TRUE) {
      match(TK_TRUE);
      match(TK_ARROW);
      action();
      match(TK_SEMICOLON);
   }
   else {
      error_syntax();
   }
}

void action(){
   if (token == TK_FORWARD){
      match(TK_FORWARD);
      match(TK_NUM);
   }
   else if (token == TK_LEFT){
      match(TK_LEFT);
      match(TK_NUM);
   } 
   else if (token == TK_RIGHT){
      match(TK_RIGHT);
      match(TK_NUM);
   }
   else {
   
   	error_syntax();
   }
}

void error_syntax(void){
   printf(" Syntax Error reading %s at line %d of input. \n",yytext, line);
   exit(-1);
}

void match(int tk){
   if (token == tk) token = yylex();
   else error_syntax();
}

int main(int argc, char **argv ){
   ++argv, --argc; /* skip over program name */
   if ( argc > 0 )
      yyin = fopen( argv[0], "r" );
   else
      yyin = stdin;

   token = yylex();
   agent();
   if (token == LEXEND) printf("\n Success! \n \n");
   else error_syntax();
   
   return 0;
}
