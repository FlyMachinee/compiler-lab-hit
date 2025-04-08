#ifndef __PARSE_TREE_H_INCLUDED__
#define __PARSE_TREE_H_INCLUDED__

#include "parser.h"

union pt_semantic_val {
    int int_val;
    float float_val;
    char *str_val;
};

typedef union pt_semantic_val pt_semantic_val_t;

struct pt_node {
    char is_token;

    yytoken_kind_t token;
    pt_semantic_val_t token_val;

    const char *name;
    int children_count;
    struct pt_node **children;

    int first_line;
};

typedef struct pt_node pt_node_t;

pt_node_t *make_pt_node(const char *name, int first_line, int children_count, ...);
pt_node_t *make_pt_token_val(yytoken_kind_t token, pt_semantic_val_t token_val);
pt_node_t *make_pt_token(yytoken_kind_t token);

void print_pt(pt_node_t *root);
void free_pt(pt_node_t *root);

#endif /* !__PARSE_TREE_H_INCLUDED__ */