#ifndef __DRIVER_H_INCLUDED__
#define __DRIVER_H_INCLUDED__

#include <iostream>

#include "parse_tree.hpp"
#include "parser.hpp"
#include "scanner.h"

namespace my
{
    class driver
    {
    public:
        scanner s;
        parser p;
        parse_tree pt;
        bool has_lexical_error;
        bool has_syntax_error;
        bool error_printed[256] = {false};

    public:
        driver();

        int parse(std::istream &is = std::cin, std::ostream &os = std::cout);

        virtual ~driver();
    }; // class driver
} // namespace my

#endif /* !__DRIVER_H_INCLUDED__ */