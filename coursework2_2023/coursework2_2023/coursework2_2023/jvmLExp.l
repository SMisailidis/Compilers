/*
Grammar with semantics and type checking.
Lexical Analyser
*/

%{
#include <stdlib.h>
#include <string.h>
int line = 1;
%}

DIGITS [0-9]
LETTER [a-zA-Z]
VARIABLE {LETTER}({LETTER}|{DIGITS}|_)*
FLOAT {DIGITS}+\.{DIGITS}+
newline \n|\x0A|\x0D\x0A
%%

"start" {return T_start;}
"end" {return T_end;}
"forall" {return T_forall;}
"print" {return T_print;}
"in" {return T_in;}

"int" {yylval.tokentype=type_integer;return T_type;}
"float" {yylval.tokentype=type_real;return T_type;}

"*" {return '*';}
"+" {return '+';}
"(" {return '(';}
")" {return ')';}
"[" {return '[';}
"]" {return ']';}
".." {return T_float;}

{DIGITS}+ {yylval.lexical=strdup(yytext);return T_int;}
{FLOAT} {yylval.lexical=strdup(yytext);return T_float;}
{VARIABLE} {yylval.lexical=strdup(yytext);return T_id;}

{newline}  { line++;}
[ \t] { /* nothing */ }
. {
	printf("Lexical Analysis: Unexpected String! :: %s. in line %d. \n",yytext,yylineno); }

%%

