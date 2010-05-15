%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright 2010, Torbjorn Tornkvist.

-module(redhot2_web_edit).

-include_lib("nitrogen/include/wf.hrl").

-export([main/0
         , title/0
         , layout/0
	 , event/1
	]).

-import(redhot2,
        [authors/0
         , raw_path/0
         , process_markdown/1
         , maybe_nick/1
         , l2b/1
         , b2l/1
        ]).

main() ->
    #template { file="./templates/grid.html" }.

title() ->
    redhot2_common:title().

layout() ->
    #container_12 {
        body=[#grid_12 { class=header, body=redhot2_common:header(none)},
              #grid_clear {},

              #grid_8 { alpha=true, body=intro() },
              #grid_4 { omega=true, body=[] },
              #grid_clear {},

              #grid_12 { alpha=true, body=edit_page() },
              #grid_clear {},
              
              #grid_12 { body=redhot2_common:footer() }
             ]}.

intro() ->
    #panel { class = "intro",
             body = intro_text()}.

intro_text() ->
    "This is the page where the authors of "++redhot2_common:logo_text()++" input their new articles. "
        "The critera for becoming an author is to have shared (at least) one beer with <em>Tobbe</em>. "
        "Get in touch if you want to join as an author and you think you fulfill the requirement.".


event(updated_entry) ->
    case wf:session(authenticated) of
        true ->
            [Title] = wf:qs("new_title"),
            [Text]  = wf:qs("new_text"),
            Btxt    = l2b(Text),
            redhot2_couchdb:new_blog_entry(l2b(Title), 
                                           Btxt, 
                                           process_markdown(Btxt), 
                                           l2b(maybe_nick(wf:user()))),
            wf:redirect("/");
        _ ->
            wf:redirect("/")
    end;
event(Event) ->
    io:format("Event=~p~n",[Event]),
    ok.


edit_page() ->
    case wf:session(authenticated) of
        true ->
            case lists:keymember(wf:user(), 1, authors()) of
                true -> 
                    [_,Id|_] = string:tokens(redhot2_common:raw_path(),"/"),
                    {obj,L} = redhot2_couchdb:entry(Id),
                    T = proplists:get_value("title",L),
                    M = proplists:get_value("markdown",L),
                    R = proplists:get_value("_rev",L),
                    redhot2_web_new:mk_entry_form(T, M, updated_entry, b2l(Id), R);
                _ ->
                    #p{body=not_author_text()}
            end;
        _ ->
            #p{body=openid_text()}
    end.

not_author_text() ->
    "Sorry, but you're not registered as an author.".

openid_text() ->
    "You need to authenticate yourself!<br />"
        "You'll find the OpenId login entry at the top of the page.".





