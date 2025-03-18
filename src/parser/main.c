#include <stdio.h>

#include "parse_tree.h"

extern void yyrestart(FILE *);
extern int yyparse();
// extern int yydebug;

extern char has_lexical_error;
extern char has_syntax_error;

pt_node_t *parse_tree;
char error_printed[256] = {0};

int main(int argc, char **argv)
{
    if (argc <= 1) {
        return 1;
    }

    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror(argv[1]);
        return 1;
    }
    yyrestart(f);
    // yydebug = 1;
    yyparse();

    if (has_lexical_error || has_syntax_error) {
        return 1;
    } else {
        print_pt(parse_tree);
        // printf("%p->%p\n", &parse_tree, parse_tree);
        free_pt(parse_tree);
        return 0;
    }
}