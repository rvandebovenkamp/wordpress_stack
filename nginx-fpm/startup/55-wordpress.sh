#!/usr/bin/env bash

mkdir -p /var/www/html/wordpress && chown www-data:www-data /var/www/html/wordpress
cd /var/www/html/wordpress

# re-seed volume with up to date examples
if [ -f /opt/nginx/multisite-subdirectory.conf ]; then
  cp /opt/nginx/multisite-subdirectory.conf /var/www/nginx/multisite-subdirectory.conf.example
fi
if [ -f /opt/nginx/multisite-subdomain.conf ]; then
  cp /opt/nginx/multisite-subdomain.conf /var/www/nginx/multisite-subdomain.conf.example
fi

chown -R www-data:www-data /var/www/nginx

wait_for_db() {
  counter=0
  echo >&2 "Connecting to database at $WORDPRESS_DB_HOST"
  while ! mysql -h $WORDPRESS_DB_HOST -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD -e "USE mysql;" >/dev/null; do
    counter=$((counter+1))
    if [ $counter == 30 ]; then
      echo >&2 "Error: Couldn't connect to database."
      exit 1
    fi
    echo >&2 "Trying to connect to database at $WORDPRESS_DB_HOST. Attempt $counter..."
    sleep 5
  done
}

setup_db() {
  echo >&2 "Creating the database..."
  mysql -h $WORDPRESS_DB_HOST -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD --skip-column-names -e "CREATE DATABASE IF NOT EXISTS $WORDPRESS_DB_NAME;"
}

install_plugin() {
  echo >&2 "Installing $1..."
  sudo -u www-data wp plugin install $1 --activate && echo "Plugin $1 installed and activated succesfully!" || "Installing $1 failed; check if plugin name is correctly specified"
}

if ! [ "$(ls -A)" ]; then
  echo >&2 "No files found in $PWD - installing wordpress..."
  
  # Create DB
  wait_for_db
  setup_db

  mv /usr/src/wordpress/* .
  sudo -u www-data wp config create --dbhost=$WORDPRESS_DB_HOST --dbname=$WORDPRESS_DB_NAME --dbuser=$WORDPRESS_DB_USER --dbpass=$WORDPRESS_DB_PASSWORD --extra-php << 'PHP'
// If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact
// see also http://codex.wordpress.org/Administration_Over_SSL#Using_a_Reverse_Proxy
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
  $_SERVER['HTTPS'] = 'on';
}
PHP

  echo >&2 "Installing WordPress..."
  sudo -u www-data wp core install --url=$WORDPRESS_URL --title="$WORDPRESS_TITLE" --admin_user=$WORDPRESS_USER --admin_password=$WORDPRESS_PASSWORD --admin_email="$WORDPRESS_EMAIL" --skip-email

  sudo -u www-data wp config set WP_AUTO_UPDATE_CORE 'minor'
  sudo -u www-data wp config set FS_METHOD 'direct'
  sudo -u www-data wp config set WP_MEMORY_LIMIT '512M'
  sudo -u www-data wp config set CS_PLUGIN_DIR '/opt/cs-wordpress-plugin-main'

  echo >&2 "Uninstall default plugins"
  sudo -u www-data wp plugin is-installed akismet && sudo -u www-data wp plugin uninstall akismet
  sudo -u www-data wp plugin is-installed hello && sudo -u www-data wp plugin uninstall hello

  #echo >&2 "Configuring nginx helper"
  #sudo -u www-data wp config set RT_WP_NGINX_HELPER_CACHE_PATH '/var/run/nginx-cache'
  #sudo -u www-data wp option add rt_wp_nginx_helper_options --format=json '{"enable_purge":"1","cache_method":"enable_fastcgi","unlink_files":"unlink_files","enable_map":null,"enable_log":null,"log_level":"INFO","log_filesize":"5","enable_stamp":null,"purge_homepage_on_edit":"1","purge_homepage_on_del":"1","purge_archive_on_edit":null,"purge_archive_on_del":null,"purge_archive_on_new_comment":null,"purge_archive_on_deleted_comment":null,"purge_page_on_mod":"1","purge_page_on_new_comment":"1","purge_page_on_deleted_comment":"1","redis_hostname":"127.0.0.1","redis_port":"6379","redis_prefix":"nginx-cache:","purge_url":"","redis_enabled_by_constant":0,"smart_http_expire_form_nonce":"2923f3260e"}' --skip-plugins --skip-themes
  #sudo -u www-data wp plugin install nginx-helper --activate --skip-plugins --skip-themes

  if [[ -z "$WORDPRESS_PLUGINLIST" ]]; then
    echo "Pluginlist-variable empty, skipping plugin installation."
  else
    IFS=',' read -r -a array <<< "$WORDPRESS_PLUGINLIST"
    for i in "${array[@]}"
    do
      install_plugin $i
    done
  fi

  # check if timezone-variable exists, else default to UTC
  if [[ -z "$WORDPRESS_TIMEZONE" ]]; then
    echo "Timezone not specified: defaulting to UTC"
  else
    echo >&2 "Setting timezone to $WORDPRESS_TIMEZONE..."
    sudo -u www-data wp option update timezone_string $WORDPRESS_TIMEZONE
  fi

  # check if timezone-variable exists, else default to English
  if [[ -z "$WORDPRESS_LANGUAGE" ]]; then
    echo "Language not specified: defaulting to English"
  else
    echo >&2 "Setting language to $WORDPRESS_LANGUAGE"
    sudo -u www-data wp language core install $WORDPRESS_LANGUAGE
    sudo -u www-data wp language core activate $WORDPRESS_LANGUAGE
  fi

fi
