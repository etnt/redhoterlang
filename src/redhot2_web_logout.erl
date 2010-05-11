%%% @author Torbjorn Tornkvist <etnt@redhoterlang.com>
%%% @copyright (C) 2010, Torbjorn Tornkvist

-module(redhot2_web_logout).

-export([main/0]).

-include_lib ("nitrogen/include/wf.hrl").


main() -> 
    wf:user(undefined),
    wf:session(authenticated, false),
    wf:redirect("/").


	
