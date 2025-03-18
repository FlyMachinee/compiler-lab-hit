#include <random>

#include "util.h"

using namespace my;
using namespace std;

using enum parse_tree_terminal_type;
using enum parse_tree_nonterminal_type;

string my::to_string(parse_tree_terminal_type token)
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
        return "YYerror";
    default:
        return "UNKNOWN";
    }
}

string my::to_string(parse_tree_nonterminal_type symbol)
{
    switch (symbol) {
    case S_Program:
        return "Program";
    case S_ExtDefList:
        return "ExtDefList";
    case S_ExtDef:
        return "ExtDef";
    case S_ExtDecList:
        return "ExtDecList";
    case S_Specifier:
        return "Specifier";
    case S_StructSpecifier:
        return "StructSpecifier";
    case S_OptTag:
        return "OptTag";
    case S_Tag:
        return "Tag";
    case S_VarDec:
        return "VarDec";
    case S_FunDec:
        return "FunDec";
    case S_VarList:
        return "VarList";
    case S_ParamDec:
        return "ParamDec";
    case S_CompSt:
        return "CompSt";
    case S_StmtList:
        return "StmtList";
    case S_Stmt:
        return "Stmt";
    case S_DefList:
        return "DefList";
    case S_Def:
        return "Def";
    case S_DecList:
        return "DecList";
    case S_Dec:
        return "Dec";
    case S_Exp:
        return "Exp";
    case S_Args:
        return "Args";
    default:
        return "Unknown";
    }
}