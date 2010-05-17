%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright YYYY Torbjorn Tornkvist.

-module(redhot2_web_about).

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
        body=[#grid_12 { class=header, body=redhot2_common:header(about) },
              #grid_clear {},

              #grid_10 { alpha=true, body=about() },
              #grid_2 { omega=true, body=redhot2_common:right() },
              #grid_clear {},
              
              #grid_12 { body=redhot2_common:footer() }
             ]}.

about() ->
        "<p>This is a blog application written in Erlang.</p>

<p>It has been functioning as a lab bench for experimenting with
different tools and techniques over the years. The current version
is version 4.
<p>
Now it is making use of <a href='http://nitrogenproject.com/'>Nitrogen 2.0</a>
and <a href='http://couchdb.apache.org/'>CouchDB</a>. Version 3 implemented a
desktop like interface, with no visible pages but the top one. In version 4 it
has returned to a more page based structure. It has also got a new layout and has
become theme-able. So if you come up with a new theme, do send it to me and I'll
add it to the theme page :-)
</p>
<p>If you would like to try it out or just look at the code, 
you will find a hg repository 
<a href='http://bitbucket.org/etnt/redhoterlang/'>here</a>.

<p>Note that this is still work in progress...</p>". % " emacs mode bug ?



event(Event) ->
    io:format("Event=~p~n",[Event]),
    ok.
