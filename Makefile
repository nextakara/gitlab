NAME=gitlab
VERSION=7.9-20151030
DOCKER_RUN_OPTIONS=\
	--add-host=gitlab:172.17.240.1 \
	-v /var/gitlab/:/home/git/ \
	-v /var/gitlab/uploads:/var/gitlab/gitlab/public/uploads/ \
	--privileged


include docker1.mk
