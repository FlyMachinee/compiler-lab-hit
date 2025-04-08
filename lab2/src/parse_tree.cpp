#include "parse_tree.hpp"

using namespace my;
using namespace std;

string parse_tree_node::to_string() const
{
    auto visitor = [](const auto &info) -> string {
        using T = decay_t<decltype(info)>;
        if constexpr (is_same_v<T, terminal_info>) {
            return ::my::to_string(info.token);
        } else if constexpr (is_same_v<T, nonterminal_info>) {
            return ::my::to_string(info.symbol);
        } else {
            return "<empty>";
        }
    };

    return std::visit(visitor, info);
}

string parse_tree_node::to_detail() const
{
    auto visitor = [this](const auto &info) -> std::string {
        using T = std::decay_t<decltype(info)>;
        if constexpr (std::is_same_v<T, terminal_info>) {
            switch (info.token) {
            case terminal_type::INT:
                return ": " + std::to_string(std::get<int>(info.val));
            case terminal_type::FLOAT:
                return ": " + std::to_string(std::get<float>(info.val));
            case terminal_type::ID:
            case terminal_type::TYPE:
                return ": " + std::get<std::string>(info.val);
            default:
                return "";
            }
        } else if constexpr (std::is_same_v<T, nonterminal_info>) {
            return " (" + ::std::to_string(begin_position.line) + ")";
        } else {
            return "";
        }
    };

    return to_string() + visit(visitor, info);
}

void parse_tree_node::_print_helper(const node *root, int depth, std::ostream &os)
{
    if (!root) {
        return;
    }

    if (root->is_nonterminal() && root->as_nonterminal().children.empty()) {
        return;
    }

    os << std::string(depth * 2, ' ') << root->to_detail() << std::endl;

    if (root->is_nonterminal()) {
        for (const auto &child : root->as_nonterminal().children) {
            _print_helper(child.get(), depth + 1, os);
        }
    }
}