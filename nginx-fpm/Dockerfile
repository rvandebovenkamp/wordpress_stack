FROM php:8.4-fpm

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx supervisor curl unzip default-mysql-client \
    libpng-dev libjpeg-dev libwebp-dev libfreetype6-dev libzip-dev libonig-dev build-essential \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd mysqli pdo_mysql zip opcache \
    && apt-get purge -y build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy configurations and scripts
COPY conf/fpm-pool.conf /usr/local/etc/php-fpm.d/www.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/site.conf /etc/nginx/sites-available/default
COPY scripts/find-wordpress.sh /usr/local/bin/find-wordpress-installation
COPY startup/ /etc/my_init.d/

# Enable Nginx site
RUN mkdir -p /etc/nginx/sites-enabled \
    && ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Set up directories
RUN mkdir -p /var/log/php \
    && mkdir -p /var/run/nginx-cache \
    && mkdir -p /var/www/logs \
    && chown -R www-data:www-data /var/www/logs /var/run/nginx-cache

# Set permissions
RUN chmod +x /usr/local/bin/find-wordpress-installation \
    && chmod +x /etc/my_init.d/*.sh

# Supervisor configuration
RUN mkdir -p /var/log/supervisor
RUN echo "[supervisord]\nnodaemon=true\n\n[program:php-fpm]\ncommand=/usr/local/sbin/php-fpm --nodaemonize\n\n[program:nginx]\ncommand=/usr/sbin/nginx -g 'daemon off;'" \
    > /etc/supervisor/conf.d/supervisord.conf

# WordPress setup at startup (ensures wp-cli runs when container is up)
COPY startup-wordpress.sh /usr/local/bin/startup-wordpress.sh
RUN chmod +x /usr/local/bin/startup-wordpress.sh

CMD ["/usr/local/bin/startup-wordpress.sh"]
