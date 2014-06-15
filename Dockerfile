FROM ubuntu:12.04
MAINTAINER talkingquickly.co.uk <ben@talkingquickly.co.uk>

ENV DEBIAN_FRONTEND noninteractive

#
# Apt
#
RUN apt-get -y update
RUN apt-get install -y -q python-software-properties
RUN \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java7-installer
RUN apt-get install -y -q \
  build-essential \
  openssl \
  libreadline6 \
  libreadline6-dev \
  curl \
  git-core \
  zlib1g \
  zlib1g-dev \
  libssl-dev \
  libyaml-dev \
  libsqlite3-dev \
  sqlite3 \
  libxml2-dev \
  libxslt-dev \
  autoconf \
  libc6-dev \
  ncurses-dev \
  automake \
  libtool \
  bison \
  subversion \
  pkg-config \
  libmysqlclient-dev \
  libpq-dev \
  make \
  wget \
  unzip \
  git \
  vim \
  nano \
  nodejs \
  mysql-client \
  postgresql-client \
  gawk \
  libgdbm-dev \
  libffi-dev

#
# OS Configuration 
#
RUN adduser --gecos "" --disabled-password --ingroup users dobby
RUN mkdir -p /app/rearview
ADD . /app/rearview
RUN cp /app/rearview/docker/rearview/database.yml /app/rearview/config
RUN chown -R dobby.users /app/rearview

#
# Ruby
#
# TODO: test doing this instead of using su
# USER dobby
# ENV HOME /home/dobby
RUN su dobby -c "git clone https://github.com/sstephenson/rbenv.git ~/.rbenv"
RUN su dobby -c "echo 'export PATH="\$HOME/.rbenv/bin:\$PATH"' >> ~/.bashrc"
RUN su dobby -c "echo -e 'eval \"\$(rbenv init -)\"' >> ~/.bashrc" 
RUN su dobby -c "git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build"
RUN su - dobby -c "cd /app/rearview && /app/rearview/docker/rearview/rbenv-exec rbenv install 1.9.3-p547"
RUN su - dobby -c "cd /app/rearview && /app/rearview/docker/rearview/rbenv-exec rbenv install jruby-1.7.5"

#
# Rearview
#
# TODO: use setup script
# RUN su - dobby -c "/app/rearview/docker/rearview/rbenv-exec bin/setup"
WORKDIR /app/rearview
RUN su - dobby -c "/app/rearview/docker/rearview/rbenv-exec gem install bundler"
RUN su - dobby -c "/app/rearview/docker/rearview/rbenv-exec bundle install"
RUN su - dobby -c "/app/rearview/docker/rearview/rbenv-exec bundle exec rake rearview:setup"
RUN cp /app/rearview/docker/rearview/rearview.rb /app/rearview/config/initializers

# ENV RAILS_ENV production
# ENV HOME /home/dobby
# USER dobby
# WORKDIR /app/rearview
# EXPOSE 3000
# CMD ["/app/rearview/docker/rearview/start-server.sh"]

