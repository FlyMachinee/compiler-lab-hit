#ifndef __PT_NODE_ENUM_H__
#define __PT_NODE_ENUM_H__

namespace my
{
    enum class parse_tree_terminal_type {
        YYerror = 0,
        YYUNDEF,
        YYEOF,
        INT,
        FLOAT,
        ID,
        SEMI,
        COMMA,
        ASSIGNOP,
        RELOP,
        PLUS,
        MINUS,
        STAR,
        DIV,
        AND,
        OR,
        DOT,
        NOT,
        TYPE,
        LP,
        RP,
        LB,
        RB,
        LC,
        RC,
        STRUCT,
        RETURN,
        IF,
        ELSE,
        WHILE
    }; // enum class parse_tree_terminal_type

    enum class parse_tree_nonterminal_type {
        S_Program = 0,
        S_ExtDefList,
        S_ExtDef,
        S_ExtDecList,
        S_Specifier,
        S_StructSpecifier,
        S_OptTag,
        S_Tag,
        S_VarDec,
        S_FunDec,
        S_VarList,
        S_ParamDec,
        S_CompSt,
        S_StmtList,
        S_Stmt,
        S_DefList,
        S_Def,
        S_DecList,
        S_Dec,
        S_Exp,
        S_Args
    }; // enum class parse_tree_nonterminal_type
} // namespace my

#endif /* !__PT_NODE_ENUM_H__ */
