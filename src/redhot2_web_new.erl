%% @author Torbjorn Tornkvist etnt@redhoterlang.com
%% @copyright 2010, Torbjorn Tornkvist.

-module(redhot2_web_new).

-include_lib("nitrogen/include/wf.hrl").

-export([main/0
         , title/0
         , layout/0
	 , event/1
	]).

-import(redhot2,
        [authors/0
        ]).

main() ->
    #template { file="./templates/grid.html" }.

title() ->
    redhot2_common:title().

layout() ->
    #container_12 {
        body=[#grid_12 { class=header, body=redhot2_common:header(new) },
              #grid_clear {},

              #grid_8 { alpha=true, body=intro() },
              #grid_4 { omega=true, body=[] },
              #grid_clear {},

              #grid_12 { alpha=true, body=new_page() },
              #grid_clear {},
              
              #grid_12 { body=redhot2_common:footer() }
             ]}.

intro() ->
    #panel { class = "intro",
             body = intro_text()}.

intro_text() ->
    "This is the page where the authors of "++redhot2_common:logo_text()++" input their new articles. "
        "The critera for becoming an author is to have shared (at least) one beer with <em>Tobbe</em>. "
        "Get in touch if you want to join as an author and you think you fulfill the requirement.".


event({claimed_id = Id,RawPath}) ->
    redhot2_web_login:claimed_id(hd(wf:qs(Id)),RawPath);
event(Event) ->
    io:format("Event=~p~n",[Event]),
    ok.


new_page() ->
    case wf:session(authenticated) of
        true ->
            case lists:keymember(wf:user(), 1, authors()) of
                true -> 
                    mk_entry_form("Title", "Some Markdown text...", new_entry);
                _ ->
                    #p{body=not_author_text()}
            end;
        _ ->
            #p{body=openid_text()}
    end.

not_author_text() ->
    "Sorry, but you're not registered as an author.".

openid_text() ->
    "You need to authenticate yourself!<br />"
        "You'll find the OpenId login entry at the top of the page.".


mk_entry_form(Title, Markdown, Postback) ->
    mk_entry_form(Title, Markdown, Postback, "", "").

mk_entry_form(Title, Markdown, Postback, Id, Rev) ->
    Mid = wf:temp_id(),

    L = [#panel{body=[markdown_help()], class="mdown_help"},
	 #panel{body=[#checkbox { id="publish", text="Publish"}, 
		      #link     { id=Mid, class="mdown_help_link", text="Markdown Help"}]},
	 #panel{body=[#textbox  { id="new_title", class="new", text=Title,     next="new_text" }]},
	 #panel{body=[#textarea { id="new_text",  class="new", text=Markdown, html_encode=false}]},
	 #panel{body=[#hidden   { id="id",  text=Id}]},
	 #panel{body=[#hidden   { id="rev", text=Rev}]},
	 #panel{body=[#button   { id="new_submit",text="Submit"}]}],

    M = case wf:user() of
	    "http://etnt.myopenid.com/" ->
		%% Some experiments with attachments
		[#panel{body=[#upload { tag=fileupload, button_text="Upload File" }]}];
	    _ ->
		[]
	end,

    B = #panel{body = L++M},
    wf:wire("new_submit", #event {type=click, postback=Postback, delegate=?MODULE}),
    wf:wire(Mid, #event {type=click, actions=#script { script="$('.mdown_help').toggle();" }}),
    B.



markdown_help() ->
  "<pre>
# Header 1 #
## Header 2 ##
### Header 3 ###             (Hashes on right are optional)
#### Header 4 ####
##### Header 5 #####

## Markdown plus h2 with a custom ID ##         {#id-goes-here}
[Link back to H2](#id-goes-here)

This is a paragraph, which is text surrounded by whitespace. Paragraphs can be on one 
line (or many), and can drone on for hours.  

Here is a Markdown link to [Warped](http://warpedvisions.org), to [Google][1] and a literal . 
Now some SimpleLinks, like one to [google] (automagically links to are-you-
feeling-lucky), a [wiki: test] link to a Wikipedia page, and a link to 
[foldoc: CPU]s at foldoc.  

[1]: http://www.google.com/

Now some inline markup like _italics_,  **bold**, and `code()`. Note that underscores in 
words are ignored in Markdown Extra.

![picture alt](/images/photo.jpeg \"Title is optional\")     

> Blockquotes are like quoted text in email replies
>> And, they can be nested

* Bullet lists are easy too
- Another one
+ Another one

1. A numbered list
2. Which is numbered
3. With periods and a space

And now some code:

    // Code is just text indented a bit
    which(is_easy) to_remember();
~~

// Markdown extra adds un-indented code blocks too

if (this_is_more_code == true && !indented) {
    // tild wrapped code blocks, also not indented
}

~~

Text with  
two trailing spaces  
(on the right)  
can be used  
for things like poems  

### Horizontal rules

* * * *
****
--------------------------


&lt;div class=\"custom-class\" markdown=\"1\"&gt;
This is a div wrapping some Markdown plus.  Without the DIV attribute,
 it ignores the 
block. 
&lt;/div&gt;
## Markdown plus tables ##

| Header | Header | Right  |
| ------ | ------ | -----: |
|  Cell  |  Cell  |   $10  |
|  Cell  |  Cell  |   $20  |

* Outer pipes on tables are optional
* Colon used for alignment (right versus left)

## Markdown plus definition lists ##

Bottled water
: $ 1.25
: $ 1.55 (Large)

Milk
Pop
: $ 1.75

* Multiple definitions and terms are possible
* Definitions can include multiple paragraphs too

*[ABBR]: Markdown plus abbreviations (produces an &lt;abbr&gt; tag)
</pre>".









