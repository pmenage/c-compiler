#include "utils.h"

#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>

int is_in_function = 0;

struct expr * global_symbols = NULL;

struct expr * local_symbols = NULL;

struct label * labels = NULL;

struct arg * expr_to_arg(struct expr * expr) {
	struct arg * arg = malloc(sizeof(struct arg));
	arg->expr = expr;
	arg->next = NULL;
	return arg;
}

char * new_var(char * nom_variable) {
	char * var;
	static int i = 0;
	i++;
	asprintf(&var, "%%%s%d", nom_variable, i);
	return var;
}

char * new_type(int type) {
	char * t;
	if (type == 0)
		asprintf(&t, "i32");
	else if (type == 1)
		asprintf(&t, "float");
	else
		asprintf(&t, "void");
	return t;
}

char * new_global_var(char * nom_variable) {
	char * var = new_var(nom_variable);
	var[0] = '@';
	return var;
}

struct expr * emit_expression_identifier(struct expr * element) {
    element->var = new_var("identifier");
    char * t = new_type(element->type);
    printf("\t%s = load %s, %s* %s\n", element->var, t, t, element->name_asm);
    return element;
}

struct expr * emit_expression_int(int i) {
	struct expr * e = malloc(sizeof(struct expr));
	asprintf(&e->var, "%d", i);
	e->type = 0;
	e->next = NULL;
	return e;
}

struct expr * emit_expression_float(double d) {
	struct expr * e = malloc(sizeof(struct expr));
	asprintf(&e->var, "%f", d);
	e->type = 1;
	e->next = NULL;
	return e;
}

struct expr * emit_expression(char * op, struct expr * e1, struct expr * e2) {
    if (e1->type != e2->type) {
    	fprintf(stderr, "%s and %s have different types\n", e1->var, e2->var);
    	abort();
    }
    struct expr * e = malloc(sizeof(struct expr));
    e->var = new_var(op);
    e->next = NULL;
    char * t = new_type(e1->type);
    printf("\t%s = %s %s %s, %s\n", e->var, op, t, e1->var, e2->var);
    return e;
}

struct expr * emit_expression_postfix(char * op, struct expr * expr) {
    struct expr * e = malloc(sizeof(struct expr));
    e->var = new_var(op);
    e->next = NULL;
    char * t = new_type(expr->type);
    printf("\t%s = %s %s %s, 1\n", e->var, op, t, expr->var);
    
    // Utile ou pas ? Sinon pas de store
    printf("\tstore %s %s, %s* %s\n", t, e->var, t, expr->name_asm);
    
    return e;
}

struct expr * emit_expression_comp(char * op, struct expr * e1, struct expr * e2) {
    if (e1->type != e2->type) {
    	fprintf(stderr, "%s and %s have different types\n", e1->var, e2->var);
    	abort();
    }
    struct expr * e = malloc(sizeof(struct expr));
    e->var = new_var(op);
    e->next = NULL;
    char c;
    if (e->type == TYPE_INT) {
    	c = 'i';
    } else {
    	c = 'f';
    }
    char * t = new_type(e1->type);
    printf("\t%s = %ccmp %s %s %s, %s\n", e->var, c, op, t, e1->var, e2->var);
    return e;
}

struct label * buffer_new_label(char * name) {
	struct label * label = malloc(sizeof(struct label));
	label->name = new_var(name);
	label->next = labels;
	return labels = label;
}

void drop_buffered_label() {
	struct label * to_delete = labels;
    labels = labels->next;
    free(to_delete);
}

void jump_to_label(struct label * label) {
	printf("\tbr label %s\n", label->name);
}

void emit_buffered_label() {
	// TODO : Attention s'il y a return dans le if - déjà fait terminating statement, pas le droit d'en caler un suivant
	printf("%s:\n", &labels->name[1]);
	drop_buffered_label();
}

void emit_boolean_branch(struct expr * expr, struct label * truelabel, struct label * falselabel) {
	printf("\tbr i1 %s, label %s, label %s\n",
        expr->var, truelabel->name, falselabel->name);
}