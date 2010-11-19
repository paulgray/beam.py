%%%-------------------------------------------------------------------
%%% File    : py_scan.xrl
%%% Author  : Michal Ptaszek <michal@ptaszek.net>
%%% Description : Python grammar scaner
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
ID      = ({LETTER}|_)({LETTER}|{DIGIT}|_)*
STRPRE  = (r)|(u)|(ur)|(R)|(U)|(UR)|(Ur)|(uR)
DECINT  = ({NZDIGIT}{DIGIT}*)|0
OCTINT  = 0{ODIGIT}+

Rules.
%% integer
{DECINT}      :
base_int(TokenChars, TokenLine, 10).
{OCTINT}      :
base_int(TokenChars, TokenLine, 8).

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
