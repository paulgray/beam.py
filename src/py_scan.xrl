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
INT     = ({DECINT})|({OCTINT})|({HEXINT})
LINT    = {INT}(l|L)
INTPART = ({DIGIT})+
FRACT   = \.({DIGIT})+
PTFLT   = (({INTPART})?{FRACT})|({INTPART}\.)
EXP     = (e|E)(\+|-)?{DIGIT}+
EXPFLT  = (({INTPART})|({PTFLT})){EXP}
FLOAT   = ({PTFLT})|({EXPFLT})
LSTRCS  = [^\\\']
LSTRCD  = [^\\\"]
LSTRISQ = (\')|(\'\')
LSTRIDQ = (\")|(\"\")
LSTRISB = ({LSTRCS})|({ESCSEQ})
LSTRIDB = ({LSTRCD})|({ESCSEQ})
LSTRIS  = ({LSTRISB})*|({LSTRISQ}{LSTRISB}*)|({LSTRISB}*{LSTRISQ})|({LSTRISB}+{LSTRISQ}{LSTRISB}+)*
LSTRID  = ({LSTRIDB})*|({LSTRIDQ}{LSTRIDB}*)|({LSTRIDB}*{LSTRIDQ})|({LSTRIDB}+{LSTRIDQ}{LSTRIDB}+)*
LNGSTR  = (\'\'\'({LSTRIS})\'\'\')|(\"\"\"({LSTRID})\"\"\")
SSTRCS  = [^\\\n\']
SSTRCD  = [^\\\n\"]
ESCSEQ  = \\.
SSTRIS  = ({SSTRCS})|({ESCSEQ})
SSTRID  = ({SSTRCD})|({ESCSEQ})
SHRTSTR = (\'({SSTRIS})*\')|(\"({SSTRID})*\")
STRLTR  = ({STRPRE})?(({SHRTSTR})|({LNGSTR}))
OP      = (\*\*)|\-|\+|\*|\/|(and)|(or)|(not)|(\~)|(\/\/)|\^|\&|\%|(\>\>)|(\<\<)
WS      = ([\000-\s]|%.*)


Rules.
%% integers
{HEXINT}      :
base_int(tl(tl(TokenChars)), TokenLine, 16).
{OCTINT}      :
base_int(TokenChars, TokenLine, 8).
{DECINT}      :
base_int(TokenChars, TokenLine, 10).
{PTFLT}       :
case hd(TokenChars) of
    46 -> %% .
        base_float([$0 | TokenChars], TokenLine);
    _ ->
        case hd(lists:reverse(TokenChars)) of
            46 -> %% .
                base_float(TokenChars ++ "0", TokenLine);
            _ ->
                base_float(TokenChars, TokenLine)
        end
end.
{EXPFLT}       :
case hd(TokenChars) of
    46 -> %% .
        base_float([$0 | TokenChars], TokenLine);
    _ ->
        case string:tokens(TokenChars, [$.]) of
            [Dec, [E | Exp]] when E == $e;
                                  E == $E ->
                base_float(Dec ++ ".0e" ++ Exp, TokenLine);
            _ ->
                base_float(TokenChars, TokenLine)
        end
end.
{LNGSTR}        :
{token, {string, TokenLine, lists:reverse(
                              tl(tl(tl(lists:reverse(
                                         tl(tl(tl(TokenChars))))))))}}.
{SHRTSTR}       :
{token, {string, TokenLine, lists:reverse(tl(lists:reverse(tl(TokenChars))))}}.
{OP}            :
{token, {list_to_atom(TokenChars), TokenLine}}.
{ID}            :
{token, {id, TokenLine, list_to_atom(TokenChars)}}.
[();,]          :
{token, {list_to_atom(TokenChars), TokenLine}}.
{WS}+           :
skip_token.

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

-spec(base_float/2 :: (string(), integer()) ->
             {token, {number, integer(), float()}} |
                 {error, not_a_float}).
base_float(String, Line) ->
    case catch list_to_float(String) of
        {'EXIT', _} ->
            {error, not_a_float};
        Float when is_float(Float) ->
            {token, {number, Line, Float}}
    end.
