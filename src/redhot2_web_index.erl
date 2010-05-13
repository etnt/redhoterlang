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

              #grid_12 { alpha=true, body=redhot2_common:left() },
%              #grid_8 { alpha=true, body=redhot2_common:left() },
%              #grid_4 { omega=true, body=redhot2_common:right() },
              #grid_clear {},
              
              #grid_12 { body=redhot2_common:footer() }
             ]}.

event(Event) ->
    io:format("Event=~p~n",[Event]),
    ok.
