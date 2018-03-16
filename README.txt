Compiler that interprets mini_l language and produces intermediate mil code
The parsing grammar is described below

$accept - accept
$end    - end
()      - non-terminal
[]      - terminal

$accept: (program) $end

(program) --> (function) (program)
           |  (function)

(function) --> [function] (ident) [;] [beginparams] (declarations) [endparams] [beginlocals] (declarations) [endlocals] [beginbody] (statements) [endbody]

(declarations) --> (declaration) [;] (declarations)
                |  {epsilon}

(declaration) --> (identifiers) [:] [integer]
               |  (identifiers) [:] [array] [[] [number] []] [of] [integer]

(statements) --> (statement) [;] (statements)
              |  {epsilon}

(statement) --> (var) [:=] (expression)
             |  [if] (bool_exp) [then] (statements) [endif]
             |  [if] (bool_exp) [then] (statements) [else] (statements) [endif]
             |  [while] (bool_exp) [beginloop] (statements) [endloop]
             |  [do] [beginloop] (statements) [endloop] [while] (bool_exp)
             |  [foreach] (ident) [in] (ident) [beginloop] (statements)
             |  [read] (vars)
             |  [write] (vars)
             |  [continue]
             |  [return] (expression)

(expressions) --> (expression) [,] (expressions)
               |  (expression)

(expression) --> (mult_expression)
              |  (mult_expression) [+] (expression)
              |  (mult_expression) [-] (expression)

(mult_expression) --> (term)
                   |  (term) [%] (mult_expression)
                   |  (term) [*] (mult_expression)
                   |  (term) [/] (mult_expression)

(bool_exp) --> (relation_and_exp)
            |  (relation_and_exp) [or] (bool_exp)

(relation_and_exp) --> (relation_exp)
                    |  (relation_exp) [and] (relation_and_exp)

(relation_exp) --> (nots) (expression) (comp) (expression)
                |  (nots) [true]
                |  (nots) [false]
                |  (nots) [(] (bool_exp) [)]

(nots) --> [not] (nots)
        |  {epsilon}

(comp) --> [==]
        |  [<>]
        |  [<]
        |  [>]
        |  [<=]
        |  [>=]

(term) --> (subs) [number]
        |  (subs) (var)
        |  (subs) [(] (expression) [)]
        |  (ident) [(] (expressions) [)]
        |  (ident) [(] [)]

(subs) --> [-]
        |  {epsilon}

(vars) --> (var) [,] (vars)
        |  (var)

(var) --> (ident)
       |  (ident) [[] (expression) []]

(identifiers) --> (ident) [,] (identifiers)
               |  (ident)

(ident): [ident]
