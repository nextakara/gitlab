NAME=gitlab
VERSION=7.9-20151029
DOCKER_RUN_OPTIONS=\
	--add-host=gitlab:172.17.240.1 \
	--privileged \
	-v /var/gitlab/:/home/git/


include docker.mk
