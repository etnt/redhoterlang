%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright YYYY Torbjorn Tornkvist.

%% @doc Callbacks for the polish application.

-module(redhot2_inets).

-export([start_link/0, stop/0, do/1]).

-include_lib("nitrogen/include/wf.hrl").


%%% @doc This is the routing table.
routes() ->
    [{"/",            redhot2_web_index}
     , {"/entry",     redhot2_web_entry}
     , {"/about",     redhot2_web_about}
     , {"/twitter",   redhot2_web_twitter}
     , {"/new",       redhot2_web_new}
     , {"/edit",      redhot2_web_edit}
     , {"/web",       redhot2_web_bwcompat}
     , {"/login",     redhot2_web_login}
     , {"/logout",    redhot2_web_logout}
     , {"/auth",      redhot2_web_auth}
     , {"/theme",     redhot2_web_theme}
     , {"/nitrogen",  static_file}
     , {"/js",        static_file}
     , {"/css",       static_file}
    ].

start_link() ->
    inets:start(),
    {ok, Pid} =
        inets:start(httpd,
                    [{port, redhot2_deps:get_env(port, redhot2:default_port())}
                     ,{server_name,  redhot2_deps:get_env(hostname, redhot2:hostname())}
                     ,{server_root, "."}
                     ,{document_root, redhot2_deps:get_env(doc_root,"./www")}
                     ,{modules, [?MODULE]}
                     ,{mime_types, [{"css",  "text/css"},
                                    {"js",   "text/javascript"},
                                    {"html", "text/html"}]}
                    ]),
    link(Pid),
    {ok, Pid}.

stop() ->
    httpd:stop_service({any, redhot2_deps:get_env(port, redhot2:default_port())}),
    ok.

do(Info) ->
    RequestBridge = simple_bridge:make_request(inets_request_bridge, Info),
    ResponseBridge = simple_bridge:make_response(inets_response_bridge, Info),
    nitrogen:init_request(RequestBridge, ResponseBridge),
    replace_route_handler(),
    nitrogen:run().

replace_route_handler() ->
    wf_handler:set_handler(named_route_handler, routes()).
