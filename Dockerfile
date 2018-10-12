FROM ubuntu:16.04
MAINTAINER Viet Duong<viet.duong@hotmail.com>

# Compatible with :
#    Ubuntu 16.04
#    Nginx 1.15.x

# Set one or more individual labels
LABEL vietcli.docker.base.image.version="0.1.0-beta"
LABEL vendor="[VietCLI] vietcli/docker-routing"
LABEL vietcli.docker.base.image.release-date="2018-09-18"
LABEL vietcli.docker.base.image.version.is-production=""

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
RUN mkdir /var/run/sshd
RUN mkdir /run/php

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Custom Environment Variables
ENV HTTP_SERVER_NAME vietcli.local

# Update apt-get
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62 \
    && echo 'deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx' >> /etc/apt/sources.list.d/nginx.list \
    && apt-get update \
    && apt-get install locales \
    && locale-gen en_US.UTF-8 \
    && export LANG=en_US.UTF-8 \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get -y upgrade

# Basic Requirements
RUN apt-get update
RUN apt-get -y install pwgen python-setuptools curl git nano sudo unzip openssh-server openssl
RUN apt-get -y install nginx

# nginx config
RUN sed -i -e"s/user\s*www-data;/user vietcli www-data;/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf

# Generate self-signed ssl cert
RUN mkdir /etc/nginx/ssl/
RUN openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=localhost" \
    -keyout /etc/ssl/private/ssl-cert-snakeoil.key \
    -out /etc/ssl/certs/ssl-cert-snakeoil.pem

# nginx site conf
# ADD ./nginx.default.conf /etc/nginx/conf.d/default.conf

# Add system user for Magento
RUN useradd -m -d /home/vietcli -p $(openssl passwd -1 'vietcli') -G root -s /bin/bash vietcli \
    && usermod -a -G www-data vietcli \
    && usermod -a -G sudo vietcli \
    && mkdir -p /home/vietcli/files/html \
    && chown -R vietcli:www-data /home/vietcli/files \
    && chmod -R 775 /home/vietcli/files

# Magento Initialization and Startup Script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

#NETWORK PORTS
# private expose
EXPOSE 443
EXPOSE 80
EXPOSE 22

# volume for mysql database and magento install
VOLUME ["/home/vietcli/files", "/home/vietcli/.log", "/var/run/sshd"]

CMD ["/bin/bash", "/start.sh"]