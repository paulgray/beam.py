%%%-------------------------------------------------------------------
%%% File    : py_scan.xrl
%%% Author  : Michal Ptaszek <michal@ptaszek.net>
%%% Description : Python grammar scaner
%%%
%%% Created : 19 Nov 2010 by Michal Ptaszek <michal@ptaszek.net>
%%%-------------------------------------------------------------------
Definitions.

D     = [0-9]

Rules.
[+-]?{D}+      :
case catch list_to_integer(TokenChars) of
    {'EXIT', _} ->
        {error, not_an_integer};
    Int when is_integer(Int) ->
        {token, {number, TokenLine, Int}}
end.

Erlang code.
-module(py_scan).
