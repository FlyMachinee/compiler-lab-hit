%skeleton "lalr1.cc"
%require "3.8.1"
%header

%define api.token.raw
%define api.token.constructor
%define api.value.type variant
%define parse.assert
%define api.namespace { my }
%define api.parser.class { parser }
%defines
%locations
%define parse.error verbose

%code requires {
    #include <memory>

    namespace my {
        class driver;
    }
    #include "parse_tree.hpp"
}

%code top {
    #include <iostream>
    #include "driver.h"
    #include "location.hh"
    #include "pt_node_enum.h"

    my::parser::symbol_type yylex(my::driver &d) {
        return d.s.next_token(d);
    }

    using namespace my;
    using enum my::parse_tree_terminal_type;
    using enum my::parse_tree_nonterminal_type;
}

%param { my::driver &d }


/* Terminal symbols */

%token <parse_tree> INT      "integer literal"
%token <parse_tree> FLOAT    "floating point literal"
%token <parse_tree> ID       "identifier"
%token <parse_tree> SEMI     ";"
%token <parse_tree> COMMA    ","
%token <parse_tree> ASSIGNOP "="
%token <parse_tree> RELOP    "relational operator"
%token <parse_tree> PLUS     "+"
%token <parse_tree> MINUS    "-"
%token <parse_tree> STAR     "*"
%token <parse_tree> DIV      "/"
%token <parse_tree> AND      "&&"
%token <parse_tree> OR       "||"
%token <parse_tree> DOT      "."
%token <parse_tree> NOT      "!"
%token <parse_tree> TYPE     "type"
%token <parse_tree> LP       "("
%token <parse_tree> RP       ")"
%token <parse_tree> LB       "["
%token <parse_tree> RB       "]"
%token <parse_tree> LC       "{"
%token <parse_tree> RC       "}"
%token <parse_tree> STRUCT   "struct"
%token <parse_tree> RETURN   "return"
%token <parse_tree> IF       "if"
%token <parse_tree> ELSE     "else"
%token <parse_tree> WHILE    "while"


/* Precedence and Asssociativity */

%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT UMINUS
%left DOT LB RB LP RP


/* Fake tokens */

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


/* Non-terminal symbols */

%type <parse_tree> ExtDefList
%type <parse_tree> ExtDef
%type <parse_tree> ExtDecList
%type <parse_tree> Specifier
%type <parse_tree> StructSpecifier
%type <parse_tree> OptTag
%type <parse_tree> Tag
%type <parse_tree> VarDec
%type <parse_tree> FunDec
%type <parse_tree> VarList
%type <parse_tree> ParamDec
%type <parse_tree> CompSt
%type <parse_tree> StmtList
%type <parse_tree> Stmt
%type <parse_tree> DefList
%type <parse_tree> Def
%type <parse_tree> DecList
%type <parse_tree> Dec
%type <parse_tree> Exp
%type <parse_tree> Args


/* Start symbol */

%start Program

%%


/* High-level Definitions */

Program: ExtDefList { d.pt = make_tree(S_Program, @1.begin, $1); }
    ;

ExtDefList: ExtDef ExtDefList { $$ = make_tree(S_ExtDefList, @1.begin, $1, $2); }
    | /* empty */             { $$ = make_tree(S_ExtDefList); }
    ;

ExtDef: Specifier ExtDecList SEMI { $$ = make_tree(S_ExtDef, @1.begin, $1, $2, $3); }
    | Specifier SEMI              { $$ = make_tree(S_ExtDef, @1.begin, $1, $2); }
    | Specifier FunDec CompSt     { $$ = make_tree(S_ExtDef, @1.begin, $1, $2, $3); }
    | error SEMI                  { $$ = make_tree(S_ExtDef, @1.begin, make_tree(YYerror)), $2; }
    ;

ExtDecList: VarDec              { $$ = make_tree(S_ExtDecList, @1.begin, $1); }
    | VarDec COMMA ExtDecList   { $$ = make_tree(S_ExtDecList, @1.begin, $1, $2, $3); }
    | error COMMA ExtDecList    { $$ = make_tree(S_ExtDecList, @1.begin, make_tree(YYerror)), $2, $3; }
    | error                     { $$ = make_tree(S_ExtDecList, @1.begin, make_tree(YYerror)); }
    ;


/* Specifiers */

Specifier: TYPE       { $$ = make_tree(S_Specifier, @1.begin, $1); }
    | StructSpecifier { $$ = make_tree(S_Specifier, @1.begin, $1); }
    ;

StructSpecifier: STRUCT OptTag LC DefList RC 
                 { $$ = make_tree(S_StructSpecifier, @1.begin, $1, $2, $3, $4, $5); }
    | STRUCT Tag { $$ = make_tree(S_StructSpecifier, @1.begin, $1, $2); }
    ;

OptTag: ID        { $$ = make_tree(S_OptTag, @1.begin, $1); }
    | /* empty */ { $$ = make_tree(S_OptTag); }
    ;

Tag: ID { $$ = make_tree(S_Tag, @1.begin, $1); }
    ;


/* Declarators */

VarDec: ID             { $$ = make_tree(S_VarDec, @1.begin, $1); }
    | VarDec LB INT RB { $$ = make_tree(S_VarDec, @1.begin, $1, $2, $3, $4); }
    ;

FunDec: ID LP VarList RP { $$ = make_tree(S_FunDec, @1.begin, $1, $2, $3, $4); }
    | ID LP RP           { $$ = make_tree(S_FunDec, @1.begin, $1, $2, $3); }
    | ID LP error RP     { $$ = make_tree(S_FunDec, @1.begin, $1, $2, make_tree(YYerror)), $4; }
    ;

VarList: ParamDec COMMA VarList { $$ = make_tree(S_VarList, @1.begin, $1, $2, $3); }
    | ParamDec                  { $$ = make_tree(S_VarList, @1.begin, $1); }
    | error COMMA VarList       { $$ = make_tree(S_VarList, @1.begin, make_tree(YYerror)), $2, $3; }
    ;

ParamDec: Specifier VarDec { $$ = make_tree(S_ParamDec, @1.begin, $1, $2); }
    ;


/* Statements */

CompSt: LC DefList StmtList RC { $$ = make_tree(S_CompSt, @1.begin, $1, $2, $3, $4); }
    ;

StmtList: Stmt StmtList { $$ = make_tree(S_StmtList, @1.begin, $1, $2); }
    | /* empty */       { $$ = make_tree(S_StmtList); }
    ;

Stmt: Exp SEMI                                { $$ = make_tree(S_Stmt, @1.begin, $1, $2); }
    | CompSt                                  { $$ = make_tree(S_Stmt, @1.begin, $1); }
    | RETURN Exp SEMI                         { $$ = make_tree(S_Stmt, @1.begin, $1, $2, $3); }
    | IF LP Exp RP Stmt %prec LOWER_THAN_ELSE { $$ = make_tree(S_Stmt, @1.begin, $1, $2, $3, $4, $5); }
    | IF LP Exp RP Stmt ELSE Stmt             { $$ = make_tree(S_Stmt, @1.begin, $1, $2, $3, $4, $5, $6, $7); }
    | WHILE LP Exp RP Stmt                    { $$ = make_tree(S_Stmt, @1.begin, $1, $2, $3, $4, $5); }
    | error SEMI                              { $$ = make_tree(S_Stmt, @1.begin, make_tree(YYerror)), $2; }
    | IF LP error RP Stmt                     { $$ = make_tree(S_Stmt, @1.begin, $1, $2, make_tree(YYerror)), $4, $5; }
    | IF LP error RP Stmt ELSE Stmt           { $$ = make_tree(S_Stmt, @1.begin, $1, $2, make_tree(YYerror)), $4, $5, $6, $7; }
    | WHILE LP error RP Stmt                  { $$ = make_tree(S_Stmt, @1.begin, $1, $2, make_tree(YYerror)), $4, $5; }
    ;


/* Local Definitions */

DefList: Def DefList { $$ = make_tree(S_DefList, @1.begin, $1, $2); }
    | /* empty */    { $$ = make_tree(S_DefList); }
    ;

Def: Specifier DecList SEMI { $$ = make_tree(S_Def, @1.begin, $1, $2, $3); }
    | error SEMI            { $$ = make_tree(S_Def, @1.begin, make_tree(YYerror)), $2; }
    ;

DecList: Dec              { $$ = make_tree(S_DecList, @1.begin, $1); }
    | Dec COMMA DecList   { $$ = make_tree(S_DecList, @1.begin, $1, $2, $3); }
    | error COMMA DecList { $$ = make_tree(S_DecList, @1.begin, make_tree(YYerror)), $2, $3; }
    | error               { $$ = make_tree(S_DecList, @1.begin, make_tree(YYerror)); }
    ;

Dec: VarDec               { $$ = make_tree(S_Dec, @1.begin, $1); }
    | VarDec ASSIGNOP Exp { $$ = make_tree(S_Dec, @1.begin, $1, $2, $3); }
    ;


/* Expressions */

Exp: Exp ASSIGNOP Exp        { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3); }
    | Exp AND Exp            { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3); }
    | Exp OR Exp             { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3); }
    | Exp RELOP Exp          { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3); }
    | Exp PLUS Exp           { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3); }
    | Exp MINUS Exp          { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3); }
    | Exp STAR Exp           { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3); }
    | Exp DIV Exp            { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3); }
    | LP Exp RP              { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3); }
    | MINUS Exp %prec UMINUS { $$ = make_tree(S_Exp, @1.begin, $1, $2); }
    | NOT Exp                { $$ = make_tree(S_Exp, @1.begin, $1, $2); }
    | ID LP Args RP          { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3, $4); }
    | ID LP RP               { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3); }
    | Exp LB Exp RB          { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3, $4); }
    | Exp DOT ID             { $$ = make_tree(S_Exp, @1.begin, $1, $2, $3); }
    | ID                     { $$ = make_tree(S_Exp, @1.begin, $1); }
    | INT                    { $$ = make_tree(S_Exp, @1.begin, $1); }
    | FLOAT                  { $$ = make_tree(S_Exp, @1.begin, $1); }
    /* | LP error RP         { $$ = make_tree(S_Exp, @1.begin, $1, make_tree(YYerror)), $3; } */    
    ;

Args: Exp COMMA Args    { $$ = make_tree(S_Args, @1.begin, $1, $2, $3); }
    | Exp               { $$ = make_tree(S_Args, @1.begin, $1); }
    | error COMMA Args  { $$ = make_tree(S_Args, @1.begin, make_tree(YYerror)), $2, $3; }
    ;

%%
void my::parser::error(const my::location &location, const std::string &msg) {
    int error_line = location.begin.line;
    
    if (!d.error_printed[error_line]) {
        std::cout << "Error type B at Line " << error_line << ": U" << msg.substr(15) << ".\n";
        d.error_printed[error_line] = 1;
    }

    d.has_syntax_error = 1;
}