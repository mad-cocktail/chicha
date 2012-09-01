-module(chicha_tests).

-compile({parse_transform, chicha}).

-compile(export_all).


id(X) -> X.

id_fn() ->
    id/1.

last() ->
    lists:last/1.


%-include_lib("eunit/include/eunit.hrl").
%
%-ifdef(TEST).
%
%chicha_test_() ->
%    [ ?_assertEqual(id_fn(), fun id/1)
%    , ?_assertEqual(last(), fun lists:last/1)
%    ].
%
%-endif.
