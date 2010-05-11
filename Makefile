
all:
	erl -make

init:
	-mkdir ebin
	-mkdir dep
	-mkdir -p www/css/
	-mkdir -p www/js
	-mkdir -p www/nitrogen
	-(cd www/nitrogen; ln -s /home/tobbe/git/nitrogen/apps/nitrogen/www/nitrogen.css .)
	-(cd www/nitrogen; ln -s /home/tobbe/git/nitrogen/apps/nitrogen/www/nitrogen.js .)
	-(cd www/nitrogen; ln -s /home/tobbe/git/nitrogen/apps/nitrogen/www/livevalidation.js .)
	-mkdir templates
	-chmod +x ./start.sh
	-(for i in `ls dep/*`; do cd ${i}; make; done)
	cp src/redhot2.app.src ebin/redhot2.app 
	$(MAKE) all

clean:
	rm -rf ./ebin/*.beam

