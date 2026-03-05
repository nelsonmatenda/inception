#!/bin/sh
set -e

secrets() {
	cat "/run/secrets/$1"
}

MYSQL_PWD=$(secrets db_user_pwd)
MYSQL_ROOT_PWD=$(secrets db_root_pwd)

: "${MYSQL_DB:?$MYSQL_DB NOT DEFINED}"
: "${MYSQL_USER:?$MYSQL_USER NOT DEFINED}"
: "${MYSQL_PWD:?$MYSQL_PWD NOT DEFINED}"
: "${MYSQL_ROOT_PWD:?$MYSQL_ROOT_PWD NOT DEFINED}"

DATA_DIR="/var/lib/mysql"

chown -R mysql:mysql "$DATA_DIR"

PWD=${MYSQL_PWD//\'/\'\\\'\'}
ROOT_PWD=${MYSQL_ROOT_PWD//\'/\'\\\'\'}

cat << EOF > "/tmp/init.sql"
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DB\`;

CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$PWD';
GRANT ALL PRIVILEGES ON \`$MYSQL_DB\`.* TO '$MYSQL_USER'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PWD';

FLUSH PRIVILEGES;
EOF
# Inicializa o diretório de dados se ainda não existir
if [ ! -d "$DATA_DIR/mysql" ]; then
	mariadb-install-db --user=mysql --datadir="$DATA_DIR" --skip-test-db

	/usr/bin/mysqld --console --user=mysql --bootstrap < /tmp/init.sql || exit 1
	rm -f /tmp/init.sql

fi

echo " ✅ MARIADB"
exec mariadbd --user=mysql \
			--datadir="$DATA_DIR" \
			--bind-address=0.0.0.0 \
			--console
