# The RedHotErlang Blog

![Logo Image](https://github.com/etnt/redhoterlang/blob/main/www/images/chili.png)

This the RedHotErlang Blog system I managed to salvage from an old
Bitbucket archive. It made use of Nitrogen + CouchDB.

## REQUIREMENTS
------------
Get Nitrogen (and perhaps EOpenId):

    mkdir $HOME/git
    cd $HOME/git
    git clone http://github.com/rklophaus/nitrogen.git
    (git clone http://github.com/etnt/eopenid.git)
 
Build the above code by running make in their resp. top dir.


## SETUP
----
In the redhot2 directory, first edit the paths in the 'dep.inc' file.

Then run:

    make init

To compile the source code of the polish application:

    make

Now, change the config settings in ebin/redhot2.app before starting
the system as:

    ./start.sh
