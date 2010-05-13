%%% @author Torbjorn Tornkvist <tobbe@tornkvist.org>
%%% @copyright (C) 2009-2010, Torbjorn Tornkvist

-module(redhot2_twitter).

-export([run/0, run/1]).

-import(redhot2, [twitter_user/0, twitter_passwd/0]).

-include_lib("nitrogen/include/wf.hrl").
-include_lib("xmerl/include/xmerl.hrl").

-define(txt(X),
    (fun() ->
       #xmlElement{name = _, 
                   content = [#xmlText{value = V}|_]} = X,
             V end)()).

-define(href(X),
    (fun() ->
       #xmlElement{name = _, 
                   attributes = As} = X,
             [#xmlAttribute{value = V}|_] = 
                 [W || W <- As,W#xmlAttribute.name == href],
             V end)()).



run() ->
    run("erlang").

run(KeyWord) ->
    Url = twitter_atom_search_url(KeyWord),
    Digest = base64:encode_to_string(twitter_user()++":"++twitter_passwd()),
    Request = {Url, [{"authorization","Basic "++Digest}]},
    case http:request(get, Request, [], []) of
        {ok,{{_,200,_}, _Headers, Content}} ->
            parse(Content);
        Else ->
            throw(Else)
    end.

parse(String) ->
    {Xml, _} = xmerl_scan:string(String),
    Z1 = [?txt(X) || X <- xmerl_xpath:string("//entry/author/name", Xml)],
    Z2 = [?txt(X) || X <- xmerl_xpath:string("//entry/author/uri", Xml)],
    Z3 = [fix_unicode(?txt(X)) || X <- xmerl_xpath:string("//entry/title", Xml)],
    lists:zip3(Z1,Z2,Z3).



twitter_atom_search_url(Q) ->
    twitter_search_url("atom")++"?q="++Q.

twitter_search_url(Type) ->
    "http://search.twitter.com/search."++Type.

%% Workaround for xmerl bug ?
fix_unicode(XmlString) ->
    Binary = unicode:characters_to_binary(XmlString, unicode),
    binary_to_list(Binary). 
