NAME=gitlab
VERSION=7.9-20151029

build:
	docker build -t $(NAME):$(VERSION) .

restart: stop start

start:
	docker run -itd \
		--privileged \
		--name $(NAME) \
		--add-host=gitlab:172.17.240.1 \
		-v /var/gitlab/:/home/git/ \
		-h $(NAME) \
		$(NAME):$(VERSION) bash


all_container=`docker ps -a -q`
image=`docker images | awk '/^<none>/ { print $$3 }'`

clean: clean_container
	@if [ "$(image)" != "" ] ; then \
		docker rmi $(image); \
	fi

stop:
	docker rm -f $(NAME)

attach:
	docker exec -it $(NAME) /bin/bash

logs:
	docker logs $(NAME)

tag:
	docker tag $(NAME):$(VERSION) $(NAME):latest

active_container=`docker ps -q`

clean_container:
	@for a in $(all_container) ; do \
		for b in $(active_container) ; do \
			if [ "$${a}" = "$${b}" ] ; then \
				continue 2; \
			fi; \
		done; \
		docker rm $${a}; \
	done

