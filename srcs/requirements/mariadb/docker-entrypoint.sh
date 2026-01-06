#!/bin/sh
set -e

mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /var/run/mysqld

if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then
    echo '[mariadb-entrypoint] First-time setup: initializing database...'

    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    echo '[mariadb-entrypoint] Starting temporary MariaDB...'
    mysqld_safe --datadir=/var/lib/mysql &
    pid="$!"

    echo '[mariadb-entrypoint] Waiting for MariaDB to start...'
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    echo '[mariadb-entrypoint] Configuring Database...'

    mysql -u root <<EOF
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOF

echo '[mariadb-entrypoint] Stopping temporary MariaDB...'
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

wait "$pid"
echo '[mariadb-entrypoint] Setup finished.'
fi

echo '[mariadb-entrypoint] Starting MariaDB server...'

exec mariadbd --datadir=/var/lib/mysql --bind-address=0.0.0.0
