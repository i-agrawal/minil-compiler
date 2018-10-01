/*
Ishan Agrawal
iagra001@ucr.edu
*/

%option noyywrap

%{
    #include <stdio.h>
    #include "mini_l.tab.h"
    
    int line = 1;
    int column = 1;
%}

DIGIT   [0-9]
LETTER  [a-zA-Z]
UNDER   [_]*({DIGIT}|{LETTER})+
IDENT   {LETTER}({LETTER}|{DIGIT}|{UNDER})*

%%

"function"      {
                    column += yyleng;
                    return FUNCTION;
                }
"beginparams"   {
                    column += yyleng;
                    return BEGIN_PARAMS;
                }
"endparams"     {
                    column += yyleng;
                    return END_PARAMS;
                }
"beginlocals"   {
                    column += yyleng;
                    return BEGIN_LOCALS;
                }
"endlocals"     {
                    column += yyleng;
                    return END_LOCALS;
                }
"beginbody"     {
                    column += yyleng;
                    return BEGIN_BODY;
                }
"endbody"       {
                    column += yyleng;
                    return END_BODY;
                }
"integer"       {
                    column += yyleng;
                    return INTEGER;
                }
"array"         {
                    column += yyleng;
                    return ARRAY;
                }
"of"            {
                    column += yyleng;
                    return OF;
                }
"if"            {
                    column += yyleng;
                    return IF;
                }
"then"          {
                    column += yyleng;
                    return THEN;
                }
"endif"         {
                    column += yyleng;
                    return ENDIF;
                }
"else"          {
                    column += yyleng;
                    return ELSE;
                }
"while"         {
                    column += yyleng;
                    return WHILE;
                }
"do"            {
                    column += yyleng;
                    return DO;
                }
"foreach"       {
                    column += yyleng;
                    return FOREACH;
                }
"in"            {
                    column += yyleng;
                    return IN;
                }
"beginloop"     {
                    column += yyleng;
                    return BEGINLOOP;
                }
"endloop"       {
                    column += yyleng;
                    return ENDLOOP;
                }
"continue"      {
                    column += yyleng;
                    return CONTINUE;
                }
"read"          {
                    column += yyleng;
                    return READ;
                }
"write"         {
                    column += yyleng;
                    return WRITE;
                }
"and"           {
                    column += yyleng;
                    return AND;
                }
"or"            {
                    column += yyleng;
                    return OR;
                }
"not"           {
                    column += yyleng;
                    return NOT;
                }
"true"          {
                    column += yyleng;
                    return TRUE;
                }
"false"         {
                    column += yyleng;
                    return FALSE;
                }
"return"        {
                    column += yyleng;
                    return RETURN;
                }
"-"             {
                    column += yyleng;
                    return SUB;
                }
"+"             {
                    column += yyleng;
                    return ADD;
                }
"*"             {
                    column += yyleng;
                    return MULT;
                }
"/"             {
                    column += yyleng;
                    return DIV;
                }
"%"             {
                    column += yyleng;
                    return MOD;
                }
"=="            {
                    column += yyleng;
                    return EQ;
                }
"<>"            {
                    column += yyleng;
                    return NEQ;
                }
"<="            {
                    column += yyleng;
                    return LTE;
                }
">="            {
                    column += yyleng;
                    return GTE;
                }
"<"             {
                    column += yyleng;
                    return LT;
                }
">"             {
                    column += yyleng;
                    return GT;
                }
";"             {
                    column += yyleng;
                    return SEMICOLON;
                }
":="            {
                    column += yyleng;
                    return ASSIGN;
                }
":"             {
                    column += yyleng;
                    return COLON;
                }
","             {
                    column += yyleng;
                    return COMMA;
                }
"("             {
                    column += yyleng;
                    return L_PAREN;
                }
")"             {
                    column += yyleng;
                    return R_PAREN;
                }
"["             {
                    column += yyleng;
                    return L_SQUARE_BRACKET;
                }
"]"             {
                    column += yyleng;
                    return R_SQUARE_BRACKET;
                }
{DIGIT}+    {
                    column += yyleng;
                    yylval.value = atoi(yytext);
                    return NUMBER;
                }
{IDENT}         {
                    column += yyleng;
                    yylval.id = yytext;
                    return IDENT;
                }
[ \t]+          {
                    column += yyleng;
                }
"\n"            {
                    line++;
                    column = 1;
                }
(##.*)          {
                    line++;
                    column = 1;
                }

([_]|{DIGIT})({DIGIT}|{LETTER}|[_])*     {
                    printf("Error at line %d, column %d ", line, column);
                    printf("identifier \"%s\" must begin with a letter\n", yytext);
                    exit(0);
                }

{LETTER}({DIGIT}|{IDENT}|[_])*[_] {
                    printf("Error at line %d, column %d ", line, column);
                    printf("identifier \"%s\" cannot end with an underscore\n", yytext);
                    exit(0);
                }

.               {
                    printf("Error at line %d, column %d ", line, column);
                    printf(" unrecognized symbol \"%s\"\n", yytext);
                    exit(0);
                }

%%
