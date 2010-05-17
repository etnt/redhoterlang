%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright 2010, Torbjorn Tornkvist.
%%
%% @doc Handling of backward compatibility issues.
%% @end

-module(redhot2_web_bwcompat).

-include_lib("nitrogen/include/wf.hrl").

-export([main/0
	]).


main() ->
    case string:tokens(redhot2_common:raw_path(), "/?") of
        [_,"plink"|_] -> 
            % v.3 used /web/plink?id=.... for permalinks
            wf:redirect("/entry/"++wf:qs("id"));
        [_,"atom"|_] -> 
            redhot2_web_atom:main();
        _ -> 
            wf:redirect("/fixme_error_msg_here")
    end.

