%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #include "parser.h"
    #include "parse_tree.h"

    extern char error_printed[256];

    int yycolumn = 1;
    #define YY_USER_ACTION \
        yylloc.first_line = yylloc.last_line = yylineno; \
        yylloc.first_column = yycolumn; \
        yycolumn += yyleng; \
        yylloc.last_column = yycolumn - 1;
    
    char has_lexical_error = 0;

    pt_semantic_val_t pt_sval;
%}

%option yylineno

digit   [0-9]
digitnz [1-9]
letter  [a-zA-Z_]
alnum   [a-zA-Z0-9_]

id {letter}{alnum}*

dec 0|{digitnz}{digit}*
oct 0[0-7]+
hex 0[xX][0-9a-fA-F]+

error_dec [1-9]{alnum}*
error_oct 0{alnum}+
error_hex 0[xX]{alnum}*

exp [eE][+-]?{digit}+
deci_with_exp {digit}*\.?{digit}+|{digit}+\.
deci_without_exp {digit}*\.{digit}+|{digit}+\.
float {deci_with_exp}{exp}|{deci_without_exp}
/* i.e. ([0-9]*\.?[0-9]+|[0-9]+\.)([eE][+-]?[0-9]+)|([0-9]*\.[0-9]+|[0-9]+\.) */

error_float_1 {digit}+{letter}{alnum}*\.{alnum}*
error_float_2 {digit}+\.{letter}{alnum}*
error_float_3 {digit}*\.{digit}+{letter}{alnum}*
error_float_4 {deci_without_exp}[eE][+-]?({digit}*{letter}{alnum}*)?

error_float {error_float_1}|{error_float_2}|{error_float_3}|{error_float_4}

%x LINE_COMMENT
%x BLOCK_COMMENT

%%

"//" {
    BEGIN LINE_COMMENT;
    #ifdef __SCANNER_DEBUG
    printf("LINE_COMMENT_START\n");
    #endif
}

<LINE_COMMENT>(.|\n) {
    if (*yytext == '\n') {
        BEGIN INITIAL;
        #ifdef __SCANNER_DEBUG
        printf("LINE_COMMENT_END\n");
        #endif
    }
}

"/*" {
    BEGIN BLOCK_COMMENT;
    #ifdef __SCANNER_DEBUG
    printf("BLOCK_COMMENT_START\n");
    #endif
}

<BLOCK_COMMENT>"*/" {
    BEGIN INITIAL;
    #ifdef __SCANNER_DEBUG
    printf("BLOCK_COMMENT_END\n");
    #endif
}

<BLOCK_COMMENT>(.|\n) {}

[\t\r ] {}

\n {
    yycolumn = 1;
}

{dec}|{oct}|{hex} {
    int strtol_res = (int) strtol(yytext, NULL, 0);

    #ifdef __SCANNER_DEBUG
    printf("INT: %d\n", strtol_res);
    #endif

    pt_sval.int_val = strtol_res;
    yylval.pnode = make_pt_token_val(INT, pt_sval);
    return INT;
}

{float} {
    #ifdef __SCANNER_DEBUG
    printf("FLOAT: %f\n", atof(yytext));
    #endif

    pt_sval.float_val = atof(yytext);
    yylval.pnode = make_pt_token_val(FLOAT, pt_sval);
    return FLOAT;
}

{error_hex} {
    if (!error_printed[yylineno]) {
        printf("Error type A at Line %d: Invalid hexadecimal literal \'%s\'.\n", yylineno, yytext);
        error_printed[yylineno] = 1;
    }

    has_lexical_error = 1;
    pt_sval.int_val = 0;
    yylval.pnode = make_pt_token_val(INT, pt_sval);
    return INT;
}

{error_oct} {
    if (!error_printed[yylineno]) {
        printf("Error type A at Line %d: Invalid octal literal \'%s\'.\n", yylineno, yytext);
        error_printed[yylineno] = 1;
    }

    has_lexical_error = 1;
    pt_sval.int_val = 0;
    yylval.pnode = make_pt_token_val(INT, pt_sval);
    return INT;
}

{error_dec} {
    if (!error_printed[yylineno]) {
        printf("Error type A at Line %d: Invalid decimal literal \'%s\'.\n", yylineno, yytext);
        error_printed[yylineno] = 1;
    }

    has_lexical_error = 1;
    pt_sval.int_val = 0;
    yylval.pnode = make_pt_token_val(INT, pt_sval);
    return INT;
}

{error_float} {
    if (!error_printed[yylineno]) {
        printf("Error type A at Line %d: Invalid floating point literal \'%s\'.\n", yylineno, yytext);
        error_printed[yylineno] = 1;
    }

    has_lexical_error = 1;
    pt_sval.float_val = 0.0;
    yylval.pnode = make_pt_token_val(FLOAT, pt_sval);
    return FLOAT;
}

";" {
    #ifdef __SCANNER_DEBUG
    printf("SEMI\n");
    #endif

    yylval.pnode = make_pt_token(SEMI);
    return SEMI;
}

"," {
    #ifdef __SCANNER_DEBUG
    printf("COMMA\n");
    #endif

    yylval.pnode = make_pt_token(COMMA);
    return COMMA;
}

"=" {
    #ifdef __SCANNER_DEBUG
    printf("ASSIGNOP\n");
    #endif

    yylval.pnode = make_pt_token(ASSIGNOP);
    return ASSIGNOP;
}

">"|"<"|">="|"<="|"=="|"!=" {
    #ifdef __SCANNER_DEBUG
    printf("RELOP\n");
    #endif

    yylval.pnode = make_pt_token(RELOP);
    return RELOP;
}

"+" {
    #ifdef __SCANNER_DEBUG
    printf("PLUS\n");
    #endif

    yylval.pnode = make_pt_token(PLUS);
    return PLUS;
}

"-" {
    #ifdef __SCANNER_DEBUG
    printf("MINUS\n");
    #endif

    yylval.pnode = make_pt_token(MINUS);
    return MINUS;
}

"*" {
    #ifdef __SCANNER_DEBUG
    printf("STAR\n");
    #endif

    yylval.pnode = make_pt_token(STAR);
    return STAR;
}

"/" {
    #ifdef __SCANNER_DEBUG
    printf("DIV\n");
    #endif

    yylval.pnode = make_pt_token(DIV);
    return DIV;
}

"&&" {
    #ifdef __SCANNER_DEBUG
    printf("AND\n");
    #endif

    yylval.pnode = make_pt_token(AND);
    return AND;
}

"||" {
    #ifdef __SCANNER_DEBUG
    printf("OR\n");
    #endif

    yylval.pnode = make_pt_token(OR);
    return OR;
}

"." {
    #ifdef __SCANNER_DEBUG
    printf("DOT\n");
    #endif

    yylval.pnode = make_pt_token(DOT);
    return DOT;
}

"!" {
    #ifdef __SCANNER_DEBUG
    printf("NOT\n");
    #endif

    yylval.pnode = make_pt_token(NOT);
    return NOT;
}

"int"|"float" {
    #ifdef __SCANNER_DEBUG
    printf("TYPE: %s\n", yytext);
    #endif

    pt_sval.str_val = strdup(yytext);
    yylval.pnode = make_pt_token_val(TYPE, pt_sval);
    return TYPE;
}

"(" {
    #ifdef __SCANNER_DEBUG
    printf("LP\n");
    #endif

    yylval.pnode = make_pt_token(LP);
    return LP;
}

")" {
    #ifdef __SCANNER_DEBUG
    printf("RP\n");
    #endif

    yylval.pnode = make_pt_token(RP);
    return RP;
}

"[" {
    #ifdef __SCANNER_DEBUG
    printf("LB\n");
    #endif

    yylval.pnode = make_pt_token(LB);
    return LB;
}

"]" {
    #ifdef __SCANNER_DEBUG
    printf("RB\n");
    #endif

    yylval.pnode = make_pt_token(RB);
    return RB;
}

"{" {
    #ifdef __SCANNER_DEBUG
    printf("LC\n");
    #endif

    yylval.pnode = make_pt_token(LC);
    return LC;
}

"}" {
    #ifdef __SCANNER_DEBUG
    printf("RC\n");
    #endif

    yylval.pnode = make_pt_token(RC);
    return RC;
}

"struct" {
    #ifdef __SCANNER_DEBUG
    printf("STRUCT\n");
    #endif

    yylval.pnode = make_pt_token(STRUCT);
    return STRUCT;
}

"return" {
    #ifdef __SCANNER_DEBUG
    printf("RETURN\n");
    #endif

    yylval.pnode = make_pt_token(RETURN);
    return RETURN;
}

"if" {
    #ifdef __SCANNER_DEBUG
    printf("IF\n");
    #endif

    yylval.pnode = make_pt_token(IF);
    return IF;
}

"else" {
    #ifdef __SCANNER_DEBUG
    printf("ELSE\n");
    #endif

    yylval.pnode = make_pt_token(ELSE);
    return ELSE;
}

"while" {
    #ifdef __SCANNER_DEBUG
    printf("WHILE\n");
    #endif

    yylval.pnode = make_pt_token(WHILE);
    return WHILE;
}

{id} {
    #ifdef __SCANNER_DEBUG
    printf("ID: %s\n", yytext);
    #endif

    pt_sval.str_val = strdup(yytext);
    yylval.pnode = make_pt_token_val(ID, pt_sval);
    return ID;
}

. {
    if (!error_printed[yylineno]) {
        printf("Error type A at Line %d: Mysterious characters \'%s\'.\n", yylineno, yytext);
        error_printed[yylineno] = 1;
    }

    has_lexical_error = 1;
}

%%