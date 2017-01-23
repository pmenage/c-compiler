%{
    #define _GNU_SOURCE
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
//     #include "expression_symbols.h"
    #include "utils.h"
    extern int yylineno;
    int yylex ();
    int yyerror ();
    
    // Pour utiliser INT_I et FLOAT_F ?
    #define INT_I 0
    #define FLOAT_F 1
%}

%token <string> IDENTIFIER
%token <n> CONSTANTI
%token <f> CONSTANTF
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN DIV_ASSIGN
%token SHL_ASSIGN SHR_ASSIGN
%token REM_ASSIGN
%token REM SHL SHR
%token AND OR
%token TYPE_NAME
%token INT FLOAT VOID
%token IF ELSE DO WHILE RETURN FOR
%type <expr> primary_expression postfix_expression unary_expression multiplicative_expression additive_expression expression
%type <expr> conditional_expression logical_or_expression logical_and_expression shift_expression comparison_expression
%type <param> parameter_declaration parameter_list optional_parameter_list
%type <t> type_name
%type <arg> argument_expression_list
%start program
%union {
  char * string;
  double f;
  int n;
  struct expr * expr;
  struct param * param;
  int t;
  //enum type t;
  struct arg * arg;
}
%%

conditional_expression
: logical_or_expression
;

logical_or_expression
: logical_and_expression
| logical_or_expression OR logical_and_expression
;

logical_and_expression
: comparison_expression
| logical_and_expression AND comparison_expression
;

shift_expression
: additive_expression   
  /*    {
        if ($1->t == ENTIER)
            printf("Résultat : %d\n", $1->v.n);
        else
            printf("Résultat : %f\n", $1->v.f);
	    } */
| shift_expression SHL additive_expression
| shift_expression SHR additive_expression
;

primary_expression
: IDENTIFIER
{
    $$ = NULL;
    struct expr * element;
    
    for (element = local_symbols; element && !$$; element = element->next) {
        if (strcmp(element->name_c, $1) == 0)
            $$ = emit_expression_identifier(element);
    }   
    for (element = global_symbols; element && !$$; element = element->next) {
        if (strcmp(element->name_c, $1) == 0)
            $$ = emit_expression_identifier(element);
    }
    if (!$$) {
        fprintf(stderr, "no symbol named '%s'", $1);
        abort();
    }
}
| CONSTANTI
{
    $$ = emit_expression_int($1);
}
| CONSTANTF
{
    $$ = emit_expression_float($1);
}
| '(' expression ')'
{
    $$ = $2;
}
| IDENTIFIER '(' ')'
{
    printf("\tcall void @%s()\n", $1);
}
| IDENTIFIER '(' argument_expression_list ')'
{
    // TODO if not void new_var
    
    $$ = NULL;
    struct expr * element;
    for (element = global_symbols; element && !$$; element = element->next) {
        if (strcmp(element->name_c, $1) == 0)
            $$ = element;
    }
    if (!$$) {
        fprintf(stderr, "no function named '%s'", $1);
        abort();
    }
    char * t = new_type($$->type);
    
    struct arg * arg;
    printf("\tcall %s @%s(", t, $1);
    for (arg = $3; arg; arg = arg->next) {
        if (arg->next) {
            printf("%s, ", arg->expr->var);
        } else {
            printf("%s", arg->expr->var);
        }
    }
    printf(")\n");
}
;

postfix_expression
: primary_expression
| postfix_expression INC_OP    
{
    if ($1->type == TYPE_INT) {
        $$ = emit_expression_postfix("add", $1);
    } else {
        $$ = emit_expression_postfix("fadd", $1);
    }
}
| postfix_expression DEC_OP 
{
    if ($1->type == TYPE_INT) {
        $$ = emit_expression_postfix("sub", $1);
    } else {
        $$ = emit_expression_postfix("fsub", $1);
    }
}
;

argument_expression_list
: expression
{
    $$ = expr_to_arg($1);
}
| argument_expression_list ',' expression
{
    struct arg * last = $1;
    while (last->next) { 
        last = last->next;
    }
    last->next = expr_to_arg($3);
}
;

unary_expression
: postfix_expression
| INC_OP unary_expression
{
    if ($2->type == TYPE_INT) {
        emit_expression_postfix("add", $2);
    } else {
        emit_expression_postfix("fadd", $2);
    }
}
| DEC_OP unary_expression
{
    if ($2->type == TYPE_INT) {
        emit_expression_postfix("sub", $2);
    } else {
        emit_expression_postfix("fsub", $2);
    }
}
| unary_operator unary_expression
  /* { 
        if ($$->t == ENTIER) 
            $$ = create_expression_symbol_int(-($2->v.n)); 
        else
            $$ = create_expression_symbol_float(-($2->v.f)); 
	    } */
;

unary_operator
: '-'
;

multiplicative_expression
: unary_expression
| multiplicative_expression '*' unary_expression
{
    if ($1->type == TYPE_INT) {
        $$ = emit_expression("mul", $1, $3);
    } else {
        $$ = emit_expression("fmul", $1, $3);
    }
}
| multiplicative_expression '/' unary_expression
{
    if ($1->type == TYPE_INT) {
        $$ = emit_expression("sdiv", $1, $3);
    } else {
        $$ = emit_expression("fdiv", $1, $3);
    }
}
| multiplicative_expression REM unary_expression
{
    if ($1->type == TYPE_INT) {
        $$ = emit_expression("srem", $1, $3);
    } else {
        fprintf(stderr, "Erreur de type : Modulo pas autorisé avec flottant\n");
        abort();
    }
}
;

additive_expression
: multiplicative_expression
| additive_expression '+' multiplicative_expression
{
    if ($1->type == TYPE_INT) {
        $$ = emit_expression("add", $1, $3);
    } else {
        $$ = emit_expression("fadd", $1, $3);
    }
}
| additive_expression '-' multiplicative_expression
{
    if ($1->type == TYPE_INT) {
        $$ = emit_expression("sub", $1, $3);
    } else {
        $$ = emit_expression("fsub", $1, $3);
    }
}
;

comparison_expression
: shift_expression
| comparison_expression '<' shift_expression
{
    $$ = emit_expression_comp("slt", $1, $3);
}
| comparison_expression '>' shift_expression
{
    $$ = emit_expression_comp("sgt", $1, $3);
}
| comparison_expression LE_OP shift_expression
{
    $$ = emit_expression_comp("sle", $1, $3);
}
| comparison_expression GE_OP shift_expression
{
    $$ = emit_expression_comp("sge", $1, $3);
}
| comparison_expression EQ_OP shift_expression
{
    $$ = emit_expression_comp("eq", $1, $3);
}
| comparison_expression NE_OP shift_expression
{
    $$ = emit_expression_comp("ne", $1, $3);
}
;

expression
: unary_expression assignment_operator conditional_expression
{
    char * t = new_type($1->type);
    printf("\tstore %s %s, %s* %s\n", t, $3->var, t, $1->name_asm);
    asprintf(&$1->var, "%s", $3->var);
}
| conditional_expression
;

assignment_operator
: '='
| MUL_ASSIGN
| DIV_ASSIGN
| REM_ASSIGN
| SHL_ASSIGN
| SHR_ASSIGN
| ADD_ASSIGN
| SUB_ASSIGN
;

declaration
: type_name IDENTIFIER ';' // identifier_list ';'
{
    // TODO : boucle au cas où plusieurs noms de variables à déclarer en une fois
        // Remettre identifier_list
    struct expr * element = malloc(sizeof(struct expr));
    element->name_c = $2;
    if (is_in_function) {
        element->name_asm = new_var(element->name_c);
        element->type = $1;
        char * t = new_type($1);
        element->next = local_symbols; // On ajoute au début
        local_symbols = element; // La tête de liste devient element
        printf("\t%s = alloca %s\n", element->name_asm, t);
    } else {
        element->name_asm = new_global_var(element->name_c);
        element->type = $1;
        char * t = new_type($1);
        element->next = global_symbols;
        global_symbols = element;
        printf("%s = common global %s 0\n", element->name_asm, t);
    }
}
;

/*
identifier_list
: IDENTIFIER
| identifier_list ',' IDENTIFIER
;
*/

type_name
: VOID
{
    $$ = TYPE_VOID;
}
| INT
{
    $$ = TYPE_INT;
}
| FLOAT
{
    $$ = TYPE_FLOAT;
}
;

optional_parameter_list
: '(' parameter_list ')'
{
    $$ = $2;
}
| '(' ')'
{
    $$ = NULL;
}
;

parameter_list
: parameter_declaration
| parameter_list ',' parameter_declaration
{
    struct param * last = $1;
    while (last->next) { 
        last = last->next;
    }
    last->next = $3;
}
;

parameter_declaration
: type_name IDENTIFIER
{
    $$ = malloc(sizeof(struct param));
    $$->name = $2;
    $$->next = NULL;
    $$->type = $1;
}
;

statement
: compound_statement
| expression_statement
| selection_statement
| iteration_statement
| jump_statement
;

compound_statement
: '{' '}'
| '{' declaration_list '}'
| '{' declaration_list statement_list '}'
| '{' statement_list '}'
;

declaration_list
: declaration
| declaration_list declaration
;

statement_list
: statement
| statement_list statement
;

expression_statement
: ';'
| expression ';'
;

selection_statement
: IF condition_if statement
{
    // after no else-branch statement
    // 1) do what else_after_if does (copy-pasted)
    jump_to_label(labels->next);
    emit_buffered_label();
    // 2) jump to endif label
    jump_to_label(labels);
    // 3) emit endif label
    emit_buffered_label();
}
| IF condition_if statement else_after_if statement
{
    // after else-branch statement
    // 1) jump to endif label
    jump_to_label(labels);
    // 2) emit endif label
    emit_buffered_label();
}
| FOR init_for before_for condition_for iteration_for statement
{
    // after body, before end
    // 1) jump to iteration (using duplicated label, dropped from list)
    jump_to_label(labels);
    labels = labels->next;
    // 2) emit end label
    emit_buffered_label();
}
;

condition_if 
: '(' expression ')'
{
    // first detection of the "if" or "if-else" control structure
    // after condition emitted, before if-branch statement
    buffer_new_label("endif");
    struct label * falselabel = buffer_new_label("iffalse");
    struct label * truelabel = buffer_new_label("iftrue");
    // 1) jump to if-branch or else-branch using $2
    emit_boolean_branch($2, truelabel, falselabel);
    // 2) emit if-branch label
    emit_buffered_label();
}
;

else_after_if
: ELSE
{
    // after if-branch statement, before else-branch statement
    // 1) jump to endif label
    jump_to_label(labels->next);
    // 2) emit else-branch label
    emit_buffered_label();
}
;

init_for
: '(' expression
| '('
;

before_for
: ';'
{
    // first detection of the "for" control structure
    // after initializer, before condition
    // 1) Prepare labels (and duplicate some to allow jumping backwards)
    buffer_new_label("endfor");
    struct label * iterationlabel_body = buffer_new_label("foriteration");
    buffer_new_label("forbody");
    struct label * conditionlabel_loop = buffer_new_label("forcondition");
    struct label * iterationlabel_start = buffer_new_label(NULL);
    iterationlabel_start->name = iterationlabel_body->name;
    struct label * conditionlabel_start = buffer_new_label(NULL);
    conditionlabel_start->name = conditionlabel_loop->name;
    // 2) jump to condition-branch
    jump_to_label(labels);
    // 3) emit condition label
    emit_buffered_label();
}
;

condition_for
: expression ';'
{
    // after condition, before iteration (caution: body comes afterwards)
    // 1) jump to body or to end depending on $1
    emit_boolean_branch($1, labels->next->next, labels->next->next->next->next);
    // 2) emit iteration label
    emit_buffered_label();
}
| ';'
{
    // nearly same as above, without expression (infinite loop)
    // 1) jump to body unconditionally
    jump_to_label(labels->next->next);
    // 2) emit iteration label
    emit_buffered_label();
}
;

iteration_for
: expression ')'
{
    // after iteration, before body
    // 1) jump to condition (using duplicated label, dropped from list)
    jump_to_label(labels);
    labels = labels->next;
    // 2) emit body label
    emit_buffered_label();
}
| ')'
{
    // same as above (iteration omitted, but we don't care, copy-paste)
    // 1) jump to condition (using duplicated label, dropped from list)
    jump_to_label(labels);
    labels = labels->next;
    // 2) emit body label
    emit_buffered_label();
}
;

iteration_statement
: before_while condition_while statement
{
    // after body
    // 1) jump to condition (using duplicated label, dropped from list)
    jump_to_label(labels);
    labels = labels->next;
    // 2) emit end label
    emit_buffered_label();
}
| DO statement WHILE '(' expression ')' 
;

before_while
: WHILE '('
{
    // first detection of the "while" control structure
    // before expression
    // 1) prepare labels
    buffer_new_label("endwhile");
    struct label * conditionlabel_body = buffer_new_label("whilecondition");
    buffer_new_label("whilebody");
    struct label * conditionlabel_start = buffer_new_label(NULL);
    conditionlabel_start->name = conditionlabel_body->name;
    // 2) jump to condition
    jump_to_label(labels);
    // 3) emit condition label
    emit_buffered_label();
}
;

condition_while
: expression ')'
{
    // after condition, before body
    // 1) jump to body or end depending on $1
    emit_boolean_branch($1, labels, labels->next->next);
    // 2) emit body label
    emit_buffered_label();
}
;

jump_statement
: RETURN ';'
| RETURN expression ';'
;

program
: external_declaration
| program external_declaration
;

external_declaration
: function_definition
| declaration
;

function_definition
: function_definition_header compound_statement
{
    // TODO : gérer ret pour autre chose que void
    /*
    struct expr * element;
    struct expr * e1 = NULL;
    for (element = global_symbols; element && !e1; element = element->next) {
        if (strcmp(element->name_c, $1) == 0)
            e1 = element;
    }
    if (!e1) {
        fprintf(stderr, "no function named '%s'", $1);
        abort();
    }*/
    
    // char * t = new_type(e1->type);
    
    is_in_function = 0;
    while (local_symbols) {
        struct expr * to_delete = local_symbols;
        local_symbols = local_symbols->next;
        free(to_delete);
    }
    printf("\tret void\n");
    printf("}\n");
}
;

function_definition_header
: type_name IDENTIFIER optional_parameter_list
{
    // TODO : gérer type de retour de la fonction
    struct expr * element = malloc(sizeof(struct expr));
    element->name_c = $2;
    element->type = $1;
    element->next = global_symbols;
    global_symbols = element;
    
    is_in_function = 1;
    struct param * param;
    char * t = new_type($1);
    printf("define %s @%s(", t, $2);
    for (param = $3; param; param = param->next) {
        if (param->next) {
            t = new_type(param->type);
            printf("%s %s, ", t, param->name);
        } else {
            t = new_type(param->type);
            printf("%s %s", t, param->name);
        }
    }
    printf(") {\n");
}
;

%%
#include <stdio.h>
#include <string.h>

extern char yytext[];
extern int column;
extern int yylineno;
extern FILE *yyin;

char *file_name = NULL;

int yyerror (char *s) {
    fflush (stdout);
    fprintf (stderr, "%s:%d:%d: %s\n", file_name, yylineno, column, s);
    return 0;
}


int main (int argc, char *argv[]) {
    FILE *input = NULL;
    if (argc==2) {
	input = fopen (argv[1], "r");
	file_name = strdup (argv[1]);
	if (input) {
	    yyin = input;
	}
	else {
	  fprintf (stderr, "%s: Could not open %s\n", *argv, argv[1]);
	    return 1;
	}
    }
    else {
	fprintf (stderr, "%s: error: no input file\n", *argv);
	return 1;
    }
    // printf("declare void @rect(double, double, double, double)\n");
    yyparse ();
    free (file_name);
    return 0;
}
