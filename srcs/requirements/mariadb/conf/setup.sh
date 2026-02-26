#! /bin/bash

: "${MYSQL_DB:?$MYSQL_DB NOT DEFINED}"
: "${MYSQL_USER:?$MYSQL_USER NOT DEFINED}"
: "${MYSQL_PWD:?$MYSQL_PWD NOT DEFINED}"

DATA_DIR="/var/lib/mysql"
if [ ! -d "$DATA_DIR/mysql" ]; then
	mysqld --initialize --user=mysql --datadir="$DATA_DIR"
fi

# roda o mariadb para criação da DB e user
mysqld --user=mysql --datadir="$DATA_DIR" --skip-networking --socket=/tmp/mysql.sock &
pid=$!

sleep_time=1
until mysqladmin --socket=/tmp/mysql.sock ping >/dev/null 2>&1; do
	echo "Inicializando MariaDB..."
	sleep $sleep_time
	((sleep_time*=2)) # vai multiplicar o tempo de espera
	if [ $sleep_time -gt 16 ]; then sleep_time=16; fi
done

PWD=${MYSQL_PWD//\'/\'\\\'\'}
mysql --socket=/tmp/mysql.sock <<EOF
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DB\`;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$PWD';
GRANT ALL PRIVILEGES ON \`$MYSQL_DB\`.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

[ -n "$pid" ] && kill -s TERM $pid
[ -n "$pid" ] && wait $pid

exec mysqld --user=mysql --datadir="$DATA_DIR" --bind-address=0.0.0.0
