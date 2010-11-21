%%%-------------------------------------------------------------------
%%% File    : py_compile.erl
%%% Author  : Michal Ptaszek <michal.ptaszek@erlang-solutions.com>
%%% Description : 
%%%
%%% Created : 21 Nov 2010 by Michal Ptaszek <michal.ptaszek@erlang-solutions.com>
%%%-------------------------------------------------------------------
-module(py_compile).

-export([compile/2]).

-record(ctx, {module,
              level = 0}).

compile(File, Module) ->
    compile(File, Module, []).

compile(File, Module, Opts) ->
    Context = init_ctx(File, Module, Opts),
    case parse(File) of
        {ok, ParseTree} ->
            case compile_tree(ParseTree, Context) of
                {ok, Binary} ->
                    code:load_binary(Module, "nofile", Binary);
%                    BeamFile = filename:join(atom_to_list(Module) ++ ".beam"),
%                    file:write_file(BeamFile, Binary);
                {error, Reason} ->
                    io:format("Compilation of ~p failed, reason: ~p~n", 
                              [Module, Reason])
            end;
        {error, Reason} ->
            io:format("Parsing of ~p failed, reason: ~p~n", 
                      [Module, Reason])
    end.

parse(File) ->
    {ok, Bin} = file:read_file(File),
    {ok, Tokens, _} = py_scan:string(binary_to_list(Bin)),
    py_grammar:parse(Tokens).

init_ctx(_File, Module, _Opts) ->
    #ctx{module = Module}.

compile_tree(Tree, Ctx) ->
    Mod = erl_syntax:attribute(erl_syntax:atom(module), 
                               [erl_syntax:atom(Ctx#ctx.module)]),
    %% FIXME: change it to the real exports
    Export = erl_syntax:attribute(erl_syntax:atom(compile), 
                                  [erl_syntax:atom(export_all)]),
    MainFunction = erl_syntax:function(erl_syntax:atom(main), 
                                       [erl_syntax:clause(
                                          [], none, 
                                          compile_tree(Tree, Ctx, []))]),
    
    Forms = [erl_syntax:revert(AST) || AST <- [Mod, Export, MainFunction]],
    
    case compile:forms(Forms) of
        {ok, _, Binary} ->
            {ok, Binary};
        {ok, _, Binary, _} ->
            {ok, Binary}
    end.

compile_tree([{'**', Left, Right} | Rest], Ctx, Acc) ->
    Expr = erl_syntax:application(
             erl_syntax:atom(math),
             erl_syntax:atom(pow),
             [hd(compile_tree([Left], Ctx, [])),
             hd(compile_tree([Right], Ctx, []))]),
    compile_tree(Rest, Ctx, [Expr | Acc]);
compile_tree([{'-', Right} | Rest], Ctx, Acc) ->
    Expr = erl_syntax:prefix_expr(
             erl_syntax:operator('-'),
             hd(compile_tree([Right], Ctx, []))),
    compile_tree(Rest, Ctx, [Expr | Acc]);
compile_tree([{'+', Right} | Rest], Ctx, Acc) ->
    Expr = erl_syntax:prefix_expr(
             erl_syntax:operator('+'),
             hd(compile_tree([Right], Ctx, []))),
    compile_tree(Rest, Ctx, [Expr | Acc]);
compile_tree([{'~', Right} | Rest], Ctx, Acc) ->
    Expr = erl_syntax:prefix_expr(
             erl_syntax:operator('bnot'),
             hd(compile_tree([Right], Ctx, []))),
    compile_tree(Rest, Ctx, [Expr | Acc]);
compile_tree([{'*', Left, Right} | Rest], Ctx, Acc) ->
    compile_tree(Rest, Ctx, [infix_expr('*', Left, Right, Ctx) | Acc]);
compile_tree([{'//', Left, Right} | Rest], Ctx, Acc) ->
    compile_tree(Rest, Ctx, [infix_expr('div', Left, Right, Ctx) | Acc]);
compile_tree([{'/', Left, Right} | Rest], Ctx, Acc) ->
    compile_tree(Rest, Ctx, [infix_expr('/', Left, Right, Ctx) | Acc]);
compile_tree([{'%', Left, Right} | Rest], Ctx, Acc) ->
    compile_tree(Rest, Ctx, [infix_expr('rem', Left, Right, Ctx) | Acc]);
compile_tree([{integer, I} | Rest], Ctx, Acc) ->
    compile_tree(Rest, Ctx, [erl_syntax:integer(I) | Acc]);
compile_tree([{float, F} | Rest], Ctx, Acc) ->
    compile_tree(Rest, Ctx, [erl_syntax:float(F) | Acc]);
compile_tree([], _, Acc) ->
    lists:reverse(Acc).

infix_expr(Op, Left, Right, Ctx) ->
    erl_syntax:infix_expr(
      hd(compile_tree([Left], Ctx, [])),
      erl_syntax:operator(Op),
      hd(compile_tree([Right], Ctx, []))).
