/*
Ishan Agrawal
861229134
iagra001@ucr.edu
*/

%{
    #include <stdio.h>

    extern int line;
    extern int column;
    extern int yylex();

    int yyerror(const char *);
    int main(int, char**);
%}

%union {
    int value;
    char* id;
}

%error-verbose

%token  FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET RETURN SUB

%left MULT DIV MOD ADD LT LTE GT GTE EQ NEQ AND OR
%right NOT ASSIGN

%token <value> NUMBER
%token <id> IDENT

%%

program:
    function program {
        printf("program -> function\n");
    } | %empty {
        printf("program -> epsilon\n");
    }
;

function:
    FUNCTION ident SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {
        printf("function -> FUNCTION IDENTIFIER SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");
    } | error {
        yyerrok; yyclearin;
    }
;

declarations:
    declaration SEMICOLON declarations {
        printf("declarations -> declaration SEMICOLON declarations\n");
    } | %empty {
        printf("declarations -> epsilon\n");
    }
;

declaration:
    idents COLON INTEGER {
        printf("declaration -> idents COLON INTEGER\n");
    } | idents COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER {
        printf("declaration -> idents COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET INTEGER\n");
    } | error {
        yyerrok; yyclearin;
    }
;

statements:
    statement SEMICOLON statements {
        printf("statements -> statement SEMICOLON statements\n");
    } | statement SEMICOLON {
        printf("statements -> statement SEMICOLON\n");
    }
;

statement:
    var ASSIGN expression {
        printf("statement -> var ASSIGN expression\n");
    } | IF bool-exp THEN statements ENDIF {
        printf("statement -> IF bool-exp THEN statements ENDIF\n");
    } | IF bool-exp THEN statements ELSE statements ENDIF {
        printf("statement -> IF bool-exp THEN statements ELSE statements ENDIF\n");
    } | WHILE bool-exp BEGINLOOP statements ENDLOOP {
        printf("statement -> WHILE bool-exp BEGINLOOP statements ENDLOOP\n");
    } | DO BEGINLOOP statements ENDLOOP WHILE bool-exp {
        printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool-exp\n");
    } | FOREACH ident IN ident BEGINLOOP statements ENDLOOP {
        printf("statement -> FOREACH ident IN ident BEGINLOOP statements ENDLOOP\n");
    } | READ vars {
        printf("statement -> READ vars\n");
    } | WRITE vars {
        printf("statement -> WRITE vars\n");
    } | CONTINUE {
        printf("statement -> CONTINUE\n");
    } | RETURN expression {
        printf("statement -> RETURN expression\n");
    } | error {
        yyerrok; yyclearin;
    }
;

bool-exp:
    and-exp OR bool-exp {
        printf("bool-exp -> and-exp OR bool-exp\n");
    } | and-exp {
        printf("bool-exp -> and-exp\n");
    }
;

and-exp:
    relation AND and-exp {
        printf("and-exp -> relation AND and-exp\n");
    } | relation {
        printf("and-exp -> relation\n");
    }
;

relation:
    expression comp expression {
        printf("relation -> expression comp expression\n");
    } | TRUE {
        printf("relation -> TRUE\n");
    } | FALSE {
        printf("relation -> FALSE\n");
    } | L_PAREN bool-exp R_PAREN {
        printf("relation -> L_PAREN bool-exp R_PAREN\n");
    } | NOT expression comp expression {
        printf("relation -> NOT expression comp expression\n");
    } | NOT TRUE {
        printf("relation -> NOT TRUE\n");
    } | NOT FALSE {
        printf("relation -> NOT FALSE\n");
    } | NOT L_PAREN bool-exp R_PAREN {
        printf("relation -> NOT L_PAREN bool-exp R_PAREN\n");
    }
;

comp:
    EQ {
        printf("comp -> EQ\n");
    } | NEQ {
        printf("comp -> NEQ\n");
    } | LT {
        printf("comp -> LT\n");
    } | GT {
        printf("comp -> GT\n");
    } | LTE {
        printf("comp -> LTE\n");
    } | GTE {
        printf("comp -> GTE\n");
    }
;

expressions:
    expression COMMA expressions {
        printf("expressions -> expression COMMA expressions\n");
    } | expression {
        printf("expressions -> expression\n");
    }
;

expression:
    mult-exp ADD expression {
        printf("expression -> mult-exp ADD expression\n");
    } | mult-exp SUB expression {
        printf("expression -> mult-exp SUB expression\n");
    } | mult-exp {
        printf("expression -> mult-exp\n");
    }
;

mult-exp:
    term MULT mult-exp {
        printf("mult-exp -> term MULT mult-exp\n");
    } | term DIV mult-exp {
        printf("mult-exp -> term DIV mult-exp\n");
    } | term MOD mult-exp {
        printf("mult-exp -> term MOD mult-exp\n");
    } | term {
        printf("mult-exp -> term\n");
    }
;

term:
    var {
        printf("term -> var\n");
    } | number {
        printf("term -> number\n");
    } | L_PAREN expression R_PAREN {
        printf("term -> L_PAREN expression R_PAREN\n");
    } | SUB var {
        printf("term -> SUB var\n");
    } | SUB number {
        printf("term -> SUB number\n");
    } | SUB L_PAREN expression R_PAREN {
        printf("term -> SUB L_PAREN expression R_PAREN\n");
    } | ident L_PAREN expressions R_PAREN {
        printf("term -> ident L_PAREN expressions R_PAREN\n");
    } | ident L_PAREN R_PAREN {
        printf("term -> ident L_PAREN R_PAREN\n");
    }
;

vars:
    var COMMA vars {
        printf("vars -> var COMMA vars\n");
    } | var {
        printf("vars -> var\n");
    } 
;

var:
    ident {
        printf("var -> ident\n");
    } | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
        printf("var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");
    }
;

idents:
    ident COMMA idents {
        printf("idents -> ident COMMA idents\n");
    } | ident {
        printf("idents -> ident\n");
    }
;

ident:
    IDENT {
        printf("ident -> IDENT %s\n", $1);
    }
;

number:
    NUMBER {
        printf("number -> NUMBER\n");
    }
;

%%

int yyerror(const char *msg) {
    printf("Error at line %d, column %d: ", line, column);
    printf("%s\n", msg);
}

int main(int argc, char** argv) {
    if (argc > 1 && freopen(argv[1], "r", stdin) == 0) {
        fprintf(stderr, "%s: File %s cannot be opened.\n", argv[0], argv[1]);
        return 1;
    }

    yyparse();
    return 0;
}

