%{
    #include <iostream>
    #include <string>
    #include <cstdlib>

    #include "parser.hpp"
    #include "scanner.h"
    #include "driver.h"
    #include "parse_tree.hpp"
    #include "location.hh"
    #include "pt_node_enum.h"

    static my::location loc;

    #define YY_USER_ACTION loc.columns(yyleng);
    #undef yywrap
    #define yywrap() 1

    using namespace my;
    using namespace std;

    #define yyterminate() return parser::make_YYEOF(loc);

    using enum parse_tree_terminal_type;
%}

%option c++
%option noyywrap
%option yyclass="my::scanner"
%option prefix="my_"

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

%{
    loc.step();
%}

"//" {
    BEGIN LINE_COMMENT;
    loc.step();
}

<LINE_COMMENT>(.|\n) {
    if (*yytext == '\n') {
        BEGIN INITIAL;
        loc.lines(1);
    }

    loc.step();
}

"/*" {
    BEGIN BLOCK_COMMENT;
    loc.step();
}

<BLOCK_COMMENT>"*/" {
    BEGIN INITIAL;
    loc.step();
}

<BLOCK_COMMENT>(.|\n) {
    if (*yytext == '\n') {
        loc.lines(1);
    }
    loc.step(); 
}

[\t\r ] { loc.step(); }

\n {
    loc.lines(1);
    loc.step();
}

{dec}|{oct}|{hex} {
    int int_val = (int) strtol(yytext, NULL, 0);
    return parser::make_INT(make_tree(INT, int_val, loc.begin), loc);
}

{float} {
    float float_val = atof(yytext);
    return parser::make_FLOAT(make_tree(FLOAT, float_val, loc.begin), loc);
}

{error_hex} {
    if (!d.error_printed[loc.begin.line]) {
        printf("Error type A at Line %d: Invalid hexadecimal literal \'%s\'.\n", loc.begin.line, yytext);
        d.error_printed[loc.begin.line] = 1;
    }

    d.has_lexical_error = 1;
    int int_val = 0;
    return parser::make_INT(make_tree(INT, int_val, loc.begin), loc);
}

{error_oct} {
    if (!d.error_printed[loc.begin.line]) {
        printf("Error type A at Line %d: Invalid octal literal \'%s\'.\n", loc.begin.line, yytext);
        d.error_printed[loc.begin.line] = 1;
    }

    d.has_lexical_error = 1;
    return parser::make_INT(make_tree(INT, 0, loc.begin), loc);
}

{error_dec} {
    if (!d.error_printed[loc.begin.line]) {
        printf("Error type A at Line %d: Invalid decimal literal \'%s\'.\n", loc.begin.line, yytext);
        d.error_printed[loc.begin.line] = 1;
    }

    d.has_lexical_error = 1;
    return parser::make_INT(make_tree(INT, 0, loc.begin), loc);
}

{error_float} {
    if (!d.error_printed[loc.begin.line]) {
        printf("Error type A at Line %d: Invalid floating point literal \'%s\'.\n", loc.begin.line, yytext);
        d.error_printed[loc.begin.line] = 1;
    }

    d.has_lexical_error = 1;
    return parser::make_FLOAT(make_tree(FLOAT, 0.0f, loc.begin), loc);
}

";" {
    return parser::make_SEMI(make_tree(SEMI, loc.begin), loc);
}

"," {
    return parser::make_COMMA(make_tree(COMMA, loc.begin), loc);
}

"=" {
    return parser::make_ASSIGNOP(make_tree(ASSIGNOP, loc.begin), loc);
}

">"|"<"|">="|"<="|"=="|"!=" {
    return parser::make_RELOP(make_tree(RELOP, loc.begin), loc);
}

"+" {
    return parser::make_PLUS(make_tree(PLUS, loc.begin), loc);
}

"-" {
    return parser::make_MINUS(make_tree(MINUS, loc.begin), loc);
}

"*" {
    return parser::make_STAR(make_tree(STAR, loc.begin), loc);
}

"/" {
    return parser::make_DIV(make_tree(DIV, loc.begin), loc);
}

"&&" {
    return parser::make_AND(make_tree(AND, loc.begin), loc);
}

"||" {
    return parser::make_OR(make_tree(OR, loc.begin), loc);
}

"." {
    return parser::make_DOT(make_tree(DOT, loc.begin), loc);
}

"!" {
    return parser::make_NOT(make_tree(NOT, loc.begin), loc);
}

"int"|"float" {
    return parser::make_TYPE(make_tree(TYPE, std::string(yytext), loc.begin), loc);
}

"(" {
    return parser::make_LP(make_tree(LP, loc.begin), loc);
}

")" {
    return parser::make_RP(make_tree(RP, loc.begin), loc);
}

"[" {
    return parser::make_LB(make_tree(LB, loc.begin), loc);
}

"]" {
    return parser::make_RB(make_tree(RB, loc.begin), loc);
}

"{" {
    return parser::make_LC(make_tree(LC, loc.begin), loc);
}

"}" {
    return parser::make_RC(make_tree(RC, loc.begin), loc);
}

"struct" {
    return parser::make_STRUCT(make_tree(STRUCT, loc.begin), loc);
}

"return" {
    return parser::make_RETURN(make_tree(RETURN, loc.begin), loc);
}

"if" {
    return parser::make_IF(make_tree(IF, loc.begin), loc);
}

"else" {
    return parser::make_ELSE(make_tree(ELSE, loc.begin), loc);
}

"while" {
    return parser::make_WHILE(make_tree(WHILE, loc.begin), loc);
}

{id} {
    return parser::make_ID(make_tree(ID, std::string(yytext), loc.begin), loc);
}

. {
    if (!d.error_printed[loc.begin.line]) {
        printf("Error type A at Line %d: Mysterious characters \'%s\'.\n", loc.begin.line, yytext);
        d.error_printed[loc.begin.line] = 1;
    }

    d.has_lexical_error = 1;
}

%%