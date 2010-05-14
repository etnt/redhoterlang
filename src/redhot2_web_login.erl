%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright YYYY Torbjorn Tornkvist.

%% @doc The initiating leg of the OpenID authentication.

-module(redhot2_web_login).

-include_lib ("nitrogen/include/wf.hrl").

-export([claimed_id/2
	]).

claimed_id(ClaimedId0,ReturnPage) ->
    try
	ClaimedId    = eopenid_lib:http_path_norm(ClaimedId0),
        HostName     = redhot2_deps:get_env(hostname, redhot2:hostname()),
        Port         = redhot2_deps:get_env(port, redhot2:default_port()),
        URL          = "http://"++HostName++":"++redhot2:i2l(Port),
        Dict0        = eopenid_lib:foldf(
                         [eopenid_lib:in("openid.return_to", 
                                         URL++"/auth?p="++wf:url_encode(ReturnPage)),
                          eopenid_lib:in("openid.trust_root", URL)
                         ], eopenid_lib:new()),

        {ok,Dict1}   = eopenid_v1:discover(ClaimedId, Dict0),
        {ok,Dict2}   = eopenid_v1:associate(Dict1),
        {ok, Url}    = eopenid_v1:checkid_setup(Dict2),

        wf:session(eopenid_dict, Dict2),
        wf:redirect(Url)
    catch      
        _:Error ->
            io:format("ERROR=~p, ~p~n",[Error,erlang:get_stacktrace()]),
            wf:redirect("/?error")
    end.

