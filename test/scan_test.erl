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
    ?assertEqual({ok, [{number, 1, 40}], 1},
                 py_scan:string("40")).

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
                 py_scan:string("3.5e0")),
    ?assertEqual({ok, [{number, 1, 3.5}], 1},
                 py_scan:string("3.5E0")),
    ?assertEqual({ok, [{number, 1, 150.0}], 1},
                 py_scan:string("1.5e2")),
    ?assertEqual({ok, [{number, 1, 100.0}], 1},
                 py_scan:string("1.e2")).

short_string_test() ->
    ?assertEqual({ok, [{string, 1, ""}], 1},
                 py_scan:string("\'\'")),
    ?assertEqual({ok, [{string, 1, ""}], 1},
                 py_scan:string("\"\"")),
    ?assertEqual({ok, [{string, 1, "foobar"}], 1},
                 py_scan:string("\'foobar\'")),
    ?assertEqual({ok, [{string, 1, "foobar"}], 1},
                 py_scan:string("\"foobar\"")),
    ?assertEqual({ok, [{string, 1, "foo\\\"bar"}], 1},
                 py_scan:string("\"foo\\\"bar\"")),
    ?assertEqual({ok, [{string, 1, "5"}], 1},
                 py_scan:string("\'5\'")),
    ?assertEqual({ok, [{string, 1, "foo"}, 
                       {string, 1, "bar"}], 1},
                 py_scan:string("\'foo\'\'bar\'")).

long_string_test() ->
    ?assertEqual({ok, [{string, 1, ""}], 1},
                 py_scan:string("\'\'\'\'\'\'")),
    ?assertEqual({ok, [{string, 1, ""}], 1},
                 py_scan:string("\"\"\"\"\"\"")),
    ?assertEqual({ok, [{string, 1, "foobar"}], 1},
                 py_scan:string("\"\"\"foobar\"\"\"")),
    ?assertEqual({ok, [{string, 1, "foo\"\"bar"}], 1},
                 py_scan:string("\"\"\"foo\"\"bar\"\"\"")),
    ?assertEqual({ok, [{string, 1, "foo"},
                       {string, 1, "bar"}], 1},
                 py_scan:string("\"\"\"foo\"\"\"\"\"\"bar\"\"\"")),
    ?assertEqual({ok, [{string, 1, "\n"}], 2},
                 py_scan:string("\'\'\'\n\'\'\'")),
    ?assertEqual({ok, [{string, 1, "\n"}], 2},
                 py_scan:string("\"\"\"\n\"\"\"")),
    ?assertEqual({ok, [{string, 1, "\"\"foo"},
                       {string, 1, "bar"}], 1},
                 py_scan:string("\"\"\"\"\"foo\"\"\"\"\"\"bar\"\"\"")),
    ?assertEqual({ok, [{string, 1, "foo"},
                       {string, 1, "bar"}], 1},
                 py_scan:string("\"\"\"foo\"\"\"\"\"\"bar\"\"\"")).
