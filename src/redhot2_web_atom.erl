%%% @author Torbjorn Tornkvist <etnt@redhoterlang.com>
%%% @copyright (C) 2010, Torbjorn Tornkvist

-module(redhot2_web_atom).

-export([main/0]).
-import(redhot2,[rfc3339/0]).

-include_lib ("nitrogen/include/wf.hrl").


main() -> 
    atom_feed().

atom_feed() ->
    export(feed(entries())).
% mochiweb
%    list_to_binary(export(feed(entries()))).

entries() ->
    F = fun({obj,E},Acc) ->
                {Xml,_} = xmerl_scan:string(binary_to_list(
                                              proplists:get_value("entry",E))),
                [Xml|Acc]
        end,
    lists:foldr(F, [], redhot2_couchdb:atom()).

feed(Entries) ->
    [{feed, [{xmlns,"http://www.w3.org/2005/Atom"}],
      [{title, [], ["RedHotErlang"]},
       {meta, [{'http-equiv',"Content-Type"},
	       {content,"application/atom+xml;charset=utf-8"}], []},
       {link, [{ref,"self"},{href,"/web/atom"}], []},
       {updated, [], [lists:flatten(rfc3339())]}  % FIXME
      ] ++ Entries
     }].


export(Content) ->
    xmerl:export_simple(Content, xmerl_xml, [{prolog,prolog()}]).


prolog() ->
    "<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>\n".

