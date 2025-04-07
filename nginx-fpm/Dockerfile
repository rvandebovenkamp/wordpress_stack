FROM php:8.3-fpm-alpine

FROM php:8.3-fpm-alpine

# Install essential packages and PHP extensions
RUN apk update && apk add --no-cache \
    nginx \
    bash \
    curl \
    tar \
    gzip \
    supervisor \
    mysql-client \
    coreutils \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql zip opcache


ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp

ADD https://codeload.github.com/ComputeStacks/cs-wp-plugin/tar.gz/refs/heads/main /tmp/cswp.tar.gz

ADD scripts/find-wordpress.sh /usr/local/bin/find-wordpress-installation
ADD startup/ /etc/my_init.d/
ADD conf/fpm-pool.conf /usr/local/etc/php-fpm.d/www.conf
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD nginx/site.conf /etc/nginx/http.d/default.conf
ADD nginx/multisite-subdomain.conf /etc/nginx/http.d/multisite-subdomain.conf
ADD nginx/multisite-subdirectory.conf /etc/nginx/http.d/multisite-subdirectory.conf

RUN mkdir -p /var/log/php \
    && mkdir -p /var/run/nginx-cache \
    && mkdir -p /var/www/logs

RUN chmod +x /usr/local/bin/wp \
    && chmod +x /etc/my_init.d/*.sh \
    && chmod +x /usr/local/bin/find-wordpress-installation \
    && mkdir -p /usr/src/wordpress \
    && cd /usr/src/wordpress \
    && wp core download --allow-root \
    && chown -R www-data:www-data /usr/src/wordpress \
    && tar -xzvf /tmp/cswp.tar.gz --directory /opt \
    && mv /opt/cs-wp-plugin-main /opt/cs-wordpress-plugin-main \
    && rm -f /tmp/cswp.tar.gz \
    && chown -R www-data:www-data /opt/cs-wordpress-plugin-main \
    && chown -R www-data:www-data /var/run/nginx-cache \
    && chown -R www-data:www-data /var/www/logs
