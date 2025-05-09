FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    git \
    rsync \
    unzip \
    --no-install-recommends

# Install PHP extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && sync \
    && install-php-extensions \
    apcu \
    bcmath \
    gd \
    gmp \
    exif \
    imagick \
    intl \
    memcached \
    mysqli \
    opcache \
    pcntl \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    redis \
    sockets \
    sysvsem \
    xdebug \
    zip \
    && rm /usr/local/bin/install-php-extensions \
    # make possible ImageMagic handle PDF files
    && sed -i'' 's|.*<policy domain="coder".*"PDF".*|<policy domain="coder" rights="read \| write" pattern="PDF" />|g' /etc/ImageMagick-6/policy.xml \
    # pevent errors when try to create files at /var/www with user www-data
    && chown -R www-data /var/www

COPY --from=composer /usr/bin/composer /usr/bin/composer

# Install NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash \
    && export NVM_DIR="/root/.nvm" \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install 20 \
    && nvm alias default 20

COPY .docker/php/config/php.ini /usr/local/etc/php/conf.d/

WORKDIR /var/www/html
COPY .docker/php/wait-for-db.php /usr/local/bin/wait-for-db.php
COPY .docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]
