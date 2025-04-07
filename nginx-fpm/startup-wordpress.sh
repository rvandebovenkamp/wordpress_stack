#!/bin/bash
set -e

# Increase PHP memory just for this script
export WP_CLI_PHP_ARGS='-d memory_limit=512M'

if [ ! -f "/var/www/html/wp-config.php" ]; then
  echo "Downloading WordPress core..."
  wp core download --allow-root --path=/var/www/html
  chown -R www-data:www-data /var/www/html
fi

exec /usr/bin/supervisord -n
