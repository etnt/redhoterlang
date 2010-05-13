%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright YYYY Torbjorn Tornkvist.

-module(redhot2_web_twitter).

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
        body=[#grid_12 { class=header, body=redhot2_common:header(twitter) },
              #grid_clear {},

              #grid_8 { alpha=true, body=intro() },
              #grid_4 { omega=true, body=[] },
              #grid_clear {},

              #grid_12 { alpha=true, body=twitter(keyword()) },
              #grid_clear {},
              
              #grid_12 { body=redhot2_common:footer() }
             ]}.

intro() ->
    #panel { class = "intro",
             body = intro_text()}.

intro_text() ->
    "Type in a Twitter keyword and press the button.".


keyword() ->
    case string:tokens(redhot2_common:raw_path(), "/") of
        [_,KeyWord] -> wf:url_decode(KeyWord);
        _           -> "erlang"  % default keyword
    end.

twitter(DefKw) ->
    L=redhot2_twitter:run(DefKw),
    K=#panel{
      body = [#panel{class="tw_search", 
                     body = [#button{id="tw_search",   text="Keyword:"},
                             #textbox{id="tw_keyword", class="tw_keyword", text=DefKw}
                            ]}]},
    wf:wire("tw_search", #event {type=click, postback=twitter_search, delegate=?MODULE}),
    R=#panel{body=[#panel{body=[#panel{class="tw_user", body=[#link{url=Url,text=User}]},
                                #panel{class="tw_title",
                                       body=[#span{text=urlify(Text),html_encode=false}]}]}
                   || {User,Url,Text} <- L,length(Text)>20]}, % else, it is not interesting enough
    #panel{body=[K,R]}.

urlify(Text) ->
    re:replace(Text,
               "(http://[^ ]+)","<a href='\\1'>\\1</a>",
               [{return,list},global]).


event(twitter_search) ->
    [KeyWord0] = wf:qs("tw_keyword"),
    [KeyWord|_] = string:tokens(KeyWord0, " "),
    wf:redirect("/twitter/"++wf:url_encode(KeyWord)).

