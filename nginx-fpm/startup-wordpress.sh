#!/bin/bash
set -e

# Force memory limit override manually using PHP CLI
echo "Memory limit (check): $(php -r 'echo ini_get("memory_limit");')"

if [ ! -f "/var/www/html/wp-config.php" ]; then
  echo "Downloading WordPress core with increased memory..."
  php -d memory_limit=1024M /usr/local/bin/wp core download --allow-root --path=/var/www/html
  chown -R www-data:www-data /var/www/html
fi

exec /usr/bin/supervisord -n
