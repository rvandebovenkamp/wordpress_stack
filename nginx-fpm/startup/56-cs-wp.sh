#!/usr/bin/env bash

WP_INSTALL_PATH=$(/usr/local/bin/find-wordpress-installation)

if [ ! -f $WP_INSTALL_PATH/wp-config.php ]; then
  echo >&2 "Error: Missing wp-config.php file."
  exit 0
fi

if [ ! -d $WP_INSTALL_PATH/wp-content ]; then
  echo >&2 "Error: Missing wp-content directory"
  exit 0
fi

##
# Some like to remove all comments from the wp-config file, we need that for
# wp-cli to work properly. So we will re-add it.
##
if grep -q "/* That's all, stop editing!" $WP_INSTALL_PATH/wp-config.php; then
  echo "Anchor found in wp-config."
else
  echo "wp-cli anchor missing from wp-config, adding it back in"
  sed -i "/wp-settings.php/i\/* That's all, stop editing! Happy publishing. *\/" $WP_INSTALL_PATH/wp-config.php
fi

##
# Configure our integrations
##

echo >&2 "Setting DB Host"
sudo -u www-data wp --path=$WP_INSTALL_PATH config set DB_HOST $WORDPRESS_DB_HOST
#echo >&2 "Configuring nginx cache path"
#sudo -u www-data wp --path=$WP_INSTALL_PATH config set RT_WP_NGINX_HELPER_CACHE_PATH '/var/run/nginx-cache'

echo >&2 "Configuring Cloudpress path"
sudo -u www-data wp --path=$WP_INSTALL_PATH config CS_PLUGIN_DIR '/opt/cs-wordpress-plugin-main'

# Remove old plugin
if [ -f "$WP_INSTALL_PATH/wp-content/mu-plugins/cstacks-config.php" ]; then
  rm $WP_INSTALL_PATH/wp-content/mu-plugins/cstacks-config.php
fi

if [ -f "/opt/cs-wordpress-plugin-main/cstacks-config.php" ]; then
  echo >&2 "Updating EcomPower integration with latest version..."
  sudo -u www-data mkdir -p $WP_INSTALL_PATH/wp-content/mu-plugins
  sudo -u www-data cp /opt/cs-wordpress-plugin-main/cstacks-config.php $WP_INSTALL_PATH/wp-content/mu-plugins/
fi

echo >&2 "Configuring wordpress cron jobs..."
sudo -u www-data wp --path=$WP_INSTALL_PATH config set DISABLE_WP_CRON true

if [ -f /var/www/crontab ]; then
  if grep -Fq 'wp-cron' /var/www/crontab; then
    echo >&2 "wordpress user-cron configured, skipping..."
  else
    cat << EOF >> '/var/www/crontab'

*/5 * * * * www-data /usr/bin/curl http://localhost/wp-cron.php?doing_wp_cron
EOF
  fi
fi
if [ -f /etc/cron.d/myapp ]; then
  if grep -Fq 'wp-cron' /etc/cron.d/myapp; then
    echo >&2 "wordpress system-cron configured, skipping..."
  else
    cat << EOF >> '/etc/cron.d/myapp'

*/5 * * * * www-data /usr/bin/curl http://localhost/wp-cron.php?doing_wp_cron
EOF
  fi
else
  cat << EOF >> '/etc/cron.d/myapp'

*/5 * * * * www-data /usr/bin/curl http://localhost/wp-cron.php?doing_wp_cron
EOF
fi
