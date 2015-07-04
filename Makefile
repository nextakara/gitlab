NAME=debian_gitlab

build:
	docker build -t $(NAME) .

restart: stop start

start:
	docker run -itd \
		-p 222:222 \
		-p 300:80 \
		-v /var/repositories:/home/git/repositories \
		-v /var/repositories/git/ssh:/home/git/.ssh \
		--name $(NAME) \
		$(NAME) bash

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
	docker attach $(NAME)

logs:
	docker logs $(NAME)
