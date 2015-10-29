NAME=gitlab
VERSION=7.9-20151027

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


contener=`docker ps -a -q`
image=`docker images | awk '/^<none>/ { print $$3 }'`

clean:
	@if [ "$(image)" != "" ] ; then \
		docker rmi $(image); \
	fi
	@if [ "$(contener)" != "" ] ; then \
		docker rm $(contener); \
	fi

stop:
	docker rm -f $(NAME)

attach:
	docker exec -it $(NAME) /bin/bash

logs:
	docker logs $(NAME)

tag:
	docker tag $(NAME):$(VERSION) $(NAME):latest

