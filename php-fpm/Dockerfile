ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm
LABEL maintainer="Wim <1404397383@qq.com>"

ARG TZ
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

#更新apt-get源 使用163的源
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

RUN apt-get install -y  wget

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

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer \
    && composer self-update --1 \ 
    && composer global require "fxp/composer-asset-plugin:^1.4.1"

#xdebug
ARG XDEBUG_VERSION
RUN pecl install xdebug-${XDEBUG_VERSION} \
    && docker-php-ext-enable xdebug

#mongo
RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

#git
RUN apt-get install -y git

#memcached
RUN pecl install memcached \
    && docker-php-ext-enable memcached 

#protobuf
RUN pecl install protobuf \
    && docker-php-ext-enable protobuf

#grpc
RUN pecl install grpc \
    && docker-php-ext-enable grpc

USER root

# Clean up
RUN apt-get clean && \
    rm -r /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog


RUN usermod -u 1000 www-data


WORKDIR /var/www

COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN chmod +x /bin/docker-entrypoint.sh
ENTRYPOINT ["/bin/docker-entrypoint.sh"]

CMD ["php-fpm"]

EXPOSE 9000