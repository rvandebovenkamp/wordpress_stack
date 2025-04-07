#!/bin/bash
set -e

# Download WordPress if it's not already present
if [ ! -f "/var/www/html/wp-config.php" ]; then
  echo "Downloading WordPress core..."
  wp core download --allow-root --path=/var/www/html
  chown -R www-data:www-data /var/www/html
fi

# Start PHP-FPM and Nginx
exec /usr/bin/supervisord -n
