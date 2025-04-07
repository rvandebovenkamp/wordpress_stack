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

# Install WP-CLI correctly
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Add ComputeStacks WordPress plugin
ADD https://codeload.github.com/ComputeStacks/cs-wp-plugin/tar.gz/refs/heads/main /tmp/cswp.tar.gz

# Copy scripts and configurations
ADD scripts/find-wordpress.sh /usr/local/bin/find-wordpress-installation
ADD startup/ /etc/my_init.d/
ADD conf/fpm-pool.conf /usr/local/etc/php-fpm.d/www.conf
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD nginx/site.conf /etc/nginx/http.d/default.conf
ADD nginx/multisite-subdomain.conf /etc/nginx/http.d/multisite-subdomain.conf
ADD nginx/multisite-subdirectory.conf /etc/nginx/http.d/multisite-subdirectory.conf

# Set up required directories
RUN mkdir -p /var/log/php \
    && mkdir -p /var/run/nginx-cache \
    && mkdir -p /var/www/logs

# Set permissions and setup WordPress
RUN chmod +x /usr/local/bin/find-wordpress-installation \
    && chmod +x /etc/my_init.d/*.sh \
    && mkdir -p /usr/src/wordpress \
    && wp core download --allow-root --path=/usr/src/wordpress \
    && chown -R www-data:www-data /usr/src/wordpress \
    && tar -xzvf /tmp/cswp.tar.gz -C /opt \
    && mv /opt/cs-wp-plugin-main /opt/cs-wordpress-plugin-main \
    && rm -f /tmp/cswp.tar.gz \
    && chown -R www-data:www-data /opt/cs-wordpress-plugin-main \
    && chown -R www-data:www-data /var/run/nginx-cache \
    && chown -R www-data:www-data /var/www/logs

# Supervisor (if required)
CMD ["/usr/bin/supervisord", "-n"]
