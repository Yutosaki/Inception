#!/bin/sh
set -eu

cd /var/www/html

if [ ! -e wp-includes/version.php ]; then
  echo "[entrypoint] Downloading WordPress..."
  wp core download --locale=ja --allow-root
  chown -R www-data:www-data /var/www/html
fi


echo "[entrypoint] Waiting for MariaDB..."
until mysqladmin ping \
  --protocol=TCP \
  -h "$WP_DB_HOST" \
  -u "$WP_DB_USER" \
  -p"$WP_DB_PASSWORD" \
  --silent; do
  sleep 1
done


if [ ! -f wp-config.php ]; then
  echo "[entrypoint] Creating wp-config.php..."
  wp config create \
    --dbname="$WP_DB_NAME" \
    --dbuser="$WP_DB_USER" \
    --dbpass="$WP_DB_PASSWORD" \
    --dbhost="$WP_DB_HOST" \
    --allow-root
fi

if ! wp core is-installed --allow-root; then
  echo "[entrypoint] Installing WordPress and creating admin user..."
  wp core install \
    --url="https://yutsasak.42.fr" \
    --title="Inception WordPress" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root
fi

if ! wp user get $WP_SECOND_USER --allow-root >/dev/null 2>&1; then
  echo "[entrypoint] Creating second WordPress user..."

  wp user create $WP_SECOND_USER $WP_SECOND_EMAIL \
    --role=subscriber \
    --user_pass="$WP_SECOND_PASSWORD" \
    --allow-root
fi

exec "$@"
