%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright YYYY Torbjorn Tornkvist.

%% @doc The terminating leg of the OpenID authentication.

-module(redhot2_web_auth).

-export([main/0]).

-include_lib ("nitrogen/include/wf.hrl").


main() -> 
    try
        Dict = wf:session(eopenid_dict),
        RawPath = redhot2_common:raw_path(),
        %% assertion
        true = eopenid_v1:verify_signed_keys(RawPath, Dict),
        ClaimedId = eopenid_lib:out("openid.claimed_id", Dict),
        wf:user(ClaimedId),
        wf:session(authenticated, true),
        wf:redirect(wf:qs("p"))
    catch
	_:_Err ->
            io:format("~p: Error(~p), ~p~n",[?MODULE,_Err,erlang:get_stacktrace()]),
            % FIXME a better way of presenting errors (jGrowl ?)
            wf:redirect("/error?emsg=authentication_failed")
    end.

	
