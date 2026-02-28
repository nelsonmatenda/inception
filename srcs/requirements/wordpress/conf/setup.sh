#! /bin/sh
set -e

secrets() {
	cat "/run/secrets/$1"
}

MYSQL_PWD=$(secrets db_user_pwd)
WP_ADM_PASS=$(secrets wp_adm_pwd)
WP_USER_PASS=$(secrets wp_user_pwd)

: "${MYSQL_DB:?$MYSQL_DB NOT DEFINED}"
: "${MYSQL_USER:?$MYSQL_USER NOT DEFINED}"
: "${MYSQL_PWD:?$MYSQL_PWD NOT DEFINED}"
: "${MYSQL_HOST:?$MYSQL_HOST NOT DEFINED}"
: "${DOMAIN_NAME:?$DOMAIN_NAME NOT DEFINED}"
: "${TITLE:?$TITLE NOT DEFINED}"
: "${WP_ADM:?$WP_ADM NOT DEFINED}"
: "${WP_ADM_PASS:?$WP_ADM_PASS NOT DEFINED}"
: "${WP_ADM_EMAIL:?$WP_ADM_EMAIL NOT DEFINED}"
: "${WP_USER_EMAIL:?$WP_USER_EMAIL NOT DEFINED}"
: "${WP_USER_LOGIN:?$WP_USER_LOGIN NOT DEFINED}"
: "${WP_USER_ROLE:?$WP_USER_ROLE NOT DEFINED}"
: "${WP_USER_PASS:?$WP_USER_PASS NOT DEFINED}"

VOL_DIR=/var/www/wordpress
cd $VOL_DIR
if [ ! -f "$VOL_DIR/wp-config.php" ]; then
	sleep_time=1
	while ! php83 -r "mysqli_report(MYSQLI_REPORT_OFF); \$mysqli = new mysqli('$MYSQL_HOST', '$MYSQL_USER', '$MYSQL_PWD', '$MYSQL_DB'); if (\$mysqli->connect_error) exit(1); \$mysqli->close();" >/dev/null 2>&1; do
		echo "⏳ Wait for DB.."
		sleep $sleep_time
		sleep_time=$(( sleep_time * 2 ))
		if [ $sleep_time -gt 16 ]; then sleep_time=16; fi
	done
	if ! php83 -d memory_limit=512M /usr/local/bin/wp core is-installed --allow-root; then

		php83 -d memory_limit=256M /usr/local/bin/wp --allow-root core download
		php83 -d memory_limit=256M /usr/local/bin/wp --allow-root config create \
			--dbname="$MYSQL_DB" \
			--dbuser="$MYSQL_USER" \
			--dbpass="$MYSQL_PWD" \
			--dbhost="$MYSQL_HOST"
		php83 -d memory_limit=256M /usr/local/bin/wp --allow-root core install \
				--url="$DOMAIN_NAME" \
				--title="$TITLE" \
				--admin_user="$WP_ADM" \
				--admin_password="$WP_ADM_PASS" \
				--admin_email="$WP_ADM_EMAIL"
		if ! php83 -d memory_limit=512M /usr/local/bin/wp user get "$WP_USER_LOGIN" --allow-root > /dev/null 2>&1; then
			php83 -d memory_limit=256M /usr/local/bin/wp --allow-root user create "$WP_USER_LOGIN" "$WP_USER_EMAIL" \
				--role="$WP_USER_ROLE" \
				--user_pass="$WP_USER_PASS"
		fi
	fi
fi

chown -R nobody:nobody /var/www/wordpress
exec /usr/sbin/php-fpm83 -F
