#!/bin/sh
set -e
envsubst '${SSL_PORT} ${DOMAIN_NAME} ${WP_PORT}' \
< /etc/nginx/templates/nginx.conf.template \
> /etc/nginx/http.d/default.conf

exec nginx -g 'daemon off;'
