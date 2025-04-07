#!/usr/bin/env bash

WP_BASE_DIR=/var/www/html/wordpress

# standard installations
if [ -f /var/www/html/wordpress/wp-config.php ]; then
  echo $WP_BASE_DIR
  exit 0
fi

if [ ! -d "$WP_BASE_DIR" ]; then
  echo ""
  exit 0
fi

wp_path=$(find "$WP_BASE_DIR" -name "wp-config.php")

if [[ $wp_path && $wp_path != "" ]]; then
  echo $wp_path | sed 's|/wp-config.php$||'
else
  echo ""
fi
