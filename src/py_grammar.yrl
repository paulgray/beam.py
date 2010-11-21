%%%-------------------------------------------------------------------
%%% File    : py_grammar.yrl
%%% Author  : Michal Ptaszek <michal.ptaszek@erlang-solutions.com>
%%% Description : Parser for BEAM.py
%%%
%%% Created : 20 Nov 2010 by Michal Ptaszek <michal.ptaszek@erlang-solutions.com>
%%%-------------------------------------------------------------------
Nonterminals input_input expression_list comparison not_test
and_test or_test conditional_expression expression lambda_form
parameter_list atom attributeref call slicing subscription
literal short_slice upper_bound lower_bound simple_slicing
extended_slicing slice_list number
xor_expr or_expr and_expr shift_expr a_expr m_expr u_expr power
primary.
Terminals comp_operator integer '+' '-' '*' '/' '//' '%' '~' '**' 
'>>' '<<' '|' '&' '^' 'not' 'and' 'or' 'if' 'else' 'lambda' ':'
'[' ']' ',' '.' identifier stringliteral 'TODO' float.
Rootsymbol input_input.

input_input -> expression_list : '$1'.
expression_list -> expression : ['$1'].
expression_list -> expression ',' expression_list : ['$1' | '$3'].
expression_list -> expression ',' : ['$1'].
expression -> lambda_form : '$1'.
expression -> conditional_expression : '$1'.
lambda_form -> 'lambda' ':' expression : ['fun', [], '$3'].
lambda_form -> 'lambda' parameter_list ':' expression : ['fun', '$2', '$4'].
parameter_list -> 'TODO'.
conditional_expression -> or_test 'if' or_test 'else' expression : ['if', [['$3', '$1'], ['true', '$5']]].
conditional_expression -> or_test : '$1'.
or_test -> or_test 'or' and_test : ['$1', 'orelse', '$3'].
or_test -> and_test : '$1'.
and_test -> and_test 'and' not_test : ['$1', 'andalso', '$3'].
and_test -> not_test : '$1'.
not_test -> 'not' not_test : ['not', '$2'].
not_test -> comparison : '$1'.
comparison -> or_expr comp_operator comparison : ['$1', unwrap('$2'), '$3'].
comparison -> or_expr : '$1'.
or_expr -> or_expr '|' xor_expr : ['$1', 'bor', '$3'].
or_expr -> xor_expr : '$1'.
xor_expr -> xor_expr '^' and_expr : ['$1', 'bxor', '$3'].
xor_expr -> and_expr : '$1'.
and_expr -> and_expr '&' shift_expr : ['$1', 'band', '$3'].
and_expr -> shift_expr : '$1'.
shift_expr -> shift_expr '>>' a_expr : ['$1', 'bsr', '$3'].
shift_expr -> shift_expr '<<' a_expr : ['$1', 'bsl', '$3'].
shift_expr -> a_expr : '$1'.
a_expr -> a_expr '+' m_expr : ['$1', '+', '$3'].
a_expr -> a_expr '-' m_expr : ['$1', '-', '$3'].
a_expr -> m_expr : '$1'.
m_expr -> m_expr '*' u_expr : ['$1', '*', '$3'].
m_expr -> m_expr '//' u_expr : ['$1', 'div', '$3'].
m_expr -> m_expr '/' u_expr : ['$1', '/', '$3'].
m_expr -> m_expr '%' u_expr : ['$1', 'rem', '$3'].
m_expr -> u_expr : '$1'.
u_expr -> '-' u_expr : ['-', '$2'].
u_expr -> '+' u_expr : ['+', '$2'].
u_expr -> '~' u_expr : ['~', '$2'].
u_expr -> power : '$1'.
power -> primary '**' u_expr : {'**', '$1', '$3'}.
power -> primary : '$1'.
primary -> atom : '$1'.
primary -> attributeref : '$1'.
primary -> subscription : '$1'.
primary -> slicing : '$1'.
%primary -> call : '$1'.
atom -> identifier : unwrap('$1').
atom -> literal : '$1'.
literal -> stringliteral : unwrap('$1').
literal -> number : '$1'.
attributeref -> primary '.' identifier : ['$1', '.', '$3'].
subscription -> primary '[' expression ']' : ['subscr', '$1', '$3'].
slicing -> simple_slicing : '$1'.
slicing -> extended_slicing : '$1'.
simple_slicing -> primary '[' short_slice ']' : ['slices', [['$1', '$3']]].
short_slice -> lower_bound ':' upper_bound : ['$1', '$3'].
lower_bound -> expression : '$1'.
upper_bound -> expression : '$1'.
extended_slicing -> primary '[' slice_list ']' : ['slices', '$3'].
slice_list -> 'TODO'.
number -> integer : {integer, unwrap('$1')}.
number -> float : {float, unwrap('$1')}.
%call -> 'TODO'.

Erlang code.
unwrap({_, _, V}) ->
    V.
