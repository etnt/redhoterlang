%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright 2010 Torbjorn Tornkvist.

-module(redhot2_web_projects).

-include_lib("nitrogen/include/wf.hrl").

-export([main/0
         , title/0
         , layout/0
	 , event/1
	]).

-import(redhot2_common, [logo_text/0]).


main() ->
    #template { file="./templates/grid.html" }.

title() ->
    redhot2_common:title().

layout() ->
    #container_12 {
        body=[#grid_12 { class=header, body=redhot2_common:header(projects) },
              #grid_clear {},

              #grid_8 { alpha=true, body=intro() },
              #grid_4 { omega=true, body=[] },
              #grid_clear {},

              #grid_12 { alpha=true, body=projects() },
              #grid_clear {},
              
              #grid_12 { body=redhot2_common:footer() }
             ]}.

intro() ->
    #panel { class = "intro",
             body = intro_text()}.

intro_text() ->
    "Here are a collection of some small projects that has been integrated with "
        ++ redhot2_common:logo_text() ++".".

projects() ->
    Theme = theme_chooser(),

    TwId = wf:temp_id(),
    Twitter = twitter(TwId),
    wf:wire(TwId, #event {type=click, postback=twitter, delegate=?MODULE}),

    SpId = wf:temp_id(),
    Sopcast = sopcast(SpId),
    wf:wire(SpId, #event {type=click, postback=sopcast, delegate=?MODULE}),
    #panel{body=[Theme,Twitter,Sopcast]}.


event({theme, Theme}) ->
    wf:session(theme, Theme),
    wf:redirect("/projects");
event(twitter) ->
    wf:redirect("/twitter");
event(sopcast) ->
    wf:redirect("/sopcast");
event(Event) ->
    ?PRINT(Event),
    wf:redirect("/?error_msg").

theme_chooser() ->
    #panel{body=[#image{image="/images/chili-small.png",class="icon_theme"},
                 #panel{class="proj_themes", 
                        body=themes()}]}.
    
themes() ->
    [#panel{body=[#link{class="theme", text="DigitalChili", 
                        postback={theme,"digitalchili"}, delegate=?MODULE },
                  " is the (new) default look of "++logo_text()]}
     , #panel{body=[#link{class="theme", text="WhiteChili", 
                          postback={theme,"whitechili"}, delegate=?MODULE },
                    " very similar to the default but more whiteish and it also "
                    "plays with the <b>@font-face</b> CSS directive."]}
    ].
     

twitter(Id) ->
    #panel{body=[#link{body=#image{image="/images/twitter_logo.png",class="icon_twitter"},
                       id=Id},
                 #panel{class="proj_txt", 
                        body=twitter_text()}]}.

twitter_text() ->
    "By clicking on the Twitter icon above you will invoke "
        "the <em>Twitter</em> page that displays tweets refering to Erlang. "
        "From that page you can also type in some other keywords that you "
        "would like to find the corresponding tweets for. If you want to "
        "bookmark the Twitter page you can use <a href=\"/twitter\">"
        "this</a> permalink.".


sopcast(Id) ->
    #panel{body=[#link{body=#image{image="/images/sopcast_logo.png", class="icon_sopcast"},
                       id=Id},
                 #panel{class="proj_txt", 
                        body=sopcast_text()}]}.

sopcast_text() ->
    "<a href=\"http://www.sopcast.com/info/sop.html\">SopCast</a> "
        " is a simple and free P2P(Peer-to-Peer) technolog that makes "
        "it possible  to broadcast video and audio. "
        "By clicking on the Sopcast icon above you will invoke "
        "the <em>Sopcast</em> page that displays some sport events that are to "
        "be broadcasted (nb: the page loads slow, ~10 sec). "
        "So, let's say you want to watch that Champions League "
        "match, but it isn't broadcasted on any of your TV channels; then see "
        "if the match is Sopcasted, fire up a client and paste in the link! "
        "If you want to bookmark the Sopcast page you can use "
        "<a href=\"/sopcast\">this</a> permalink.".
