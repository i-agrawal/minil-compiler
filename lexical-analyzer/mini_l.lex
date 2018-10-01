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
                    printf("FUNCTION\n");
                }
"beginparams"   {
                    column += yyleng;
                    printf("BEGIN_PARAMS\n");
                }
"endparams"     {
                    column += yyleng;
                    printf("END_PARAMS\n");
                }
"beginlocals"   {
                    column += yyleng;
                    printf("BEGIN_LOCALS\n");
                }
"endlocals"     {
                    column += yyleng;
                    printf("END_LOCALS\n");
                }
"beginbody"     {
                    column += yyleng;
                    printf("BEGIN_BODY\n");
                }
"endbody"       {
                    column += yyleng;
                    printf("END_BODY\n");
                }
"integer"       {
                    column += yyleng;
                    printf("INTEGER\n");
                }
"array"         {
                    column += yyleng;
                    printf("ARRAY\n");
                }
"of"            {
                    column += yyleng;
                    printf("OF\n");
                }
"if"            {
                    column += yyleng;
                    printf("IF\n");
                }
"then"          {
                    column += yyleng;
                    printf("THEN\n");
                }
"endif"         {
                    column += yyleng;
                    printf("ENDIF\n");
                }
"else"          {
                    column += yyleng;
                    printf("ELSE\n");
                }
"while"         {
                    column += yyleng;
                    printf("WHILE\n");
                }
"do"            {
                    column += yyleng;
                    printf("DO\n");
                }
"foreach"       {
                    column += yyleng;
                    printf("FOREACH\n");
                }
"in"            {
                    column += yyleng;
                    printf("IN\n");
                }
"beginloop"     {
                    column += yyleng;
                    printf("BEGINLOOP\n");
                }
"endloop"       {
                    column += yyleng;
                    printf("ENDLOOP\n");
                }
"continue"      {
                    column += yyleng;
                    printf("CONTINUE\n");
                }
"read"          {
                    column += yyleng;
                    printf("READ\n");
                }
"write"         {
                    column += yyleng;
                    printf("WRITE\n");
                }
"and"           {
                    column += yyleng;
                    printf("AND\n");
                }
"or"            {
                    column += yyleng;
                    printf("OR\n");
                }
"not"           {
                    column += yyleng;
                    printf("NOT\n");
                }
"true"          {
                    column += yyleng;
                    printf("TRUE\n");
                }
"false"         {
                    column += yyleng;
                    printf("FALSE\n");
                }
"return"        {
                    column += yyleng;
                    printf("RETURN\n");
                }
"-"             {
                    column += yyleng;
                    printf("SUB\n");
                }
"+"             {
                    column += yyleng;
                    printf("ADD\n");
                }
"*"             {
                    column += yyleng;
                    printf("MULT\n");
                }
"/"             {
                    column += yyleng;
                    printf("DIV\n");
                }
"%"             {
                    column += yyleng;
                    printf("MOD\n");
                }
"=="            {
                    column += yyleng;
                    printf("EQ\n");
                }
"<>"            {
                    column += yyleng;
                    printf("NEQ\n");
                }
"<="            {
                    column += yyleng;
                    printf("LTE\n");
                }
">="            {
                    column += yyleng;
                    printf("GTE\n");
                }
"<"             {
                    column += yyleng;
                    printf("LT\n");
                }
">"             {
                    column += yyleng;
                    printf("GT\n");
                }
";"             {
                    column += yyleng;
                    printf("SEMICOLON\n");
                }
":="            {
                    column += yyleng;
                    printf("ASSIGN\n");
                }
":"             {
                    column += yyleng;
                    printf("COLON\n");
                }
","             {
                    column += yyleng;
                    printf("COMMA\n");
                }
"("             {
                    column += yyleng;
                    printf("L_PAREN\n");
                }
")"             {
                    column += yyleng;
                    printf("R_PAREN\n");
                }
"["             {
                    column += yyleng;
                    printf("L_SQUARE_BRACKET\n");
                }
"]"             {
                    column += yyleng;
                    printf("R_SQUARE_BRACKET\n");
                }
{DIGIT}+        {
                    column += yyleng;
                    yylval.value = atoi(yytext);
                    printf("NUMBER\n");
                }
{IDENT}         {
                    column += yyleng;
                    yylval.id = yytext;
                    printf("IDENT\n");
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
