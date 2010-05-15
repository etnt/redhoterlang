%% @author Torbjorn Tornkvist <etnt@redhoterlang.com>
%% @copyright 2010 Torbjorn Tornkvist

-module(redhot2_nav).

-include_lib ("nitrogen/include/wf.hrl").

-export([event/1
         , list_entries/0
        ]).

-import(redhot2, [gtostr/2
                  , to_latin1/1
                  , b2l/1
                 ]).


event({entry,Id}) ->
    wf:redirect("/entry/"++b2l(Id));
event({edit,Id}) ->
    wf:redirect("/edit/"++b2l(Id));
event(Event) ->
    io:format("~p: Event = ~p~n",[?MODULE,Event]),
    wf:redirect("/").
    


list_entries() ->
    Auth = wf:session(authenticated),
    F = fun({obj,L}, Acc) ->
                case {Auth, proplists:get_value("published",L)} of
                    {Auth, PubP} when PubP == true orelse (Auth == true andalso (not PubP)) ->
                        [list_entry(Auth, L, PubP) | Acc];
                    _ ->
                        Acc
                end
        end,
    lists:foldr(F, [], redhot2_couchdb:entries()).

list_entry(Auth, L, PubP) ->
    C = trunc(proplists:get_value("created",L)), % hm...a float here strange.. 
    A = proplists:get_value("author",L),
    T = proplists:get_value("title",L),
    R = proplists:get_value("id",L),
    Tid = wf:temp_id(),
    Xid = wf:temp_id(),
    M = #panel { body =
                 [#panel { body =
                           [if (Auth andalso (not PubP)) ->
                                    #panel{class="l_date_unpub",
                                           body=[#link {id=Xid,
                                                        text=gtostr(C, date)}]};
                               true ->
                                    #panel {class="l_date" , body=gtostr(C, date)}
                            end,
                            #panel {class="l_author", body=to_latin1(A)},
                            #link {class="l_title", id=Tid, text=to_latin1(T)}
                            ]}]},
    wf:wire(Tid, #event {type=click, postback={entry,R}, delegate=?MODULE}),
    if (Auth andalso (not PubP)) ->
            wf:wire(Xid, #event {type=click, postback={edit,R}, delegate=?MODULE});
       true ->
            false
    end,
    M.

