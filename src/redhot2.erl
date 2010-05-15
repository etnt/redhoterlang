%%% @author Torbjorn Tornkvist <etnt@redhoterlang.com>
%%% @copyright (C) YYYY, Torbjorn Tornkvist

-module(redhot2).

-export([couchdb_url/0
         , couchdb_host/0
         , couchdb_port/0
         , passwd/0
         , authors/0
         , mail_from/0
         , twitter_user/0
         , twitter_passwd/0
         , log_dir/0
         , top_dir/0
         , author2email/1
         , maybe_nick/1
         , to_latin1/1
         , process_markdown/1
	 , gnow/0
         , gtostr/1
         , gtostr/2
         , gdate2datetime/1
         , rfc3339/0
         , rfc3339/1
         , hostname/0
         , default_port/0
         , i2l/1
         , b2l/1
         , l2b/1
         , replace/2
        ]).

-import(redhot2_deps, [get_env/2]).

-include_lib("nitrogen/include/wf.hrl").

couchdb_url() ->
    "http://"++couchdb_host()++":"++integer_to_list(couchdb_port()).

couchdb_host()      -> get_env(couchdb_host, "localhost").
couchdb_port()      -> get_env(couchdb_port, 5984).
passwd()            -> get_env(passwd, "xyzzyzeke").
authors()           -> get_env(authors, []).
mail_from()         -> get_env(mail_from, []).
twitter_user()      -> get_env(twitter_user, []).
twitter_passwd()    -> get_env(twitter_passwd, []).
log_dir()           -> get_env(error_logger_mf_file, "/tmp/redhot").

top_dir() ->
    filename:join(["/"|lists:reverse(tl(lists:reverse(string:tokens(filename:dirname(code:which(?MODULE)),"/"))))]).


author2email(Nick) when is_binary(Nick) ->
    author2email(b2l(Nick));
author2email(Nick) when is_list(Nick) ->
    {value,{_,_,Email}} = lists:keysearch(Nick, 2, authors()),
    Email.

maybe_nick(Who) ->
    case lists:keysearch(Who, 1, authors()) of
        {value,{Who, Nick, _Email}} -> Nick;
        _                           -> Who
    end.


%% The stupid browser persist to send utf-8 characters...
to_latin1(Str) when is_list(Str) -> to_latin1(list_to_binary(Str));
to_latin1(Str) when is_binary(Str) ->
    case binary_to_list(<< <<C>> || <<C/utf8>> <= Str >>) of
        []   -> Str;
        Lstr -> Lstr
    end.


process_markdown(Txt) when is_binary(Txt) ->
    {A,B,C} = erlang:now(),
    Fname = i2l(A)++i2l(B)++i2l(C),
    Path = filename:join(["/tmp", Fname]),
    Res = Path++".res",
    file:write_file(Path, Txt),
    os:cmd("markdown "++Path++" > "++Res),
    {ok, Result} = file:read_file(Res),
    os:cmd(" rm -f "++Path++" "++Res),
    Result.

rfc3339() ->
    rfc3339(calendar:now_to_local_time(now())).

rfc3339(Gsec) when is_integer(Gsec) ->
    rfc3339(gdate2datetime(Gsec));

rfc3339({{Year, Month, Day}, {Hour, Min, Sec}}) ->
    io_lib:format("~4..0w-~2..0w-~2..0wT~2..0w:~2..0w:~2..0w~s",
                  [Year,Month,Day, Hour, Min, Sec, zone()]).  

zone() ->
    Time = erlang:universaltime(),
    LocalTime = calendar:universal_time_to_local_time(Time),
    DiffSecs = calendar:datetime_to_gregorian_seconds(LocalTime) -
        calendar:datetime_to_gregorian_seconds(Time),
    zone(DiffSecs div 3600, (DiffSecs rem 3600) div 60).

zone(Hr, Min) when Hr < 0; Min < 0 ->
    io_lib:format("-~2..0w~2..0w", [abs(Hr), abs(Min)]);
zone(Hr, Min) when Hr >= 0, Min >= 0 ->
    io_lib:format("+~2..0w~2..0w", [Hr, Min]).



          
%%-----------------------------------------------------------------------------
%% @doc Return gregorian seconds as of now()
%%-----------------------------------------------------------------------------
gnow() ->
    calendar:datetime_to_gregorian_seconds(calendar:local_time()).

%%-----------------------------------------------------------------------------
%% @spec gtostr(Gsecs::greg_secs()) -> string()
%% @doc Equivalent to <code>gtostr(Gsecs, date_time)</code>.
%%-----------------------------------------------------------------------------
gtostr(Secs) when is_float(Secs) -> gtostr(trunc(Secs)); % float !??
gtostr(Secs) -> gtostr(Secs, date_time).

%%-----------------------------------------------------------------------------
%% @spec gtostr(Gsecs::greg_secs(), Format::format()) -> string()
%% @doc Returns standard format string
%% The returned formats look like this:
%% <pre>
%% Returns : date      -> "YYYY-MM-DD"
%%           xdate     -> "YYYYMMDD"
%%           time      -> "HH:MM:SS"
%%           date_time -> "YYYY-MM-DD HH:MM:SS"  (default)
%%           iso8106   -> "YYYYMMDDTHHMMSS"
%% </pre>
%% Note    : the YYYY part can be 1+ chars
%%-----------------------------------------------------------------------------
gtostr(undefined, _) -> "-";
gtostr(Secs, date) ->
    {{Year, Month, Day}, _} = calendar:gregorian_seconds_to_datetime(Secs),
    lists:flatten(io_lib:format("~w-~2.2.0w-~2.2.0w", [Year, Month, Day]));
gtostr(Secs, xdate) ->
    {{Year, Month, Day}, _} = calendar:gregorian_seconds_to_datetime(Secs),
    lists:flatten(io_lib:format("~w~2.2.0w~2.2.0w", [Year, Month, Day]));
gtostr(Secs, xdatex) ->
    {{Year, Month, Day}, _} = calendar:gregorian_seconds_to_datetime(Secs),
    Year2 = Year rem 1000,
    lists:flatten(io_lib:format("~2.2.0w~2.2.0w~2.2.0w", [Year2, Month, Day]));
gtostr(Secs, days) ->
    {{Year, Month, Day}, _} = calendar:gregorian_seconds_to_datetime(Secs),
    lists:flatten(io_lib:format("~w", [calendar:date_to_gregorian_days(
					 Year, Month, Day)]));
gtostr(Secs, time) ->
    {_, {Hour, Minute, Second}} = calendar:gregorian_seconds_to_datetime(Secs),
    lists:flatten(io_lib:format("~2.2.0w:~2.2.0w:~2.2.0w",
				[Hour, Minute, Second]));
gtostr(Secs, date_time) ->
    {{Year, Month, Day}, {Hour, Minute, Second}} =
	calendar:gregorian_seconds_to_datetime(Secs),
    lists:flatten(io_lib:format("~w-~2.2.0w-~2.2.0w ~2.2.0w:~2.2.0w:~2.2.0w",
				[Year, Month, Day, Hour, Minute, Second]));
gtostr(Secs, iso8601) ->
    {{Year, Month, Day}, {Hour, Minute, Second}} =
	calendar:gregorian_seconds_to_datetime(Secs),
    lists:flatten(io_lib:format("~w~2.2.0w~2.2.0wT~2.2.0w~2.2.0w~2.2.0w",
				[Year, Month, Day, Hour, Minute, Second])).

gdate2datetime(Secs) ->
    calendar:gregorian_seconds_to_datetime(Secs).


default_port() -> 8080.

hostname() ->
    {ok,Host} = inet:gethostname(),
    Host.

i2l(I) when is_integer(I) -> integer_to_list(I);
i2l(L) when is_list(L)    -> L.
    
b2l(B) when is_binary(B) -> binary_to_list(B);
b2l(L) when is_list(L)   -> L.
    
l2b(L) when is_list(L)   -> list_to_binary(L);
l2b(B) when is_binary(B) -> B.

replace({K,_}=H, [{K,_}|T]) -> [H|T];
replace(X, [H|T])           -> [H|replace(X,T)];
replace(_, [])              -> [].
