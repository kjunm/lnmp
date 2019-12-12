ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm
LABEL maintainer="Wim <1404397383@qq.com>"

ARG TZ


RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        libmemcached-dev \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
    && rm -r /var/lib/apt/lists/* \
    && pecl install grpc \
    && pecl install protobuf

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
        && composer config -g repo.packagist composer https://packagist.phpcomposer.com

RUN set -xe; \
    apt-get update -yqq && \
    pecl channel-update pecl.php.net && \
    apt-get install -yqq \
        apt-utils \
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
        docker-php-ext-install gd

RUN printf "\n" | pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis


# Hiredis
ARG HIREDIS_VERSION

RUN apt-get install -y  wget

RUN wget https://github.com/redis/hiredis/archive/v${HIREDIS_VERSION}.tar.gz -O hiredis.tar.gz \
    && mkdir -p hiredis \
    && tar -xf hiredis.tar.gz -C hiredis --strip-components=1 \
    && rm hiredis.tar.gz \
    && ( \
        cd hiredis \
        && make -j$(nproc) \
        && make install \
        && ldconfig \
    ) \
    && rm -r hiredis

# Swoole extension
ARG SWOOLE_VERSION
RUN wget https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -O swoole.tar.gz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
        cd swoole \
        && phpize \
        && ./configure --enable-async-redis --enable-mysqlnd --enable-openssl --enable-http2 \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r swoole \
    && docker-php-ext-enable swoole \
    && echo "swoole.use_shortname = 'Off'" >> /usr/local/etc/php/conf.d/docker-php-ext-swoole.ini

#sockets
RUN docker-php-ext-install -j$(nproc) sockets

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog


RUN usermod -u 1000 www-data


WORKDIR /var/www

CMD ["php-fpm"]

EXPOSE 9000