#ifndef __PARSE_TREE_HPP_INCLUDED__
#define __PARSE_TREE_HPP_INCLUDED__

#include <iostream>
#include <memory>
#include <string>
#include <variant>
#include <vector>

#include "location.hh"
#include "pt_node_enum.h"
#include "util.h"

namespace my
{
    class parse_tree_node;

    class parse_tree : public std::shared_ptr<parse_tree_node>
    {
    public:
        parse_tree() = default;
        parse_tree(parse_tree_node *node) : std::shared_ptr<parse_tree_node>(node) {}
    }; // class parse_tree

    class parse_tree_node
    {
    public:
        using semantic_val = std::variant<std::monostate, int, float, std::string>;
        using terminal_type = parse_tree_terminal_type;
        using nonterminal_type = parse_tree_nonterminal_type;

        class terminal_info
        {
        public:
            terminal_type token;
            semantic_val val;

            terminal_info(terminal_type token, semantic_val val) : token(token), val(val) {}
            terminal_info(terminal_type token) : token(token), val() {}
            ~terminal_info() = default;

            int get_int() const { return std::get<int>(val); }
            float get_float() const { return std::get<float>(val); }
            const std::string &get_string() const { return std::get<std::string>(val); }
            int &get_int() { return std::get<int>(val); }
            float &get_float() { return std::get<float>(val); }
            std::string &get_string() { return std::get<std::string>(val); }
        };

        class nonterminal_info
        {
        public:
            nonterminal_type symbol;
            std::vector<parse_tree> children;

            nonterminal_info(nonterminal_type symbol) : symbol(symbol), children() {}

            template <typename... Args>
            nonterminal_info(nonterminal_type symbol, Args... args) : symbol(symbol), children({args...}) {}

            ~nonterminal_info() = default;
        };

    private:
        using node = parse_tree_node;

    public:
        std::variant<std::monostate, terminal_info, nonterminal_info> info;
        node *father;
        position begin_position;

        parse_tree_node() : info(), father(nullptr), begin_position() {}

        parse_tree_node(terminal_type token, position posi = position())
            : info(terminal_info(token)), father(nullptr), begin_position(posi) {}

        parse_tree_node(terminal_type token, semantic_val val, position posi = position())
            : info(terminal_info(token, val)), father(nullptr), begin_position(posi) {}

        parse_tree_node(nonterminal_type symbol, position posi = position())
            : info(nonterminal_info(symbol)), father(nullptr), begin_position(posi) {}

        template <typename... Args>
        parse_tree_node(nonterminal_type symbol, position posi, Args... args)
            : info(nonterminal_info(symbol, args...)), father(nullptr), begin_position(posi)
        {
            for (auto &child : as_nonterminal().children) {
                child->father = this;
            }
        }

        ~parse_tree_node() = default;

        bool is_terminal() const { return std::holds_alternative<terminal_info>(info); }
        bool is_nonterminal() const { return std::holds_alternative<nonterminal_info>(info); }
        bool is_empty() const { return std::holds_alternative<std::monostate>(info); }

        terminal_info &as_terminal() { return std::get<terminal_info>(info); }
        const terminal_info &as_terminal() const { return std::get<terminal_info>(info); }
        nonterminal_info &as_nonterminal() { return std::get<nonterminal_info>(info); }
        const nonterminal_info &as_nonterminal() const { return std::get<nonterminal_info>(info); }

        std::string to_string() const;
        std::string to_detail() const;

        template <typename... Args>
        bool can_derive_to(Args... args) const
        {
            if (!is_nonterminal())
                return false;

            if (as_nonterminal().children.size() != sizeof...(args))
                return false;

            return _can_derive_to_helper(0, args...);
        }

        bool has_root(nonterminal_type symbol) const
        {
            return is_nonterminal() && as_nonterminal().symbol == symbol;
        }

        bool has_root(terminal_type token) const
        {
            return is_terminal() && as_terminal().token == token;
        }

        void print(std::ostream &os = std::cout) const { _print_helper(this, 0, os); }

    private:
        static void _print_helper(const node *root, int depth, std::ostream &os);

        bool _can_derive_to_helper(int) const { return true; }

        template <typename... Args>
        bool _can_derive_to_helper(int i, nonterminal_type symbol, Args... args) const
        {
            const auto &child = as_nonterminal().children[i];
            return child->is_nonterminal() && child->as_nonterminal().symbol == symbol && _can_derive_to_helper(i + 1, args...);
        }

        template <typename... Args>
        bool _can_derive_to_helper(int i, terminal_type token, Args... args) const
        {
            const auto &child = as_nonterminal().children[i];
            return child->is_terminal() && child->as_terminal().token == token && _can_derive_to_helper(i + 1, args...);
        }
    };

    template <typename... Args>
    parse_tree make_tree(Args &&...args)
    {
        return parse_tree(new parse_tree_node(std::forward<Args>(args)...));
    }
} // namespace my

#endif /* !__PARSE_TREE_HPP_INCLUDED__ */