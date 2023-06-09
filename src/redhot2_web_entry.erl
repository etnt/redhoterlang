%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright 2010, Torbjorn Tornkvist.

-module(redhot2_web_entry).

-include_lib("nitrogen/include/wf.hrl").

-export([main/0
         , title/0
         , layout/0
	 , event/1
	]).

-import(redhot2,
        [author2email/1
         , is_valid_author/2
         , maybe_nick/1
         , mail_from/0
         , gtostr/1
         , to_latin1/1
         , b2l/1
         , l2b/1
         , gnow/0
        ]).

-import(redhot2_common,
        [gravatar/1
        ]).


main() ->
    #template { file="./templates/grid.html" }.

title() ->
    redhot2_common:title().

layout() ->
    #container_12 {
        body=[#grid_12 { class=header, body=redhot2_common:header() },
              #grid_clear {},

              #grid_10 { alpha=true, body=article() },
              #grid_2 { omega=true, body=redhot2_common:right() },
              #grid_clear {},
              
              #grid_12 { body=redhot2_common:footer() }
             ]}.


event({comment, Id}) ->
    case {wf:session(authenticated), wf:user()} of
        {true, Who} ->
            [Text] = wf:qs("com_text"),
            {obj,L} = redhot2_couchdb:entry(Id),
            Author = proplists:get_value("author",L),
            Title = proplists:get_value("title",L),
            redhot2_couchdb:store_comment(l2b(Id), 
                                          l2b(Text), 
                                          l2b(maybe_nick(Who)), 
                                          gnow(), 
                                          is_valid_author(Author, Who)),
            Email = author2email(Author),
            spawn(fun() -> redhot2_sendmail:send(Email, mail_from(), 
                                                 "New Comment...", 
                                                 "...on your article: "++Title) 
                  end),
            wf:redirect("/entry/"++Id);
        _ ->
            wf:redirect("/entry/"++Id)
    end;
event(Event) ->
    io:format("Event=~p~n",[Event]),
    ok.


article() ->
    case string:tokens(redhot2_common:raw_path(), "/") of
        [_,Id] -> article(Id);
        _      -> wf:redirect("/fixme_error_msg_here")
    end.

article(Id) ->
    {obj,L} = redhot2_couchdb:entry(Id),
    C = proplists:get_value("created",L),
    T = proplists:get_value("title",L),
    A = proplists:get_value("author",L),
    H = proplists:get_value("html",L),
    Comform = "e_comform",
    #panel{body=[#panel{class="e_author", 
                        body=[#panel{body=[gravatar(author2email(A))]},
                              #panel{body=["by: ",#span{class="by_who",text=A}]}]},
                 #span{class="e_date" ,      text=gtostr(C)},
                 #span{class="e_title",      text=to_latin1(T)},
                 #panel{class="l_body" ,     body=to_latin1(H)},
                 #panel{class="e_comhdr",    body=comhdr(Comform,Id)},
                 #panel{class=Comform,       body=comform(Comform,Id)},
                 #panel{class="l_comments" , body=format_comments(Id)}
                ]}.

comhdr(Comform, Id) ->
    Tid = wf:temp_id(),
    B=[#link{class="comhdr", text="permalink", url="/web/plink?id="++b2l(Id)},
       #link{id = Tid, class="comhdr", text="add comment"}],
    wf:wire(Tid, #event {type=click, actions=#script { script="$('."++Comform++"').toggle('slow');" }}),
    B.

%%%
%%% Add comment form
%%%
comform(_Comform, Id) ->
    case wf:session(authenticated) of
        true ->
            B=[#panel{body=["Type in your comment! HTML is allowed "
                            "(enclose code blocks with &lt;pre&gt;&lt;code&gt;)."]},
               #panel{body=[#textarea { id="com_text",  class="comment", text=""}]},
               #panel{body=[#button   { id="com_submit",text="Submit"}]}],
            wf:wire("com_submit", #event {type=click, postback={comment,Id}, delegate=?MODULE}),
            B;
        _ ->
            openid_comment_form_text()
    end.


%%%
%%% Format the comments
%%%
format_comments(Id) ->
    F = fun({obj,L},Acc) ->
                [C,T,W,A] = 
                    [proplists:get_value(K,L) 
                     || K <- ["created","text","who","author"]],
                [{b2l(W),C,b2l(T),A}|Acc]
        end,
    Cs = lists:foldr(F, [], redhot2_couchdb:comments(Id)),
    G = fun({Who,Created,Text,Author}) ->
                #panel{class = "c_body",
                       body  = [#panel{class=c_is_author(Author),
                                       body=[#span{class="c_date", 
                                                   text=gtostr(Created)},
                                             #span{class="c_who", 
                                                   text=Who}]},
                                #panel{class=c_txt(Author),
                                       body=Text}]}
        end,
    [G(X) || X <- Cs].


openid_comment_form_text() ->
    "To avoid spammers you are required to authenticate yourself with OpenId."
        "<br />A bit of a hassle perhaps but the upside is that you'll be "
        "exercising the <a href='http://github.com/etnt/eopenid'>eopenid</a> "
        "code. <br />You'll find the OpenId login entry at the top of the page.".


c_is_author(true) -> "c_is_author";
c_is_author(_)    -> "".

c_txt(true) -> "c_is_author_txt";
c_txt(_)    -> "c_txt".
