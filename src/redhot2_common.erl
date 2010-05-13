%% @author Torbjorn Tornkvist <etnt@redhoterlang.com>
%% @copyright 2010 Torbjorn Tornkvist

-module(redhot2_common).

-include_lib ("nitrogen/include/wf.hrl").

-export([title/0
         , header/1
         , footer/0
         , right/0
         , left/0
         , gravatar/1
         , raw_path/0
        ]).

title() ->
    "redhot2".


right() ->
    #panel { class=right, body=[] }.


left() ->
    #panel { class=left, body=[redhot2_nav:list_entries()] }.

raw_path() ->
    RequestBridge = wf_context:request_bridge(),
    RequestBridge:uri().



gravatar(Email) ->
    #gravatar { email=Email,
		size="30", 
		rating="g", 
		default="identicon" }.


header(Selected) ->
    wf:wire(Selected, #add_class { class=selected }),
    #panel { body = [#h1 { class=header,
                           text = "<span class='big'>R</span>ed<span class='big'>H</span>ot<span class='big'>E</span>rlang", html_encode=false},
                     #panel { class=menu, 
                              body=[#link { id=home,   url='/',            text="Home"  },
                                    #link { id=logout, url='/logout',      text="Logout"  },
                                    #link { id=about,  url='/about',       text="About"  }
                                   ]}
                    ]}.

footer() ->
    [#br{},
     #panel { class=credits, body=[
        "
        Copyright &copy; 2010 <a href='http://www.redhoterlang.com'>Torbjorn Tornkvist</a>. 
        Released under the MIT License.
        "
    ]}].

