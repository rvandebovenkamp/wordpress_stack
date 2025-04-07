#!/bin/bash
set -e

echo "Memory limit (check): $(php -r 'echo ini_get("memory_limit") . PHP_EOL;')"

# Only download WordPress if it's not already installed
if [ ! -f "/var/www/html/wp-load.php" ]; then
  echo "Downloading WordPress core with increased memory..."
  php -d memory_limit=1024M /usr/local/bin/wp core download --allow-root --path=/var/www/html
  chown -R www-data:www-data /var/www/html
else
  echo "WordPress already present, skipping download."
fi

# Test php-fpm config before starting
echo "Testing PHP-FPM config..."
php-fpm -tt || { echo "❌ php-fpm config invalid"; exit 78; }

# Start everything
exec /usr/bin/supervisord -n
