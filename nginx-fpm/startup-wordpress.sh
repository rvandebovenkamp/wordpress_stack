#!/bin/bash
set -e

# Enforce high memory limit for WP-CLI
export WP_CLI_PHP_ARGS='-d memory_limit=2048M'

# Debug: show PHP version and memory limit for logging
php -r 'echo "Memory limit: " . ini_get("memory_limit") . PHP_EOL;'

if [ ! -f "/var/www/html/wp-config.php" ]; then
  echo "Downloading WordPress core..."
  wp core download --allow-root --path=/var/www/html
  chown -R www-data:www-data /var/www/html
fi

exec /usr/bin/supervisord -n
