#!/bin/sh

: "${MYSQL_DB:?$MYSQL_DB NOT DEFINED}"
: "${MYSQL_USER:?$MYSQL_USER NOT DEFINED}"
: "${MYSQL_PWD:?$MYSQL_PWD NOT DEFINED}"
: "${MYSQL_ROOT_PWD:?$MYSQL_ROOT_PWD NOT DEFINED}"

DATA_DIR="/var/lib/mysql"

chown -R mysql:mysql "$DATA_DIR" 2>/dev/null || true
chmod 700 "$DATA_DIR" 2>/dev/null || true

# Inicializa o diretório de dados se ainda não existir
if [ ! -d "$DATA_DIR/mysql" ]; then
	mariadb-install-db --user=mysql --datadir="$DATA_DIR"
fi

# Inicia temporariamente o servidor só com socket (sem rede)
mariadbd --user=mysql --datadir="$DATA_DIR" --skip-networking &
pid=$!

sleep_time=1
until mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
	echo "⏳ A aguardar que o MariaDB inicie...	($sleep_time s)"
	sleep $sleep_time
	sleep_time=$(( sleep_time * 2 ))
	if [ $sleep_time -gt 16 ]; then sleep_time=16; fi
done

PWD=${MYSQL_PWD//\'/\'\\\'\'}
ROOT_PWD=${MYSQL_ROOT_PWD//\'/\'\\\'\'}

mariadb -h localhost --protocol=SOCKET --socket=/run/mysqld/mysqld.sock <<EOF
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DB\`;

-- Para WordPress (liga via rede Docker)
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$PWD';
GRANT ALL PRIVILEGES ON \`$MYSQL_DB\`.* TO '$MYSQL_USER'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PWD';

FLUSH PRIVILEGES;
EOF

[ -n "$pid" ] && kill -s TERM $pid
[ -n "$pid" ] && wait $pid

echo "✅ MariaDB inicializado com sucesso!"
exec mariadbd --user=mysql \
			--datadir="$DATA_DIR" \
			--bind-address=0.0.0.0 \
			--console
