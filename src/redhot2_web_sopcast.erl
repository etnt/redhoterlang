%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright 2010 Torbjorn Tornkvist.

-module(redhot2_web_sopcast).

-include_lib("nitrogen/include/wf.hrl").

-export([main/0
         , title/0
         , layout/0
%	 , event/1
	]).


main() ->
    #template { file="./templates/grid.html" }.

title() ->
    redhot2_common:title().

layout() ->
    #container_12 {
        body=[#grid_12 { class=header, body=redhot2_common:header(twitter) },
              #grid_clear {},

              #grid_8 { alpha=true, body=intro() },
              #grid_4 { omega=true, body=[] },
              #grid_clear {},

              #grid_12 { alpha=true, body=sopcast_page() },
              #grid_clear {},
              
              #grid_12 { body=redhot2_common:footer() }
             ]}.

intro() ->
    #panel { class = "intro",
             body = intro_text()}.

intro_text() ->
    "Upcoming Sopcast'ed games.".


sopcast_page() ->
    L = [#panel{body = [#panel{body=what_sport(Sport), class="sopcast_sport"},
			#panel{body=mk_sopcast_links(Links)}]}
	 || {Sport,Links} <- mysopcast:sport(), Sport=/=error ],
    #panel{body=L}.

what_sport(A) when is_atom(A) -> string:to_upper(atom_to_list(A));
what_sport(S) when is_list(S) -> string:to_upper(S).
    
mk_sopcast_links(Links) ->
    [#panel{body = [#panel{body=Hdr, class="sopcast_hdr"},
		    #panel{body=mk_the_sopcast_links(Ls)}]}
     || {Hdr,Ls} <- Links].

mk_the_sopcast_links(Ls) ->
    [#panel{body=[#link{url=S,text=S}], class="sopcast_links"} || S <- Ls].
