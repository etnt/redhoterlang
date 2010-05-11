%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright YYYY Torbjorn Tornkvist.

%% @doc The initiating leg of the OpenID authentication.

-module(redhot2_web_login).

-include_lib ("nitrogen/include/wf.hrl").

-export([main/0,
         title/0,
         layout/0,
	 event/1
	]).

main() ->
    #template { file="./templates/grid.html" }.

title() ->
    redhot2_common:title().

layout() ->
    #container_12 {
        body=[
              #grid_12 { class=header, body=login_header() },
              #grid_clear {},
              #grid_4 { body=[] },
              #grid_4 { body=[login_form()] },
              #grid_4 { body=[] },
              #grid_clear {},              
              #grid_12 { body=redhot2_common:footer() }
             ]}.

event(claimed_id) ->
    try
        [ClaimedId0] = wf:qs(claimed_id),
	ClaimedId    = eopenid_lib:http_path_norm(ClaimedId0),
        HostName     = redhot2_deps:get_env(hostname, redhot2:hostname()),
        Port         = redhot2_deps:get_env(port, redhot2:default_port()),
        URL          = "http://"++HostName++":"++redhot2:i2l(Port),
        Dict0        = eopenid_lib:foldf(
                         [eopenid_lib:in("openid.return_to", URL++"/auth"),
                          eopenid_lib:in("openid.trust_root", URL)
                         ], eopenid_lib:new()),

        {ok,Dict1}   = eopenid_v1:discover(ClaimedId, Dict0),
        {ok,Dict2}   = eopenid_v1:associate(Dict1),
        {ok, Url}    = eopenid_v1:checkid_setup(Dict2),

        wf:session(eopenid_dict, Dict2),
        wf:redirect(Url)
    catch      
        _:Error ->
            io:format("ERROR=~p~n",[Error]),
            M = lists:flatten(
                  io_lib:format("~p:~p", [Error, erlang:get_stacktrace()])),
            wf:flash("ERROR: "++M)
    end;
event(E) ->
    io:format("E=~p~n",[E]).
    

login_header() ->
    #panel { class = "login_header", body = ["redhot2 logo here..."] }.


login_form() ->
    Text = "Type in your OpenID and press Enter:",
    B = #panel { class = "openid",
                 body  = [ #panel { body = [Text]},
                           #panel { class= "openid_box",
                                    body = [#panel { body = [ #textbox { class = "openid_login", 
                                                                         id    = "claimed_id", 
                                                                         next  = "auth" }]},
                                            #panel { body = [#button {   id    = "auth", 
                                                                         text  = "Enter"}]}]}
                          ]},
    wf:wire("auth", #event { type     = click, 
                             postback = claimed_id, 
                             delegate = ?MODULE}),
    B.


