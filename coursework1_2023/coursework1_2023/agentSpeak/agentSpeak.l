%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int line=1;
%}

ws [ \t]+
newline \n|\x0A|\x0D\x0A


nzdigit [1-9]
digit (0|{nzdigit}) 
digits {digit}+
floats  {digits}(\.{digits})
capital [A-Z]
smallcase [a-z]
letter [A-Za-z]
variable {capital}({letter}|{digit}|_)*
atom {smallcase}({letter}|{digit}|_)*

%%

{ws} {/* do nothing */}

{digits} {return T_NUMBER;}
{floats} {return T_NUMBER;}
{atom} {
    if (strcmp(yytext, "true") == 0) {
        return T_TRUE;
    } else if (strcmp(yytext, "not") == 0) {
        return T_NOT;
    } else {
        return T_ATOM;
    }
}

{variable} {return T_VAR;}
"<-" {return T_ARROW;}
"_" {return T_VAR;}
">"|"<"|"="|">="|"=<" {return T_COMP_OP;}

"." {return '.';}
"(" {return '(';}
")" {return ')';}
":" {return ':';}
"+" {return '+';}
"-" {return '-';}
"&" {return '&';}
"!" {return '!';}
"?" {return '?';}
";" {return ';';}
"," {return ',';}
"|" {return '|';}




{newline} { line++;}
. {/*Do nothing*/}

%%


