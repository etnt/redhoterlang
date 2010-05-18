-module(redhot2_sendmail).
-export([send/4
         ,send/5
        ]).

-ignore_xref([{send,4}]).

send(To, From, Subject, Text) ->
    send(To, From, Subject, Text, "text/plain").

send(To, From, Subject, Text, ContentType) ->
    do_send(To, From, Subject, Text, ContentType).

do_send(To0, From, Subject, Text, ContentType) ->
    Data = list_to_binary(["To: ", To0, "\n",
                           "From: ", From, "\n",
                           %% Assume not too long line here!
                           "Subject: ", Subject, "\n",  
                           "Content-type: ", ContentType,"\n",
                           "\n\n",
                           Text]),
    To = shell_quote(To0),
    ErrFile = "redhot_mail.error",
    P = open_port({spawn, "/usr/sbin/sendmail -f " ++ From ++
                                  " -bm " ++ To ++ " 2> " ++ ErrFile}, 
                  [stream, eof]),
    P ! {self(), {command, Data}},
    P ! {self(), close},
    rec_data(P, To),
    P ! {self(), close}.

rec_data(P, User) ->
    receive
        {P, {data, _Data}} -> rec_data(P, User);
        {P, closed}        -> ok;
        {P, eof}           -> ok
    after 15000            -> ok
    end.

shell_quote(String) ->
    %% 1. Put single quotes around the string.
    "'" ++
        %% 2. Remove any single quote
        [C || C <- lists:flatten(String),
              C =/= $' % ' emacs
                 ] 
        ++ "'". 

