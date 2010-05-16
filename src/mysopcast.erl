%% -*- mode: erlang; erlang-indent-level: 2 -*-
%%% Created : 21 Dec 2009 by mats cronqvist <masse@kreditor.se>

%% scrapes sopcasted events from myp2p.eu
%% there's one page per sport, that has links to many games.
%% one page per game, that has links to many streams.

-module('mysopcast').
-author('mats cronqvist').
-export([sport/0
        , sport/1]).

sport() ->
  [sport(S) || S <- sports()].

sport(Sport) ->
  inets:start(),
  try 
    {ok,{_,_,HTML}} = http:request(get,{sport_url(Sport),""},[],[]),
    {match,Games} = re:run(HTML,sport_re(),[{capture,[1],list},global]),
    {Sport,games(Games,protocols())}
  catch
    _:R -> {error,R}
  end.

sports() ->
  [football,soccer,hoops,hockey].

protocols() ->
  [sopcast].

games([],_) -> [];
games([[Game]|Games],Protocols) -> 
  {ok,{_,_,HTML}} = http:request(get,{game_url(Game),""},[],[]),
  case streams(HTML,Protocols) of
    [] -> games(Games,Protocols);
    Ss -> [{game(HTML),Ss}|games(Games,Protocols)]
  end.

streams(_,[]) -> [];
streams(HTML,[Protocol|Ps]) ->
  case re:run(HTML,stream_re(Protocol),[{capture,[1],list},ungreedy,global]) of
    {match,Ss} -> lists:usort([S||[S]<-Ss])++streams(HTML,Ps);
    nomatch    -> streams(HTML,Ps)
  end.

game(HTML) ->
  {match,[Match]} = re:run(HTML,game_re(),[{capture,[1],list}]),
  {match,[From,To]} = re:run(HTML,time_re(),[{capture,[1,2],list}]),
  From++"-"++To++" :: "++Match.

sport_url(football) -> sport_url("americanfootball");
sport_url(hockey)   -> sport_url("icehockey");
sport_url(soccer)   -> sport_url("football");
sport_url(hoops)    -> sport_url("basketball");
sport_url(Sport) -> 
  "http://www.myp2p.eu/competition.php?"
    "competitionid=&part=sports&discipline="++Sport.

game_url(Game) ->
  "http://www.myp2p.eu/broadcast.php?matchid="++Game.

sport_re() ->
  "matchid=([0-9]+)".

stream_re(sopcast) -> 
  "icon_online.gif[^>]*>[^<]*<span[^>]*><b>Sopcast</b></span></td><td[^>]*>"
    "<span[^>]*>"
    "<a href[\"\\s=]*(sop://[-a-z0-9_\\.]+:[0-9]+/[0-9]+)[^0-9]".

game_re() ->
  "<title>[^:]*::\\s*([^<]*)</title>".

time_re() ->
  "<tr><td[^>]*><b>Match scheduled:<br>Last updated:</b></td><td[^>]*>"
    "[0-9-]*\\s*from\\s*([0-9:]*)\\s*until\\s*([0-9:]*)[^<]*<br>"
    "[^<]*</td></tr>".
