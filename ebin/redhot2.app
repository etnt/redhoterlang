{application, redhot2, 
 [
  {description,  "redhot2 - bla bla..."},

  % The Module and Args used to start this application.
  {mod, { redhot2_app, []} },

  % All modules used by the application.
  {modules,
   [redhot2
    ,redhot2_app
    ,redhot2_sup
    ,redhot2_deps
    ,redhot2_common
    ,redhot2_inets
    ,redhot2_web_index
    ,redhot2_web_login
    ,redhot2_web_logout
    ,redhot2_web_auth
   ]},

  % configuration parameters similar to those in the config file specified on the command line
  {env, [{ip, "0.0.0.0"}
         ,{port, 8283}
	 ,{log_dir, "/tmp"}
	 ,{doc_root, "./www"}
	 ,{twitter_user, "kruskakli"}
	 ,{twitter_passwd, "mortuta42"}
	 ,{authors, [{"http://etnt.myopenid.com/" % Claimed OpenID
                     ,"tobbe"                    % Nickname
                     ,"tobbe@tornkvist.org"},    % Email,
                    {"http://mats.cronqvist.myopenid.com/"
                     ,"masse"                 
                     ,"masse@cronqvi.st"},
                    {"http://klacke.myopenid.com/"
                     ,"klacke"                 
                     ,"klacke@hyber.org"} 
                   ]}

        ]
  }
]}.
