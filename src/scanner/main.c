#include <stdio.h>

extern int yylex();
extern FILE *yyin;

int main(int argc, char **argv)
{
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror(argv[1]);
            return 1;
        }
    }
    while (yylex() != 0)
        ;
    return 0;
}