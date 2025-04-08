%code requires {
    struct pt_node;
    typedef struct pt_node pt_node_t;
}

%{
    #include <stdio.h>
    #include <stdlib.h>

    struct pt_node;
    typedef struct pt_node pt_node_t;

    #include "parse_tree.h"

    extern pt_node_t *parse_tree;
    extern int yylex(void);
    extern int yyrestart(FILE *input_file);

    extern char error_printed[256];

    void yyerror(const char *msg);

    char has_syntax_error = 0;
%}

%locations
%define parse.error verbose
%expect 2

%union {
    pt_node_t *pnode;
}


/* Terminal symbols */

%token <pnode> INT      "integer literal"
%token <pnode> FLOAT    "floating point literal"
%token <pnode> ID       "identifier"
%token <pnode> SEMI     ";"
%token <pnode> COMMA    ","
%token <pnode> ASSIGNOP "="
%token <pnode> RELOP    "relational operator"
%token <pnode> PLUS     "+"
%token <pnode> MINUS    "-"
%token <pnode> STAR     "*"
%token <pnode> DIV      "/"
%token <pnode> AND      "&&"
%token <pnode> OR       "||"
%token <pnode> DOT      "."
%token <pnode> NOT      "!"
%token <pnode> TYPE     "type"
%token <pnode> LP       "("
%token <pnode> RP       ")"
%token <pnode> LB       "["
%token <pnode> RB       "]"
%token <pnode> LC       "{"
%token <pnode> RC       "}"
%token <pnode> STRUCT   "struct"
%token <pnode> RETURN   "return"
%token <pnode> IF       "if"
%token <pnode> ELSE     "else"
%token <pnode> WHILE    "while"


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

%type <pnode> Program
%type <pnode> ExtDefList
%type <pnode> ExtDef
%type <pnode> ExtDecList
%type <pnode> Specifier
%type <pnode> StructSpecifier
%type <pnode> OptTag
%type <pnode> Tag
%type <pnode> VarDec
%type <pnode> FunDec
%type <pnode> VarList
%type <pnode> ParamDec
%type <pnode> CompSt
%type <pnode> StmtList
%type <pnode> Stmt
%type <pnode> DefList
%type <pnode> Def
%type <pnode> DecList
%type <pnode> Dec
%type <pnode> Exp
%type <pnode> Args


/* Start symbol */

%start Program


/* Destructors */

%destructor {
    free_pt($$);
} <pnode>

%%


/* High-level Definitions */

Program: ExtDefList {
                        $$ = NULL;
                        parse_tree = make_pt_node("Program", @1.first_line, 1, $1);
                    }
    ;

ExtDefList: ExtDef ExtDefList { $$ = make_pt_node("ExtDefList", @1.first_line, 2, $1, $2); }
    | /* empty */             { $$ = make_pt_node("ExtDefList", -1, 0); }
    ;

ExtDef: Specifier ExtDecList SEMI { $$ = make_pt_node("ExtDef", @1.first_line, 3, $1, $2, $3); }
    | Specifier SEMI              { $$ = make_pt_node("ExtDef", @1.first_line, 2, $1, $2); }
    | Specifier FunDec CompSt     { $$ = make_pt_node("ExtDef", @1.first_line, 3, $1, $2, $3); }
    | error SEMI                  { $$ = make_pt_node("ExtDef", @1.first_line, 2, 
                                        make_pt_token(YYerror), $2
                                    ); 
                                  }
    ;

ExtDecList: VarDec              { $$ = make_pt_node("ExtDecList", @1.first_line, 1, $1); }
    | VarDec COMMA ExtDecList   { $$ = make_pt_node("ExtDecList", @1.first_line, 3, $1, $2, $3); }
    | error COMMA ExtDecList    { $$ = make_pt_node("ExtDecList", @1.first_line, 3, 
                                        make_pt_token(YYerror), $2, $3
                                    ); 
                                }
    | error                     { $$ = make_pt_node("ExtDecList", @1.first_line, 1, 
                                        make_pt_token(YYerror)
                                    ); 
                                }
    ;


/* Specifiers */

Specifier: TYPE       { $$ = make_pt_node("Specifier", @1.first_line, 1, $1); }
    | StructSpecifier { $$ = make_pt_node("Specifier", @1.first_line, 1, $1); }
    ;

StructSpecifier: STRUCT OptTag LC DefList RC 
                 { $$ = make_pt_node("StructSpecifier", @1.first_line, 5, $1, $2,$3, $4, $5 ); }
    | STRUCT Tag { $$ = make_pt_node("StructSpecifier", @1.first_line, 2, $1, $2); }
    ;

OptTag: ID        { $$ = make_pt_node("OptTag", @1.first_line, 1, $1); }
    | /* empty */ { $$ = make_pt_node("OptTag", -1, 0); }
    ;

Tag: ID { $$ = make_pt_node("Tag", @1.first_line, 1, $1); }
    ;


/* Declarators */

VarDec: ID             { $$ = make_pt_node("VarDec", @1.first_line, 1, $1); }
    | VarDec LB INT RB { $$ = make_pt_node("VarDec", @1.first_line, 4, $1, $2, $3, $4); }
    ;

FunDec: ID LP VarList RP { $$ = make_pt_node("FunDec", @1.first_line, 4, $1, $2, $3, $4); }
    | ID LP RP           { $$ = make_pt_node("FunDec", @1.first_line, 3, $1, $2, $3); }
    | ID LP error RP     { $$ = make_pt_node("FunDec", @1.first_line, 4, $1, $2,
                                make_pt_token(YYerror), $4
                            ); 
                         }
    ;

VarList: ParamDec COMMA VarList { $$ = make_pt_node("VarList", @1.first_line, 3, $1, $2, $3); }
    | ParamDec                  { $$ = make_pt_node("VarList", @1.first_line, 1, $1); }
    | error COMMA VarList       { $$ = make_pt_node("VarList", @1.first_line, 3, 
                                        make_pt_token(YYerror), $2, $3
                                    ); 
                                }
    ;

ParamDec: Specifier VarDec { $$ = make_pt_node("ParamDec", @1.first_line, 2, $1, $2); }
    ;


/* Statements */

CompSt: LC DefList StmtList RC { $$ = make_pt_node("CompSt", @1.first_line, 4, $1, $2, $3, $4); }
    ;

StmtList: Stmt StmtList { $$ = make_pt_node("StmtList", @1.first_line, 2, $1, $2); }
    | /* empty */       { $$ = make_pt_node("StmtList", -1, 0); }
    ;

Stmt: Exp SEMI                                { $$ = make_pt_node("Stmt", @1.first_line, 2, $1, $2); }
    | CompSt                                  { $$ = make_pt_node("Stmt", @1.first_line, 1, $1); }
    | RETURN Exp SEMI                         { $$ = make_pt_node("Stmt", @1.first_line, 3, $1, $2, $3); }
    | IF LP Exp RP Stmt %prec LOWER_THAN_ELSE { $$ = make_pt_node("Stmt", @1.first_line, 5, $1, $2, $3, $4, $5); }
    | IF LP Exp RP Stmt ELSE Stmt             { $$ = make_pt_node("Stmt", @1.first_line, 7, $1, $2, $3, $4, $5, $6, $7); }
    | WHILE LP Exp RP Stmt                    { $$ = make_pt_node("Stmt", @1.first_line, 5, $1, $2, $3, $4, $5); }
    | error SEMI                              { $$ = make_pt_node("Stmt", @1.first_line, 2, 
                                                    make_pt_token(YYerror), $2
                                                ); 
                                              }
    | IF LP error RP Stmt                     { $$ = make_pt_node("Stmt", @1.first_line, 5, $1, $2,
                                                    make_pt_token(YYerror), $4, $5
                                                ); 
                                              }
    | IF LP error RP Stmt ELSE Stmt           { $$ = make_pt_node("Stmt", @1.first_line, 7, $1, $2,
                                                    make_pt_token(YYerror), $4, $5, $6, $7
                                                ); 
                                              }
    | WHILE LP error RP Stmt                  { $$ = make_pt_node("Stmt", @1.first_line, 5, $1, $2,
                                                    make_pt_token(YYerror), $4, $5
                                                ); 
                                              }
    ;


/* Local Definitions */

DefList: Def DefList { $$ = make_pt_node("DefList", @1.first_line, 2, $1, $2); }
    | /* empty */    { $$ = make_pt_node("DefList", -1, 0); }
    ;

Def: Specifier DecList SEMI { $$ = make_pt_node("Def", @1.first_line, 3, $1, $2, $3); }
    | error SEMI            { $$ = make_pt_node("Def", @1.first_line, 2, 
                                    make_pt_token(YYerror), $2
                                ); 
                            }
    ;

DecList: Dec              { $$ = make_pt_node("DecList", @1.first_line, 1, $1); }
    | Dec COMMA DecList   { $$ = make_pt_node("DecList", @1.first_line, 3, $1, $2, $3); }
    | error COMMA DecList { $$ = make_pt_node("DecList", @1.first_line, 3, 
                                make_pt_token(YYerror), $2, $3
                            );
                          }
    | error               { $$ = make_pt_node("DecList", @1.first_line, 1, 
                                make_pt_token(YYerror)
                            ); 
                          }
    ;

Dec: VarDec               { $$ = make_pt_node("Dec", @1.first_line, 1, $1); }
    | VarDec ASSIGNOP Exp { $$ = make_pt_node("Dec", @1.first_line, 3, $1, $2, $3); }
    ;


/* Expressions */

Exp: Exp ASSIGNOP Exp        { $$ = make_pt_node("Exp", @1.first_line, 3, $1, $2, $3); }
    | Exp AND Exp            { $$ = make_pt_node("Exp", @1.first_line, 3, $1, $2, $3); }
    | Exp OR Exp             { $$ = make_pt_node("Exp", @1.first_line, 3, $1, $2, $3); }
    | Exp RELOP Exp          { $$ = make_pt_node("Exp", @1.first_line, 3, $1, $2, $3); }
    | Exp PLUS Exp           { $$ = make_pt_node("Exp", @1.first_line, 3, $1, $2, $3); }
    | Exp MINUS Exp          { $$ = make_pt_node("Exp", @1.first_line, 3, $1, $2, $3); }
    | Exp STAR Exp           { $$ = make_pt_node("Exp", @1.first_line, 3, $1, $2, $3); }
    | Exp DIV Exp            { $$ = make_pt_node("Exp", @1.first_line, 3, $1, $2, $3); }
    | LP Exp RP              { $$ = make_pt_node("Exp", @1.first_line, 3, $1, $2, $3); }
    | MINUS Exp %prec UMINUS { $$ = make_pt_node("Exp", @1.first_line, 2, $1, $2); }
    | NOT Exp                { $$ = make_pt_node("Exp", @1.first_line, 2, $1, $2); }
    | ID LP Args RP          { $$ = make_pt_node("Exp", @1.first_line, 4, $1, $2, $3, $4); }
    | ID LP RP               { $$ = make_pt_node("Exp", @1.first_line, 3, $1, $2, $3); }
    | Exp LB Exp RB          { $$ = make_pt_node("Exp", @1.first_line, 4, $1, $2, $3, $4); }
    | Exp DOT ID             { $$ = make_pt_node("Exp", @1.first_line, 3, $1, $2, $3); }
    | ID                     { $$ = make_pt_node("Exp", @1.first_line, 1, $1); }
    | INT                    { $$ = make_pt_node("Exp", @1.first_line, 1, $1); }
    | FLOAT                  { $$ = make_pt_node("Exp", @1.first_line, 1, $1); }
    /* | LP error RP            { $$ = make_pt_node("Exp", @1.first_line, 3, 
                                    $1, make_pt_token(YYerror), $3
                                ); 
                             } */    
    ;

Args: Exp COMMA Args    { $$ = make_pt_node("Args", @1.first_line, 3, $1, $2, $3); }
    | Exp               { $$ = make_pt_node("Args", @1.first_line, 1, $1); }
    | error COMMA Args  { $$ = make_pt_node("Args", @1.first_line, 3, 
                                make_pt_token(YYerror), $2, $3
                            ); 
                        }
    ;

%%
void yyerror(const char *msg) {
    if (!error_printed[yylloc.first_line]) {
        printf("Error type B at Line %d: U%s.\n", yylloc.first_line, msg + 15);
        error_printed[yylloc.first_line] = 1;
    }

    has_syntax_error = 1;
}