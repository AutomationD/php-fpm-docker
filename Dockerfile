################################################################################
# Base image
################################################################################

FROM kireevco/openresty:1.11.33.4-1.0.2j-1.11.33.4
MAINTAINER Dmitry Kireev <dmitry@kireev.co>

ENV \
  DEBIAN_FRONTEND=noninteractive \
  TERM=xterm-color

# Install base utils
RUN apt-get update && apt-get install -my \
  wget \
  curl

# Use actual mirror instead of using httpredir which could break
RUN sed -i "s/httpredir.debian.org/`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`/" /etc/apt/sources.list

# Remove default nginx configs.
RUN rm -f /etc/nginx/conf.d/*

# Install HHVM Repo
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
RUN echo deb http://dl.hhvm.com/debian jessie main | tee /etc/apt/sources.list.d/hhvm.list

# Install NewRelic Repo
RUN wget -O - https://download.newrelic.com/548C16BF.gpg | apt-key add -
RUN echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list

# Install packages
RUN apt-get clean && apt-get update && apt-get install -my \
  supervisor \
  python python-pip python-dev \
  curl \
  wget \
  php5-curl \
  php5-fpm \
  php5-gd \
  php5-memcache \
  php5-memcached \
  php5-mysql \
  php5-mcrypt \
  php5-sqlite \
  php5-xdebug \
  hhvm \
  php-apc \  
  openjdk-7-jre \
  yui-compressor \
  tidy \
  newrelic-php5 \
  htop vim strace dstat mc mysql-client


# Install j2cli (will help us with config templating)
RUN pip install j2cli && pip install j2cli[yaml]

## Ensure that PHP5 FPM is run as root.
#RUN sed -i "s/user = www-data/user = root/" /etc/php5/fpm/pool.d/www.conf
#RUN sed -i "s/group = www-data/group = root/" /etc/php5/fpm/pool.d/www.conf
#
## Pass all docker environment
#RUN sed -i '/^;clear_env = no/s/^;//' /etc/php5/fpm/pool.d/www.conf
#
## Get access to FPM-ping page /ping
#RUN sed -i '/^;ping\.path/s/^;//' /etc/php5/fpm/pool.d/www.conf
## Get access to FPM_Status page /status
#RUN sed -i '/^;pm\.status_path/s/^;//' /etc/php5/fpm/pool.d/www.conf#
#
## Set php memory
#RUN sed -i '/^;php_admin_value[memory_limit] = 32M/php_admin_value[memory_limit] = 512M/' /etc/php5/fpm/pool.d/www.conf



# Prevent PHP Warning: 'xdebug' already loaded.
# XDebug loaded with the core
RUN sed -i '/.*xdebug.so$/s/^/;/' /etc/php5/mods-available/xdebug.ini
