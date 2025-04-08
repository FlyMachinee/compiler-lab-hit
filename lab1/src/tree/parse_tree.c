#include <memory.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parse_tree.h"

pt_node_t **vmake_pt_node_list(int count, va_list args);
void print_pt_helper(pt_node_t *root, int depth);
const char *get_token_name(yytoken_kind_t token);

pt_node_t *make_pt_node(const char *name, int first_line, int children_count, ...)
{
    pt_node_t *node = (pt_node_t *)malloc(sizeof(pt_node_t));

    node->is_token = 0;
    node->name = name;
    node->first_line = first_line;

    node->children_count = children_count;

    va_list args;
    va_start(args, children_count);
    node->children = vmake_pt_node_list(children_count, args);
    va_end(args);

    // printf("make_pt_node: %s\n", name);
    // for (int i = 0; i < children_count; i++) {
    //     printf("  [%d]->%s\n", i, node->children[i]->is_token ? get_token_name(node->children[i]->token) : node->children[i]->name);
    // }

    return node;
}

pt_node_t *make_pt_token_val(yytoken_kind_t token, pt_semantic_val_t token_val)
{
    pt_node_t *node = (pt_node_t *)malloc(sizeof(pt_node_t));

    // printf("make_pt_token_val: %s\n", get_token_name(token));

    node->is_token = 1;
    node->token = token;
    node->token_val = token_val;

    node->name = NULL;
    node->children_count = 0;
    node->children = NULL;

    return node;
}

pt_node_t *make_pt_token(yytoken_kind_t token)
{
    pt_node_t *node = (pt_node_t *)malloc(sizeof(pt_node_t));

    // printf("make_pt_token: %s\n", get_token_name(token));

    node->is_token = 1;
    node->token = token;

    node->name = NULL;
    node->children_count = 0;
    node->children = NULL;

    return node;
}

void print_pt(pt_node_t *root)
{
    print_pt_helper(root, 0);
}

void free_pt(pt_node_t *root)
{
    if (!root) {
        return;
    }

    if (root->is_token) {
        if (root->token == ID || root->token == TYPE) {
            free(root->token_val.str_val);
        }
        free(root);
    } else {
        for (int i = 0; i < root->children_count; i++) {
            free_pt(root->children[i]);
        }
        free(root->children);
        free(root);
    }
}

pt_node_t **vmake_pt_node_list(int count, va_list args)
{
    pt_node_t **list = (pt_node_t **)malloc(count * sizeof(pt_node_t *));

    for (int i = 0; i < count; i++) {
        list[i] = va_arg(args, pt_node_t *);
    }

    return list;
}

void print_pt_helper(pt_node_t *root, int depth)
{
    if (!root) {
        return;
    }

    if (!root->is_token && root->children_count == 0) {
        return;
    }

    // printf("%2d: ", depth);
    for (int i = 0; i < depth; i++) {
        printf("  ");
    }

    if (root->is_token) {
        printf("%s", get_token_name(root->token));
        switch (root->token) {
        case INT:
            printf(": %d", root->token_val.int_val);
            break;
        case FLOAT:
            printf(": %f", root->token_val.float_val);
            break;
        case ID:
        case TYPE:
            printf(": %s", root->token_val.str_val);
            break;
        }
        putchar('\n');
    } else {
        printf("%s (%d)\n", root->name, root->first_line);
        for (int i = 0; i < root->children_count; i++) {
            print_pt_helper(root->children[i], depth + 1);
        }
    }
}

const char *get_token_name(yytoken_kind_t token)
{
    switch (token) {
    case INT:
        return "INT";
    case FLOAT:
        return "FLOAT";
    case ID:
        return "ID";
    case SEMI:
        return "SEMI";
    case COMMA:
        return "COMMA";
    case ASSIGNOP:
        return "ASSIGNOP";
    case RELOP:
        return "RELOP";
    case PLUS:
        return "PLUS";
    case MINUS:
        return "MINUS";
    case STAR:
        return "STAR";
    case DIV:
        return "DIV";
    case AND:
        return "AND";
    case OR:
        return "OR";
    case DOT:
        return "DOT";
    case NOT:
        return "NOT";
    case TYPE:
        return "TYPE";
    case LP:
        return "LP";
    case RP:
        return "RP";
    case LB:
        return "LB";
    case RB:
        return "RB";
    case LC:
        return "LC";
    case RC:
        return "RC";
    case STRUCT:
        return "STRUCT";
    case RETURN:
        return "RETURN";
    case IF:
        return "IF";
    case ELSE:
        return "ELSE";
    case WHILE:
        return "WHILE";
    case YYerror:
        return "ERROR";
    default:
        return "UNKNOWN";
    }
}