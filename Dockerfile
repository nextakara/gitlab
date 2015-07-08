FROM debian:8.1

MAINTAINER takara

WORKDIR /root/

RUN apt-get update && apt-get -y upgrade

RUN apt-get -y install vim gcc make wget tar
RUN apt-get install -y build-essential zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libncurses5-dev libffi-dev curl openssh-server redis-server checkinstall libxml2-dev libxslt-dev libcurl4-openssl-dev libicu-dev logrotate python-docutils pkg-config cmake nodejs
RUN apt-get install -y mysql-client libmysqlclient-dev libkrb5-dev git
RUN apt-get install -y expect
RUN apt-get install -y daemon chkconfig
RUN apt-get install -y nginx

# ruby
RUN apt-get -y install ruby2.1 ruby2.1-dev rubygems 
RUN gem install bundler

COPY asset/gitlab.init.d /etc/init.d/gitlab
COPY asset/gitlab.default /etc/default/gitlab

COPY asset/gitlab /etc/nginx/sites-available/gitlab
RUN ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab

COPY asset/postfix-install /root/
RUN /usr/bin/expect /root/postfix-install

RUN useradd -m -s /bin/bash -c 'GitLab' git

USER git
WORKDIR /home/git/

RUN git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 7-9-stable gitlab
RUN wget https://raw.githubusercontent.com/ksoichiro/gitlab-i18n-patch/master/patches/v7.9.4/app_ja.patch
WORKDIR /home/git/gitlab
RUN patch -p1 < ../app_ja.patch
RUN chown -R git log tmp
RUN chmod -R u+rwX log tmp public/uploads/
RUN mkdir /home/git/gitlab-satellites
RUN chmod u+rwx,g=rx,o-rwx /home/git/gitlab-satellites

RUN bundle install --deployment --without development test postgres aws

COPY asset/gitlab.yml /home/git/gitlab/config/
COPY asset/unicorn.rb /home/git/gitlab/config/
COPY asset/rack_attack.rb /home/git/gitlab/config/initializers/
COPY asset/resque.yml /home/git/gitlab/config/
COPY asset/database.yml /home/git/gitlab/config/
COPY asset/application.rb /home/git/gitlab/config/

RUN bundle exec rake gitlab:shell:install[v2.4.0] REDIS_URL=unix:/var/run/redis/redis.sock RAILS_ENV=production
RUN bundle exec rake assets:precompile RAILS_ENV=production

EXPOSE 223 80

ENTRYPOINT /root/init

USER root

#COPY asset/settimezone /root/
#RUN /usr/bin/expect /root/settimezone

COPY asset/sshd_config /etc/ssh/
COPY asset/init /root/
RUN chmod +x /root/init
