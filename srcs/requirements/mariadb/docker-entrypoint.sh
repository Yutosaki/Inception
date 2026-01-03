#!/bin/bash

set -e

echo '[mariadb-entrypoint] First-time setup: initializing database...'
mysql_install_db --user=mysql > /dev/null

echo '[mariadb-entrypoint] Starting temporary MariaDB...'
mysqld_safe --nowatch & sleep 5

echo '[mariadb-entrypoint] Creating database and user...'
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo '[mariadb-entrypoint] Stopping temporary MariaDB...'
mysqladmin shutdown

echo '[mariadb-entrypoint] Starting MariaDB server...'
exec "$@"
