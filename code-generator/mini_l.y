/*
Ishan Agrawal
iagra001@ucr.edu
*/

%{
    #include <stdio.h>
    #include <list>
    #include <vector>
    #include <map>
    using namespace std;

    /* externals */
    extern int line;
    extern int column;
    extern int yylex();

    /* defines */
    enum type {
        function_t,
        scalar_t,
        array_t
    };

    /* functions */
    int yyerror(const char *);
    int main(int, char**);
    void declare(type, int);
    string gentemp();
    void checkdef(string);
    void checktype(string, type);

    /* globals */
    int readin;
    int loopval = 0;
    int tempval = 0;
    bool errored = 0;
    map<string,type> functions;
    map<string,type> variables;
    map<string,int>  arraysz;
    vector<string> symbols;
    vector<int> loops;
    vector<string> mil;
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
    function program | %empty {
        if (functions.find("main") == functions.end()) {
            fprintf(stderr, "error at line %d: no main function defined\n", line);
            errored = 1;
        }
        if (!errored) {
            for (int i = 0; i < mil.size(); i++)
                printf("%s\n", mil[i].c_str());
        }
    }
;

function:
    funcstart begparams declarations END_PARAMS beglocals declarations END_LOCALS BEGIN_BODY statements END_BODY {
        mil.push_back("endfunc\n");
        variables.clear();
        symbols.clear();
    } | error {
        errored = 1; yyerrok; yyclearin;
    }
;

funcstart:
    FUNCTION ident SEMICOLON {
        declare(function_t, 1);
    } | error {
        errored = 1; yyerrok; yyclearin;
    }
;

begparams:
    BEGIN_PARAMS {
        readin = 0;
    }
;

beglocals:
    BEGIN_LOCALS {
        readin = -1;
    }
;

declarations:
    declaration SEMICOLON declarations | %empty
;

declaration:
    idents COLON INTEGER {
        declare(scalar_t, 1);
    } | idents COLON ARRAY L_SQUARE_BRACKET number R_SQUARE_BRACKET OF INTEGER {
        int sz = stoi(symbols.back());
        symbols.pop_back();
        declare(array_t, sz);
    } | idents COLON ARRAY L_SQUARE_BRACKET SUB number R_SQUARE_BRACKET OF INTEGER {
        int sz = -stoi(symbols.back());
        symbols.pop_back();
        declare(array_t, sz);
    } | error {
        errored = 1; yyerrok; yyclearin;
    }
;

statements:
    statement SEMICOLON statements {
    } | %empty {
    }
;

statement:
    ident ASSIGN expression {
        string src = symbols.back();
        symbols.pop_back();
        string dest = symbols.back();
        symbols.pop_back();
        checkdef(dest);
        checktype(dest, scalar_t);
        mil.push_back("= " + dest + "," + src);
    } | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET ASSIGN expression {
        string src = symbols.back();
        symbols.pop_back();
        string index = symbols.back();
        symbols.pop_back();
        string dest = symbols.back();
        checkdef(dest);
        checktype(dest, array_t);
        symbols.pop_back();
        mil.push_back("[]= " + dest + "," + index + "," + src);
    } | IF bool-exp then statements ENDIF {
        string lab = "__label__" + to_string(loopval++);
        mil.push_back(": " + lab);
    } | IF bool-exp then statements else statements ENDIF {
        string lab = "__label__" + to_string(loopval++);
        mil.push_back(": " + lab);
    } | whilewh bool-exp beginwh statements ENDLOOP {
        int loop = loops.back();
        string leave = "__label__" + to_string(loop);
        string check = "__label__" + to_string(loop+1);
        mil.push_back(":= " + check);
        mil.push_back(": " + leave);
        loops.pop_back();
    } | do BEGINLOOP statements ENDLOOP whiledo bool-exp {
        string pred = symbols.back();
        symbols.pop_back();
        int loop = loops.back();
        string start = "__label__" + to_string(loop);
        mil.push_back("?:= " + start + "," + pred);
        loops.pop_back();
    } | FOREACH ident IN ident beginfe statements ENDLOOP {
        int loop = loops.back();
        string leave = "__label__" + to_string(loop);
        string start = "__label__" + to_string(loop+1);
        mil.push_back(":= " + start);
        mil.push_back(": " + leave);
        loops.pop_back();
    } | READ vars {
        for (int i = 0; i < symbols.size(); i++) {
            string dest = symbols[i];
            if (dest.find(",") == string::npos)
                mil.push_back(".< " + dest);
            else
                mil.push_back(".[]< " + dest);
        }
        symbols.clear();
    } | WRITE vars {
        for (int i = 0; i < symbols.size(); i++) {
            string src = symbols[i];
            if (src.find(",") == string::npos)
                mil.push_back(".> " + src);
            else
                mil.push_back(".[]> " + src);
        }
        symbols.clear();
    } | CONTINUE {
        if (loops.size() == 0) {
            fprintf(stderr, "error at line %d: continue used outside of loop\n", line);
            errored = 1;
        }
        else {
            string check = "__label__" + to_string(loops.back()+1);
            mil.push_back(":= " + check);
        }
    } | RETURN expression {
        string name = symbols.back();
        symbols.pop_back();
        mil.push_back("ret " + name);
    } | error {
        errored = 1; yyerrok; yyclearin;
    }
;

do:
    DO {
        loops.push_back(loopval);
        string start = "__label__" + to_string(loopval);
        mil.push_back(": " + start);
        loopval+=2;
    }
;

whiledo:
    WHILE {
        int loop = loops.back();
        string check = "__label__" + to_string(loop+1);
        mil.push_back(": " + check);
    }
;

whilewh:
    WHILE {
        loops.push_back(loopval);
        string check = "__label__" + to_string(loopval+1);
        mil.push_back(": " + check);
        loopval += 2;
    }
;

beginwh:
    BEGINLOOP {
        int loop = loops.back();
        string pred = symbols.back();
        symbols.pop_back();
        string dest = gentemp();
        mil.push_back("! " + dest + "," + pred);
        string leave = "__label__" + to_string(loop);
        mil.push_back("?:= " + leave + "," + dest);
    }
;

beginfe:
    BEGINLOOP {
        string iter = gentemp();
        string len = gentemp();
        string arr = symbols.back();
        checkdef(arr);
        if (variables.find(arr) != variables.end() && variables[arr] != array_t) {
            fprintf(stderr, "error at line %d: attempt to use scalar %s in foreach\n", line, arr.c_str());
            errored = 1;
        }
        symbols.pop_back();
        string id = symbols.back();
        symbols.pop_back();

        // init
        mil.push_back("= " + iter + ",0");
        mil.push_back("= " + len + "," + to_string(arraysz[arr]));

        // for loop begin
        loops.push_back(loopval);
        string start = "__label__" + to_string(loopval+1);
        mil.push_back(": " + start);

        // for loop check
        string leave = "__label__" + to_string(loopval);
        string geq = gentemp();
        mil.push_back(">= " + geq + "," + iter + "," + len);
        mil.push_back("?:= " + leave + "," + geq);

        // create dummy
        mil.push_back(". " + id);
        variables[id] = scalar_t;
        mil.push_back("=[] " + id + "," + arr + "," + iter);
        mil.push_back("+ " + iter + "," + iter + ",1");
        loopval+=2;
    }
;

then:
    THEN {
        string pred = symbols.back();
        symbols.pop_back();
        string lab1 = "__label__" + to_string(loopval++);
        string lab2 = "__label__" + to_string(loopval);
        mil.push_back("?:= " + lab1 + "," + pred);
        mil.push_back(":= " + lab2);
        mil.push_back(": " + lab1);
    }
;

else:
    ELSE {
        string lab2 = "__label__" + to_string(loopval++);
        string lab3 = "__label__" + to_string(loopval);
        mil.push_back(":= " + lab3);
        mil.push_back(": " + lab2);
    }
;

bool-exp:
    bool-exp OR and-exp {
        string src2 = symbols.back();
        symbols.pop_back();
        string src1 = symbols.back();
        symbols.pop_back();
        string dest = gentemp();
        mil.push_back("|| " + dest + "," + src1 + "," + src2);
        symbols.push_back(dest);
    } | and-exp {
    }
;

and-exp:
    and-exp AND relation {
        string src2 = symbols.back();
        symbols.pop_back();
        string src1 = symbols.back();
        symbols.pop_back();
        string dest = gentemp();
        mil.push_back("&& " + dest + "," + src1 + "," + src2);
        symbols.push_back(dest);
    } | relation {
    }
;

relation:
    expression comp expression {
        string src2 = symbols.back();
        symbols.pop_back();
        string cmp = symbols.back();
        symbols.pop_back();
        string src1 = symbols.back();
        symbols.pop_back();
        string dest = gentemp();
        mil.push_back(cmp + " " + dest + "," + src1 + "," + src2);
        symbols.push_back(dest);
    } | TRUE {
        symbols.push_back("1");
    } | FALSE {
        symbols.push_back("0");
    } | L_PAREN bool-exp R_PAREN {
    }
;

comp:
    EQ {
        symbols.push_back("==");
    } | NEQ {
        symbols.push_back("!=");
    } | LT {
        symbols.push_back("<");
    } | GT {
        symbols.push_back(">");
    } | LTE {
        symbols.push_back("<=");
    } | GTE {
        symbols.push_back(">=");
    }
;

expressions:
    expression COMMA expressions {
    } | expression {
        string name = symbols.back();
        symbols.pop_back();
        mil.push_back("param " + name);
    }
;

expression:
    expression ADD mult-exp {
        string src2 = symbols.back();
        symbols.pop_back();
        string src1 = symbols.back();
        symbols.pop_back();
        string dest = gentemp();
        mil.push_back("+ " + dest + "," + src1 + "," + src2);
        symbols.push_back(dest);
    } | expression SUB mult-exp {
        string src2 = symbols.back();
        symbols.pop_back();
        string src1 = symbols.back();
        symbols.pop_back();
        string dest = gentemp();
        mil.push_back("- " + dest + "," + src1 + "," + src2);
        symbols.push_back(dest);
    } | mult-exp {
    }
;

mult-exp:
    mult-exp MULT term {
        string src2 = symbols.back();
        symbols.pop_back();
        string src1 = symbols.back();
        symbols.pop_back();
        string dest = gentemp();
        mil.push_back("* " + dest + "," + src1 + "," + src2);
        symbols.push_back(dest);
    } | mult-exp DIV term {
        string src2 = symbols.back();
        symbols.pop_back();
        string src1 = symbols.back();
        symbols.pop_back();
        string dest = gentemp();
        mil.push_back("/ " + dest + "," + src1 + "," + src2);
        symbols.push_back(dest);
    } | mult-exp MOD term {
        string src2 = symbols.back();
        symbols.pop_back();
        string src1 = symbols.back();
        symbols.pop_back();
        string dest = gentemp();
        mil.push_back("% " + dest + "," + src1 + "," + src2);
        symbols.push_back(dest);
    } | term
;

term:
    var {
    } | number {
    } | L_PAREN expression R_PAREN {
    } | SUB var {
    } | SUB number {
    } | SUB L_PAREN expression R_PAREN {
    } | ident L_PAREN expressions R_PAREN {
        string name = symbols.back();
        if (functions.find(name) == functions.end()) {
            fprintf(stderr, "error at line %d: function %s has not yet been defined\n", line, name.c_str());
            errored = 1;
        }
        symbols.pop_back();
        string dest = gentemp();
        mil.push_back("call " + name + "," + dest);
        symbols.push_back(dest);
    } | ident L_PAREN R_PAREN {
        string name = symbols.back();
        if (functions.find(name) == functions.end()) {
            fprintf(stderr, "error at line %d: function %s has not yet been defined\n", line, name.c_str());
            errored = 1;
        }
        symbols.pop_back();
        string dest = gentemp();
        mil.push_back("call " + name + "," + dest);
        symbols.push_back(dest);
    }
;

vars:
    ident COMMA vars {
        checkdef(symbols.back());
        checktype(symbols.back(), scalar_t);
    } | ident {
        checkdef(symbols.back());
        checktype(symbols.back(), scalar_t);
    } | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET COMMA vars{
        string index = symbols.back();
        symbols.pop_back();
        string arr = symbols.back();
        checkdef(arr);
        checktype(arr, array_t);
        symbols.pop_back();
        symbols.push_back(arr + "," + index);
    } | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
        string index = symbols.back();
        symbols.pop_back();
        string arr = symbols.back();
        checkdef(arr);
        checktype(arr, array_t);
        symbols.pop_back();
        symbols.push_back(arr + "," + index);
    }
;

var:
    ident {
        checktype(symbols.back(), scalar_t);
    } | ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {
        string index = symbols.back();
        symbols.pop_back();
        string src = symbols.back();
        checkdef(src);
        checktype(src, array_t);
        symbols.pop_back();
        string dest = gentemp();
        mil.push_back("=[] " + dest + "," + src + "," + index);
        symbols.push_back(dest);
    }
;

idents:
    ident COMMA idents | ident
;

ident:
    IDENT {
        symbols.push_back($1);
    }
;

number:
    NUMBER {
        symbols.push_back(to_string($1));
    }
;

%%

int yyerror(const char *msg) {
    fprintf(stderr, "error at line %d: %s\n", line, msg);
}

void declare(type t, int sz) {
    if (sz <= 0) {
        fprintf(stderr, "error at line %d: defining array with bad size of %d\n", line, sz);
        errored = 1;
    }
    for (int i = 0; i < symbols.size(); i++) {
        string name = symbols[i];
        if (functions.find(name) != functions.end() || variables.find(name) != variables.end()) {
            fprintf(stderr, "error at line %d: %s is previously defined\n", line, name.c_str());
            errored = 1;
        }
        if (t == function_t) {
            functions[name] = t;
            mil.push_back("func " + name);
        } else if (t == scalar_t) {
            variables[name] = t;
            mil.push_back(". " + name);
            if (readin >= 0) mil.push_back("= " + name + ",$" + to_string(readin++));
        } else {
            arraysz[name] = sz;
            variables[name] = t;
            mil.push_back(".[] " + name + ", " + to_string(sz));
        }
    }
    symbols.clear();
}

void checkdef(string name) {
    if (variables.find(name) == variables.end()) {
        fprintf(stderr, "error at line %d: %s has not yet been defined\n", line, name.c_str());
        errored = 1;
    }
}

void checktype(string name, type t) {
    if (variables.find(name) != variables.end() && variables[name] != t) {
        if (t == array_t)
            fprintf(stderr, "error at line %d: %s is not an array\n", line, name.c_str());
        else
            fprintf(stderr, "error at line %d: %s is missing specified index\n", line, name.c_str());
        errored = 1;
    }
}

string gentemp() {
    string name = "__temp__" + to_string(tempval++);
    mil.push_back(". " + name);
    variables[name] = scalar_t;
    return name;
}

int main(int argc, char** argv) {
    if (argc == 2 && freopen(argv[1], "r", stdin) == 0) {
        fprintf(stderr, "%s: file %s cannot be opened.\n", argv[0], argv[1]);
        return 1;
    }
    yyparse();
    return 0;
}

