#ifndef __UTILS_H
#define __UTILS_H

extern int is_in_function;

typedef enum type type;

enum type {
    TYPE_INT = 0,
    TYPE_FLOAT = 1,
    TYPE_VOID = 2
};

struct param {
    // TODO type;
    enum type type;
    char * name;
    struct param * next;
};

struct expr {
    enum type type;
    char * name_c;
    char * name_asm;
    struct expr * next;
	char * var;
	struct param * params;
};

struct arg {
    struct expr * expr;
    struct arg * next;
};

struct label {
    char * name;
    struct label * next;
};

extern struct expr * global_symbols;

extern struct expr * local_symbols;

extern struct label * labels;

struct arg * expr_to_arg(struct expr * expr);

char * new_var(char * nom_variable);

char * new_type(int type);

char * new_global_var(char * nom_variable);

struct expr * emit_expression_identifier(struct expr * element);

struct expr * emit_expression_int(int i);

struct expr * emit_expression_float(double d);

struct expr * emit_expression(char * op, struct expr * e1, struct expr * e2);

struct expr * emit_expression_postfix(char * op, struct expr * expr);

struct expr * emit_expression_comp(char * op, struct expr * e1, struct expr * e2);

struct label * buffer_new_label(char * name);

void jump_to_label(struct label * label);

void emit_buffered_label();

void drop_buffered_label();

void emit_boolean_branch(struct expr * expr, struct label * truelabel, struct label * falselabel);

#endif // __UTILS_H
