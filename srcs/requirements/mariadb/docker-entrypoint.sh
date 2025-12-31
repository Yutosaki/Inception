#!/bin/bash

set -e

echo '[mariadb-entrypoint] First-time setup: initializing database...'
mariadb-install-db --user=mysql > /dev/null

echo '[mariadb-entrypoint] Starting temporary MariaDB...'
mariadb-safe --nowatch & sleep 5

echo '[mariadb-entrypoint] Creating database and user...'
mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo '[mariadb-entrypoint] Stopping temporary MariaDB...'
mariadb-admin shutdown

echo '[mariadb-entrypoint] Starting MariaDB server...'
exec "$@"
