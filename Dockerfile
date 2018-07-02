FROM php:7.0.30-fpm-alpine

###### Install packages
RUN apk --no-cache add g++ gcc make autoconf curl curl-dev bzip2 bzip2-dev zip icu icu-libs icu-dev \
    libmemcached libmemcached-dev zlib-dev cyrus-sasl-dev mysql-client nginx supervisor tzdata bash \
    libpng-dev freetype-dev libjpeg-turbo-dev libmcrypt-dev libpng libpng-dev gettext  gettext-dev  \
    libmcrypt libmcrypt-dev libxml2 libxml2-dev libxslt libxslt-dev 

##### Install memcached and redis packages
RUN echo no | pecl install redis && \
    echo yes | pecl install memcached && \
    docker-php-ext-enable redis memcached

##### Install php extension packages
RUN docker-php-ext-install gd bz2 intl bcmath calendar exif gd gettext intl mcrypt mysqli pcntl pdo_mysql soap sockets wddx xsl opcache zip gettext intl mcrypt mysqli pcntl pdo_mysql soap sockets wddx xsl zip 

###### set up timezone
RUN rm /etc/localtime && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

##install composer
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

###### change php.ini ######
ADD ./php.ini /usr/local/etc/php/
RUN sed -i -e "s/listen = 9000//g" /usr/local/etc/php-fpm.d/zz-docker.conf
ADD ./www.conf /usr/local/etc/php-fpm.d/www.conf

#Update nginx config
ADD ./nginx.conf /etc/nginx/
ADD ./magento.conf /etc/nginx/site-enabled/
RUN mkdir /etc/nginx/ssl 

###### supervisord ######
ADD ./supervisord.conf /etc/supervisord.conf
RUN mkdir -p /etc/supervisor/conf.d

###### startup prepare ######
VOLUME ["/var/www/html", "/etc/nignx/site-enabled", "/usr/local/etc"]

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]

EXPOSE 80
WORKDIR /var/www/html

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
