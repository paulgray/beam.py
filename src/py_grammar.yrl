%%%-------------------------------------------------------------------
%%% File    : py_grammar.yrl
%%% Author  : Michal Ptaszek <michal.ptaszek@erlang-solutions.com>
%%% Description : Parser for BEAM.py
%%%
%%% Created : 20 Nov 2010 by Michal Ptaszek <michal.ptaszek@erlang-solutions.com>
%%%-------------------------------------------------------------------
Nonterminals input_input expression_list a_expr m_expr u_expr.
Terminals number '+' '-' '*' '/' '//' '%'.
Rootsymbol expression_list.

input_input -> expression_list : '$1'.
expression_list -> a_expr : '$1'.
a_expr -> a_expr '+' m_expr : ['$1', '$2', '$3'].
a_expr -> a_expr '-' m_expr : ['$1', '$2', '$3'].
a_expr -> m_expr : '$1'.
m_expr -> m_expr '*' u_expr : ['$1', '$2', '$3'].
m_expr -> m_expr '//' u_expr : ['$1', 'div', '$3'].
m_expr -> m_expr '/' u_expr : ['$1', '$2', '$3'].
m_expr -> m_expr '%' u_expr : ['$1', 'rem', '$3'].
m_expr -> u_expr : '$1'.
u_expr -> number : unwrap('$1').

Erlang code.
unwrap({_, _, V}) ->
    V.
