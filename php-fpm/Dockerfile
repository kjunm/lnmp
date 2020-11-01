ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm
LABEL maintainer="Wim <1404397383@qq.com>"

ARG TZ
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb https://mirrors.aliyun.com/debian  stable main contrib non-free" >/etc/apt/sources.list && \
    echo "deb https://mirrors.aliyun.com/debian  stable-updates main contrib non-free" >>/etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-utils \
        curl \
        libmemcached-dev \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev

RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    apt-get install -yqq \
        libzip-dev zip unzip && \
        docker-php-ext-configure zip --with-libzip && \
        docker-php-ext-install zip && \
        docker-php-ext-install bcmath && \
        docker-php-ext-install opcache && \
        docker-php-ext-install mysqli && \
        docker-php-ext-install pdo_mysql &&\
        docker-php-ext-install json &&\
        docker-php-ext-configure gd \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
        docker-php-ext-install gd && \
        pecl install igbinary && \
        docker-php-ext-enable igbinary

RUN printf "\n" | pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

#sockets
RUN docker-php-ext-install -j$(nproc) sockets

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
        && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug
    
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

USER root

# Clean up
RUN apt-get clean && \
    rm -r /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog


RUN usermod -u 1000 www-data


WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000