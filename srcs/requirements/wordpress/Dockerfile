FROM alpine:3.22

RUN apk add --no-cache \
	php83=8.3.29-r0 \
	php83-fpm=8.3.29-r0 \
	php83-mysqli=8.3.29-r0 \
	php83-curl=8.3.29-r0 \
	php83-dom=8.3.29-r0 \
	php83-exif=8.3.29-r0 \
    	php83-fileinfo=8.3.29-r0 \
   	php83-mbstring=8.3.29-r0 \
   	php83-openssl=8.3.29-r0 \
	php83-xml=8.3.29-r0 \
	php83-zip=8.3.29-r0 \
	php83-phar=8.3.29-r0 \
	curl=8.14.1-r2  && \
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
   	chmod +x wp-cli.phar && \
   	mv wp-cli.phar /usr/local/bin/wp && \
	sed -i 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|g' /etc/php83/php-fpm.d/www.conf
