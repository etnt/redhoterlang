%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright YYYY Torbjorn Tornkvist.

-module(redhot2_web_entry).

-include_lib("nitrogen/include/wf.hrl").

-export([main/0
         , title/0
         , layout/0
	 , event/1
	]).

-import(redhot2,
        [author2email/1
         , maybe_nick/1
         , gtostr/1
         , to_latin1/1
         , b2l/1
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
        body=[#grid_12 { class=header, body=redhot2_common:header(home) },
              #grid_clear {},

              #grid_10 { alpha=true, body=article() },
              #grid_2 { omega=true, body=redhot2_common:right() },
              #grid_clear {},
              
              #grid_12 { body=redhot2_common:footer() }
             ]}.

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
    #panel{body=[#span{class="e_date" , text=gtostr(C)},
                 #span{class="e_title", text=to_latin1(T)},
                 %#panel{class="e_author", body=["by: ",#span{class="blue",text=A}]},
                 #panel{class="e_author", body=[#panel{body=[gravatar(author2email(A))]},
						#panel{body=["by: ",#span{class="blue",text=A}]}]},
                 #panel{class="l_body" , body=to_latin1(H)}
%                 #panel{class="e_comhdr", body=comhdr(Comform,Id)},
%                 #panel{class=Comform, body=comform(Comform,Id)},
%                 #panel{class="l_comments" , 
%                        body=format_comments(Id)}
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
            Op = fun() -> nav:mk_article(Id) end,
% FIXME            push(Op),
            mk_openid_form(openid_comment_form_text())
    end.


%%%
%%% Format the comments
%%%
format_comments(Id) ->
    F = fun({obj,L}) ->
                C = proplists:get_value("created", L),
                T = proplists:get_value("text", L),
                W = proplists:get_value("who",L),
                A = proplists:get_value("author",L),
                {true, {W,C,T,A}}
        end,
    Cs = redhot_couchdb:find(F, ["rows","value"], redhot_couchdb:comments(Id)),
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


mk_openid_form(Text) ->
    B=#panel{class="openid",
             body = [#panel{body=[Text]},
                     #panel{class="openid_box",
                            body=[#panel{body=[#textbox{ class="openid_login", 
                                                         id="claimed_id", 
                                                         next="auth" }]},
                                  #panel{body=[#button{ id="auth", 
                                                        text="Authenticate"}]}]}
                    ]},
    wf:wire("auth", #event {type=click, 
                            postback=claimed_id, 
                            delegate=?MODULE}),
    B.

openid_comment_form_text() ->
    "To avoid spammers you are required to authenticate yourself "
        "with OpenId. A bit of a hassle perhaps "
        "but the upside is that you'll be exercising the "
        "<a href='http://github.com/etnt/eopenid'>eopenid</a> code.".


c_is_author(true) -> "c_is_author";
c_is_author(_)    -> "".

c_txt(true) -> "c_txt c_is_author_txt";
c_txt(_)    -> "c_txt".
