%% @author Torbjorn Tornkvist <etnt@redhoterlang.com>
%% @copyright 2010 Torbjorn Tornkvist

-module(redhot2_common).

-include_lib ("nitrogen/include/wf.hrl").

-export([title/0
         , event/1
         , header/0
         , header/1
         , footer/0
         , right/0
         , left/0
         , gravatar/1
         , raw_path/0
         , logo_text/0
        ]).


-define(INDEX_PAGE, redhot2_web_index).


title() ->
    "RedHotErlang".

event(login) ->
    wf:wire(openid_box_id(), #appear { speed=5000 });
event(Event) ->
    io:format("~p: Event=~p~n",[?MODULE,Event]),
    ok.

right() ->
    #panel { class=right, body=[] }.


left() ->
    #panel { class=left, body=[redhot2_nav:list_entries()] }.

raw_path() ->
    RequestBridge = wf_context:request_bridge(),
    RequestBridge:uri().



gravatar(Email) ->
    #gravatar { email=Email,
		size="30", 
		rating="g", 
		default="identicon" }.


header() ->
    header(none).

header(Selected) ->
    lists:member(Selected,[home,twitter,login,logout,new,about]) andalso
        wf:wire(Selected, #add_class { class=selected }),
    #panel { body = [#image{image="/images/chili-small.png", 
                            class="chili_logo"},                     
                     #h1 { class = "header",
                           text  = logo_text(), html_encode=false},
                     #panel { class = "menu_box",
                              body  = [menu_box(),
                                       openid_box()]}
                    ]}.

menu_box() ->
    P = "p="++wf:url_encode(raw_path()),
    #panel { class=menu, 
             body=[#link { id=home,    url='/',           text="Home" },
                   #link { id=projects,url='/projects',   text="Projects" },
                   login_logout(P),
                   #link { id=new,     url='/new',        text="New" },
                   #link { id=about,   url='/about',      text="About" }
                  ]}.


login_logout(Path) ->
    login_logout(Path, wf:session(authenticated)).

login_logout(Path, true) ->
    #link { id=logout, url="/logout?"++Path, text="Logout" };
login_logout(_,_) ->
    #link { id=login, url="#", text="Login", postback=login, delegate=?MODULE }.


openid_box_id() ->
    openid_box_id.

openid_box() ->
    case wf:session(authenticated) of
        true ->
            #panel { class = "show_openid_box",
                     id    = openid_box_id(),
                     body  = [wf:user()]};
        _ ->
            Id = claimed_id,
            #panel { class = "hide_openid_box",
                     id    = openid_box_id(),
                     body  = [#textbox{ class    = "openid_login", 
                                        id       = Id,
                                        postback = {Id,raw_path()},
                                        delegate = ?INDEX_PAGE}]}
    end.


logo_text() ->
    "<span class='big'>R</span>ed<span class='big'>H</span>ot<span class='big'>E</span>rlang".

footer() ->
    [#br{},
     #panel { class="footer", body=[
        "
        Copyright &copy; 2010 <a href='http://www.redhoterlang.com'>Torbjorn Tornkvist</a>. 
        Released under the MIT License.
        "
    ]}].

