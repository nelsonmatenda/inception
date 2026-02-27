FROM alpine:3.22

RUN mkdir -p /etc/nginx/ssl /run/nginx && \
	apk add --no-cache nginx=1.28.2-r0 openssl=3.5.5-r0 && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/inception.key \
	-out /etc/nginx/ssl/inception.crt \
	-subj "/C=AO/ST=Luanda/L=Luanda/O=42/OU=42/CN=nfigueir.42.fr/UID=nfigueir"
COPY conf/nginx.conf /etc/nginx/http.d/default.conf

CMD ["nginx", "-g", "daemon off;"]



