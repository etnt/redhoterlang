%%% @author Torbjorn Tornkvist <etnt@redhoterlang.com>
%%% @copyright (C) YYYY, Torbjorn Tornkvist

-module(redhot2).

-export([hostname/0
         , default_port/0
         , i2l/1
        ]).

-include_lib("nitrogen/include/wf.hrl").
           

default_port() -> 8080.

hostname() ->
    {ok,Host} = inet:gethostname(),
    Host.

i2l(I) when is_integer(I) -> integer_to_list(I);
i2l(L) when is_list(L)    -> L.
    

