%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright YYYY Torbjorn Tornkvist.

%% @doc Callbacks for the redhot2 application.

-module(redhot2_app).
-behaviour(application).

-export([start/2, stop/1]).

-include_lib("nitrogen/include/wf.hrl").

start(_, _) ->
    %% Uncomment below iff using eopenid!
    %%eopenid:start(),
    Res = redhot2_sup:start_link(),
    {ok,_Pid} = redhot2_inets:start_link(), % ends up under the inets supervisors
    Res.

stop(_) ->
    %% Uncomment below iff using eopenid!
    %%eopenid:stop(),
    ok.



