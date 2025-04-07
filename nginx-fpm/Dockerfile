ARG php_version
FROM hpowernl/php:${php_version}
ARG php_version

LABEL maintainer="https://ecompower.com"
LABEL org.opencontainers.image.authors="https://ecompower.com"
LABEL org.opencontainers.image.source="https://github.com/Ecompower-nl/docker-wordpress/tree/main/nginx-fpm"
LABEL org.opencontainers.image.url="https://github.com/Ecompower-nl/docker-wordpress/tree/main/nginx-fpm"
LABEL org.opencontainers.image.title="WordPress with PHP-FPM ${php_version} and nginx"

ADD https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar /usr/local/bin/wp
ADD https://codeload.github.com/ComputeStacks/cs-wp-plugin/tar.gz/refs/heads/main /tmp/cswp.tar.gz

ADD scripts/find-wordpress.sh /usr/local/bin/find-wordpress-installation
ADD startup/ /etc/my_init.d/
ADD conf/fpm-pool.conf /etc/php/$php_version/fpm/pool.d/www.conf
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD nginx/site.conf /etc/nginx/sites-available/default
ADD nginx/multisite-subdomain.conf /etc/nginx/sites-available/multisite-subdomain.conf
ADD nginx/multisite-subdirectory.conf /etc/nginx/sites-available/multisite-subdirectory.conf

RUN mkdir -p /var/log/php
RUN mkdir -p /var/run/nginx-cache
RUN mkdir -p /var/www/logs

RUN chmod 655 /usr/local/bin/wp \
    ; \
    chmod +x /etc/my_init.d/*.sh \
        && chmod +x /usr/local/bin/wp \
        && chmod +x /usr/local/bin/find-wordpress-installation \
    ; \
    mkdir -p /usr/src/wordpress \
        && cd /usr/src/wordpress \
        && wp core download --allow-root \
        && chown -R www-data:www-data /usr/src/wordpress \
    ; \
    tar -xzvf /tmp/cswp.tar.gz --directory /opt \
        && mv /opt/cs-wp-plugin-main /opt/cs-wordpress-plugin-main \
        && rm -f /tmp/cswp.tar.gz \
        && chown -R www-data: /opt/cs-wordpress-plugin-main \
    ; \
    chown -R www-data:www-data /var/run/nginx-cache \
    && chown -R www-data:www-data /var/www/logs
