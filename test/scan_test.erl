%%%-------------------------------------------------------------------
%%% File    : scan_test.erl
%%% Author  : Michal Ptaszek <michal.ptaszek@erlang-solutions.com>
%%% Description : Scanner tests
%%%
%%% Created : 20 Nov 2010 by Michal Ptaszek <michal.ptaszek@erlang-solutions.com>
%%%-------------------------------------------------------------------
-module(scan_test).

-include_lib("eunit/include/eunit.hrl").

-compile(export_all).

decimal_test() ->
    ?assertEqual({ok, [{number, 1, 0}], 1}, 
                 py_scan:string("0")),
    ?assertEqual({ok, [{number, 1, -40}], 1},
                 py_scan:string("-40")).

float_test() ->
    ?assertEqual({ok, [{number, 1, 0.0}], 1},
                 py_scan:string("0.0")),
    ?assertEqual({ok, [{number, 1, 0.0}], 1},
                 py_scan:string(".0")),
    ?assertEqual({ok, [{number, 1, 0.0}], 1},
                 py_scan:string("0.")),
    ?assertEqual({ok, [{number, 1, 31.5}], 1},
                 py_scan:string("31.5")),
    ?assertEqual({ok, [{number, 1, 3.5}], 1},
                 py_scan:string("3.5e1")),
    ?assertEqual({ok, [{number, 1, 3.5}], 1},
                 py_scan:string("3.5E1")),
    ?assertEqual({ok, [{number, 1, 15.0}], 1},
                 py_scan:string("1.5e2")),
    ?assertEqual({ok, [{number, 1, 10.0}], 1},
                 py_scan:string("1.e2")).
