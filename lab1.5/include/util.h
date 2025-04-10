#ifndef __UTIL_H_INCLUDED__
#define __UTIL_H_INCLUDED__

#include <string>

#include "pt_node_enum.h"

namespace my
{

    std::string to_string(my::parse_tree_terminal_type token);

    std::string to_string(my::parse_tree_nonterminal_type symbol);

} // namespace my

#endif /* !__UTIL_H_INCLUDED__ */