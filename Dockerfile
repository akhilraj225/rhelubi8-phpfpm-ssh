FROM registry.access.redhat.com/ubi8/ubi:8.1


#Enable epel repositry
RUN dnf -y --disableplugin=subscription-manager install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm 

#Installing packages
RUN dnf --disableplugin=subscription-manager -y module enable php:7.4 \
  && dnf --disableplugin=subscription-manager -y install httpd openssh-server \
  && dnf --disableplugin=subscription-manager -y install php php-pear php-devel \
                  php-gd php-intl php-json php-ldap php-mbstring php-pdo \
                  php-process php-soap php-opcache php-xml \
                  php-gmp php-pecl-apcu php-pecl-zip hostname \
                  nano zip unzip php-fpm php-bcmath php-exif
RUN dnf --disableplugin=subscription-manager clean all

ADD Docker/index.php /var/www/html

#SSH configuration
COPY Docker/sshd_config /etc/ssh/
RUN ssh-keygen -A \
  && echo "root:Docker!" | chpasswd 

#php-fpm configuration
RUN mkdir /run/php-fpm
RUN sed -E -i -e 's/;listen.owner = nobody/listen.owner = apache/g' /etc/php-fpm.d/www.conf \
  && sed -E -i -e 's/;listen.group = nobody/listen.group = apache/g' /etc/php-fpm.d/www.conf \
  && sed -E -i -e 's/listen.acl_users = (.*)$/;listen.acl_users = \1/g' /etc/php-fpm.d/www.conf 

EXPOSE 80 2222
CMD /usr/sbin/php-fpm & /usr/sbin/sshd & httpd -D FOREGROUND
