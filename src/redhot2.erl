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
         , hostname/0
         , default_port/0
         , i2l/1
         , b2l/1
         , l2b/1
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

