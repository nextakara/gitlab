NAME=gitlab
VERSION=7.9-20151024

build:
	docker build -t $(NAME):$(VERSION) .

restart: stop start

start:
	docker run -itd \
		--privileged \
		-v /var/gitlab/repositories:/home/git/repositories \
		-v /var/gitlab/ssh:/home/git/.ssh \
		-v /var/gitlab/uploads:/home/git/gitlab/public/uploads \
		--name $(NAME) \
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

