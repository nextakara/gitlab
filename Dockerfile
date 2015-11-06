FROM debian:8.1

MAINTAINER taka2063

WORKDIR /root/

RUN apt-get update && apt-get -y upgrade

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get remove nginx nginx-full nginx-light nginx-common

RUN apt-get -y install vim gcc make wget tar net-tools
RUN apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate python-docutils pkg-config cmake nodejs
RUN apt-get install -y mysql-client libmysqlclient-dev libkrb5-dev git
RUN apt-get install -y daemon chkconfig
RUN apt-get -y install ntp apt-transport-https
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
COPY asset/passenger.list /etc/apt/sources.list.d/
RUN apt-get update
RUN apt-get -y install nginx-extras passenger

# ruby
RUN apt-get -y install ruby2.1 ruby2.1-dev rubygems 
RUN gem install bundler

RUN apt-get -y install postfix

ENV DEBIAN_FRONTEND dialog

RUN passenger-install-nginx-module --auto

# nginx
COPY asset/nginx.conf /etc/nginx/
COPY asset/gitlab /etc/nginx/sites-available/gitlab
RUN ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab


# gitlab
RUN useradd -m -s /bin/bash -c 'GitLab' git
RUN mkdir -p /var/gitlab && chown -R git.www-data /var/gitlab && chmod -R g+rw /var/gitlab

USER git
WORKDIR /var/gitlab

RUN git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b v7.13.5 gitlab
RUN wget https://raw.githubusercontent.com/ksoichiro/gitlab-i18n-patch/master/patches/v7.13.5/app_ja.patch -O ~/app_ja.patch
WORKDIR /var/gitlab/gitlab
RUN patch -p1 < ~/app_ja.patch && rm ~/app_ja.patch
RUN chown -R git log tmp
RUN chmod -R u+rwX log tmp public/uploads/
RUN mkdir /var/gitlab/gitlab-satellites
RUN chmod u+rwx,g=rx,o-rwx /var/gitlab/gitlab-satellites

RUN bundle install --deployment --without development test postgres aws

COPY asset/gitlab.yml /var/gitlab/gitlab/config/
COPY asset/database.yml /var/gitlab/gitlab/config/
RUN bundle exec rake gitlab:shell:install[v2.6.3] REDIS_URL=redis://172.17.42.1:6379 RAILS_ENV=production
RUN bundle exec rake assets:precompile RAILS_ENV=production

USER root

#COPY asset/rack_attack.rb /var/git/gitlab/config/initializers/
COPY asset/resque.yml /var/gitlab/gitlab/config/
COPY asset/application.rb /var/gitlab/gitlab/config/
#COPY asset/gitlab.init.d /etc/init.d/gitlab
#COPY asset/gitlab.default /etc/default/gitlab
#COPY asset/gitlab-shell-config.yml /home/git/gitlab-shell/config.yml
#
#RUN chown git.git /home/git/gitlab-shell/config.yml

COPY asset/sshd_config /etc/ssh/
COPY asset/init /root/
RUN chmod +x /root/init
RUN chown -R git.www-data /var/gitlab/gitlab
RUN chmod -R g+rw /var/gitlab/gitlab

EXPOSE 80 22

ENTRYPOINT /root/init
