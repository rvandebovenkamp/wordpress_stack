#!/bin/bash
set -e

# Show PHP memory limit for logging
echo "Memory limit (check): $(php -r 'echo ini_get(\"memory_limit\");')"

# Only download if WordPress isn't already there
if [ ! -f "/var/www/html/wp-load.php" ]; then
  echo "Downloading WordPress core with increased memory..."
  php -d memory_limit=1024M /usr/local/bin/wp core download --allow-root --path=/var/www/html
  chown -R www-data:www-data /var/www/html
else
  echo "WordPress already present, skipping download."
fi

exec /usr/bin/supervisord -n
