%%%-------------------------------------------------------------------
%%% File    : py_scan.xrl
%%% Author  : Michal Ptaszek <michal@ptaszek.net>
%%% Description : Python grammar scaner
%%% Grammar taken from http://docs.python.org/release/2.5.2/ref/grammar.txt
%%%
%%% Created : 19 Nov 2010 by Michal Ptaszek <michal@ptaszek.net>
%%%-------------------------------------------------------------------
Definitions.

LC      = [a-z]
UC      = [A-Z]
LETTER  = {LC}|{UC}
NZDIGIT = [1-9]
ODIGIT  = [0-7]
DIGIT   = [0-9]
HDIGIT  = {DIGIT}|[a-f]|[A-F]
ID      = ({LETTER}|_)({LETTER}|{DIGIT}|_)*
STRPRE  = (r)|(u)|(ur)|(R)|(U)|(UR)|(Ur)|(uR)
DECINT  = ({NZDIGIT}{DIGIT}*)|0
OCTINT  = 0({ODIGIT})+
HEXINT  = 0(x|X)({HDIGIT})+

Rules.
%% integers
{HEXINT}      :
base_int(tl(tl(TokenChars)), TokenLine, 16).
{OCTINT}      :
base_int(TokenChars, TokenLine, 8).
{DECINT}      :
base_int(TokenChars, TokenLine, 10).

Erlang code.
-spec(base_int/3 :: (string(), integer(), integer()) ->
             {token, {number, integer(), integer()}} |
                 {error, not_an_integer}).
base_int(String, Line, Base) ->
    case catch erlang:list_to_integer(String, Base) of
        {'EXIT', _} ->
            {error, not_an_integer};
        Int when is_integer(Int) ->
            {token, {number, Line, Int}}
    end.
