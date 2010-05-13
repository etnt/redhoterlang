%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright YYYY Torbjorn Tornkvist.

-module(redhot2_web_index).

-include_lib("nitrogen/include/wf.hrl").

-export([main/0
         , title/0
         , layout/0
	 , event/1
	]).


main() ->
    #template { file="./templates/grid.html" }.

title() ->
    redhot2_common:title().

layout() ->
    #container_12 {
        body=[#grid_12 { class=header, body=redhot2_common:header(home) },
              #grid_clear {},

              #grid_8 { alpha=true, body=intro() },
              #grid_4 { omega=true, body=[] },
              #grid_clear {},

              #grid_12 { alpha=true, body=redhot2_common:left() },
%              #grid_8 { alpha=true, body=redhot2_common:left() },
%              #grid_4 { omega=true, body=redhot2_common:right() },
              #grid_clear {},
              
              #grid_12 { body=redhot2_common:footer() }
             ]}.

intro() ->
    #panel { class = "intro",
             body = intro_text()}.

intro_text() ->
    "Welcome to "++redhot2_common:logo_text()++". "
        "Everything on this site revolves around <a href='http://www.erlang.org'>Erlang</a>; "
        "either in form of tips and tricks from a couple of passionate Erlang "
        "hackers, or in form of some experimental code being run.".

event(Event) ->
    io:format("Event=~p~n",[Event]),
    ok.









