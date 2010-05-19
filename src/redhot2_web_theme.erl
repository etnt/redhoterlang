%%% @author Torbjorn Tornkvist <etnt@redhoterlang.com>
%%% @copyright (C) 2010, Torbjorn Tornkvist

-module(redhot2_web_theme).

-export([main/0]).

-include_lib ("nitrogen/include/wf.hrl").


main() -> 
%%    io:format("~p: redirect to: ~p~n",[?MODULE,"/css/"++theme_filename()]),
%%    wf:redirect("/css/"++theme_filename()).
    try
        Fname = redhot2:top_dir()++"/www/css/"++theme_filename(),
        {ok, Bin} = file:read_file(Fname),
        wf:status_code(200),
        set_content_disposition("style.css"),
        %wf:header(content_type,"text/css"), % inets wants 'content_type'....
        wf:content_type("text/css"), % works with my patched nitrogen repo
        [Bin]
    catch
        _:_ ->
        wf:status_code(404),
        wf:content_type("text/plain"),
        "The file could not be found!"
    end.


theme_filename() ->
    case wf:session(theme) of
        "digitalchili" -> "digitalchili.css";
        "whitechili"   -> "whitechili.css";
        "cantarell"    -> "cantarell.css";
        _              -> "digitalchili.css"
    end.

set_content_disposition(Fname) when is_binary(Fname) ->
    set_content_disposition(binary_to_list(Fname));
set_content_disposition(Fname) ->
    wf:header("Content-Disposition", "filename=\""++Fname++"\"").
