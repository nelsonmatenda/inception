FROM alpine:3.22

COPY conf/setup.sh /usr/local/bin/setup.sh

RUN apk add --no-cache mariadb=11.4.8-r0 mariadb-client=11.4.8-r0 mariadb-common=11.4.8-r0 && \
	mkdir -p /run/mysqld && \
	chown -R mysql:mysql /run/mysqld && \
	chmod +x /usr/local/bin/setup.sh &&\
	sed -i 's/skip-networking/#skip-networking/g' /etc/my.cnf.d/mariadb-server.cnf && \
	sed -i 's/#bind-address=0.0.0.0/bind-address=0.0.0.0/g' /etc/my.cnf.d/mariadb-server.cnf

CMD ["/usr/local/bin/setup.sh"]
