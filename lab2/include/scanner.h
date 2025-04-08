#ifndef __SCANNER_H_INCLUDED__
#define __SCANNER_H_INCLUDED__

#if !defined(yyFlexLexerOnce)
#undef yyFlexLexer
#define yyFlexLexer my_FlexLexer
#include <FlexLexer.h>
#endif

#undef YY_DECL
#define YY_DECL my::parser::symbol_type my::scanner::next_token(driver &d)

#include "parser.hpp"

namespace my
{
    class driver;

    class scanner : public yyFlexLexer
    {
    private:
        driver &_driver;

    public:
        scanner(driver &driver) : _driver(driver) {}
        virtual ~scanner() {}

        virtual parser::symbol_type next_token(driver &d);
    }; // class scanner
} // namespace my

#endif /* !__SCANNER_H_INCLUDED__ */