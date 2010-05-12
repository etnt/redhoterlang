%%% @author  Torbjorn Tornkvist <etnt@redhoterlang.com>
%%% @copyright (C) 2010 Torbjorn Tornkvist

-module(redhot2_couchdb).

-export([init/0
	 ,entries/0
	 ,ids/0
	 ,atom/0
	 ,comments/0
	 ,comments/1
         ,store_doc/1
         ,store_doc/2
	 ,update_user/1
        ]).

-export([http_get_req/1
         ,http_post_req/2
         ,http_post_req/3
         ,http_put_req/2
         ,http_put_req/3
         ,find/2
        ]).

-import(redhot2, [l2b/1,b2l/1]).


-define(DB_NAME, "eblog").
%%-define(DB_NAME, "rh2").
-define(HOST, redhot2:couchdb_url()).
-define(DESIGN_DOC, "_design/"++?DB_NAME).
-define(VIEWS_PATH, ?HOST ++ "/" ++ ?DB_NAME ++ "/" ++ ?DESIGN_DOC ++ "/_view/").
-define(DESIGN_PATH, ?HOST ++ "/" ++ ?DB_NAME ++ "/" ++ ?DESIGN_DOC).

-define(COMMENTS_VIEW,       "comments").
-define(ENTRIES_VIEW,        "entries").
-define(IDS_VIEW,            "ids").
-define(ATOM_VIEW,           "atom").
-define(NO_OF_COMMENTS_VIEW, "no_of_comments").


%%
%% @doc Get the entries from the db
%%
entries() ->
    get_from_couchdb(?VIEWS_PATH ++ ?ENTRIES_VIEW).

ids() ->
    get_from_couchdb(?VIEWS_PATH ++ ?IDS_VIEW).

atom() ->
    get_from_couchdb(?VIEWS_PATH ++ ?ATOM_VIEW).

comments() ->
    get_from_couchdb(?VIEWS_PATH ++ ?COMMENTS_VIEW).

comments(Id) ->
    get_from_couchdb(?VIEWS_PATH ++ ?COMMENTS_VIEW ++
                     "?descending=true&"
                     "startkey=[\""++b2l(Id)++"\",{}]&"
                     "endkey=[\""++b2l(Id)++"\",0]").

%% @doc Create the redhot2 database if it doesn't exist. 
%%      Also create the views if they don't exist
init() ->
    DbList = http_get_req(?HOST ++ "/_all_dbs"),
    case lists:member(l2b(?DB_NAME), DbList) of
	true ->
	    ok;
	false ->
	    http_put_req(?HOST ++"/"++ ?DB_NAME, [])
    end,
    init_design_doc(),
    ok.

%% @doc Create the redhot2 design document if it doesn't exist
init_design_doc() ->
    try
	http_get_req(?DESIGN_PATH)
    catch
	throw:_ ->
	    Z = [{"_id", l2b(?DESIGN_DOC)},
		 {"views", {obj, views()}}],
	    Body = rfc4627:encode({obj, Z}),
	    http_put_req(?DESIGN_PATH, Body)
    end.

views() ->
    [{?COMMENTS_VIEW, {obj, [{"map", l2b(comments_map())}]}}
     ,{?ENTRIES_VIEW, {obj, [{"map", l2b(entries_map())}]}}
     ,{?IDS_VIEW,     {obj, [{"map", l2b(ids_map())}]}}
     ,{?ATOM_VIEW,    {obj, [{"map", l2b(atom_map())}]}}
     ,{?NO_OF_COMMENTS_VIEW, {obj, [{"map", l2b(no_of_comments_map())},
                                    {"reduce", l2b(no_of_comments_reduce())}]}}
    ].

comments_map() ->
    "function(doc) {
       if (doc.type == 'comment') {
         emit([doc.ref, doc.created], doc);
       }
     };".

entries_map() ->
    "function(doc) {
       if (doc.type == 'blog') {
          var summary = (doc.html.replace(/<(.|\\\\n)*?>/g, '').substring(0,350) + '...');
          emit(doc.created, {
            id : doc._id,
            summary : summary,
            title : doc.title,
            created : doc.created,
            published: doc.published 
          });
       }
     };".

ids_map() ->
    "function(doc) {
       if (doc.type == 'blog') {
         emit(doc.created, doc._id);
       }      
     };".

atom_map() ->
    "function(doc) { 
      if (doc.type == 'blog' & doc.published) { 
        var summary = doc.html.substring(0,250) + '...';
        var s = summary.replace(/&/g,'&amp;').replace(/\</g,'&lt;').replace(/\>/g,'&gt;');
        var e = '<entry>\n'+
                ' <title>'+doc.title+'</title>\n'+
                ' <link href=\"http://www.redhoterlang.com/web/plink?id='+doc._id+'\"/>\n'+
                ' <id>'+doc._id+'</id>\n'+
                ' <updated>'+doc.created_tz+'</updated>\n'+
                ' <author>'+doc.author+'</author>\n'+
                ' <summary>'+s+'</summary>\n'+
                '</entry>\n';
        emit(doc.created, { entry : e});
      }
    };".

no_of_comments_map() ->
    "function(doc) {
       if (doc.type == 'comment') {
         emit([doc.ref, doc.created], doc);
       }
     };".

no_of_comments_reduce() ->
    "function(ks, vs, co) {
       if (co) {
         return sum(vs);
       } else {
         return vs.length;
       }
    };".



%%
%% @doc Take a key-value tuple list and store it as a new CouchDB document.
%%
store_doc(KeyValList) ->
    store_doc(KeyValList, redhot2:gnow()).

store_doc(KeyValList, Created) ->
    Z = [{"gsec", Created},
         {"created_tz", l2b(lists:flatten(redhot2:rfc3339(Created)))}
         | KeyValList],
    Body = rfc4627:encode({obj, Z}),
    http_post_req(?HOST ++"/"++ ?DB_NAME, Body).


%%
%% @doc Update a user document
%%
update_user(User) ->
    Id = binary_to_list(proplists:get_value("_id", User)),
    http_put_req(?HOST ++"/"++ ?DB_NAME ++ "/" ++ Id, rfc4627:encode({obj, User})).
    

get_from_couchdb(Url) ->
    R = http_get_req(Url),
    %% Just preserve the Json
    F = fun(X) -> {true,X} end,
    find(F, ["rows","value"], R).


%%%
%%% HTTP access
%%%

http_get_req(Url) ->
    case http:request(Url) of
        {ok,{ {_,200,_}, _Headers, Content}} ->
            {ok, Json, []} = rfc4627:decode(Content),
            Json;
        Else ->
            throw(Else)
    end.


http_post_req(Url, Body) ->
    http_post_req(Url, Body, []).

http_post_req(Url, Body, Hdrs) ->
    http_req(post, Url, Body, Hdrs).


http_put_req(Url, Body) ->
    http_put_req(Url, Body, []).

http_put_req(Url, Body, Hdrs) ->
    http_req(put, Url, Body, Hdrs).

http_req(Method, Url, Body, Hdrs) ->
    ContentType = "application/json",
    Request = {Url, Hdrs, ContentType, Body},
    http:request(Method, Request, [], []).

   
%%
%% @doc Traverse and extract data from a CouchDB reply.
%%
%%   find(["rows","value","text"],Json).
%%   find(fun(X) -> {true,element(2,X)} end, ["rows","value"],Jsonu).
%%
%% @end

find(Path, Json) ->
    find(fun(X) -> {true,X} end, Path, Json).

find(_, []      , _)                     -> [];
find(F, Path    , {obj,L})               -> fold(F, Path, L);
find(F, [Key]   , {Key,Val})             ->
    case F(Val) of
        {true, Res} -> [Res];
        false       -> []
    end;
find(F, [H|Path], {H,{obj,L}})           -> fold(F, Path, L);
find(F, [H|Path], {H,L}) when is_list(L) -> fold(F, Path, L);
find(_, _       , _)                     -> [].


fold(F, Path, Input) ->
    lists:foldl(fun(E,Acc) ->
                        case find(F,Path,E) of
                            [] -> Acc;
                            X -> X++Acc
                        end
                end, [], Input).
