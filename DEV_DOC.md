# DEVELOPER DOCUMENTATION

## 1. Project Overview

This project implements a containerized infrastructure using Docker and Docker Compose inside a Virtual Machine.

The stack consists of:

- NGINX (HTTPS reverse proxy)
- WordPress (php-fpm only)
- MariaDB
- Two named volumes
- One dedicated Docker bridge network

All services are built using custom Dockerfiles (no pre-built images except Alpine/Debian base images).

---

# 2. Prerequisites

To set up the environment from scratch, you need:

- A Linux Virtual Machine
- Docker installed
- Docker Compose installed
- Proper domain configuration in `/etc/hosts`

Example:

```
127.0.0.1    <your_login>.42.fr
```

Replace `<your_login>` with your actual 42 login.

---

# 3. Project Structure

Expected structure:

```

.
├── Makefile
├── secrets/
│	├── db_password.txt
│	├── db_root_password.txt
│	└── credentials.txt
└── srcs/
	├── docker-compose.yml
	├── .env
	└── requirements/
		├── mariadb/
		|	├── Dockerfile
		|	└── conf
		|		└── setup.sh
		├── nginx/
		|	├── Dockerfile
		|	└── conf
		|		└── nginx.conf
		└── wordpress/
			├── Dockerfile
			└── conf
				└── setup.sh

```

---

# 4. Environment Configuration

## 4.1 .env File

Located in:

```

srcs/.env

```

Used to store non-sensitive configuration:

Example:

```
DOMAIN_NAME=<your_login>.42.fr

MYSQL_DB=wordpress
MYSQL_USER=wpuser
MYSQL_HOST=mariadb

WP_TITLE=Inception
WP_USER=editoruser
WP_EMAIL=[user@example.com](mailto:user@example.com)
```

⚠️ No passwords must be stored in this file if Docker secrets are used.

---

## 4.2 Docker Secrets

Secrets are stored inside:

```
/secrets
```

Example:

- db_password.txt
- db_root_password.txt

These are referenced inside `docker-compose.yml` and mounted at runtime.

Secrets are:
- Not committed to Git
- Not hardcoded in Dockerfiles
- Not visible in image layers

---

# 5. Building and Launching

From project root:

```
make
```

This command should:

1. Call docker compose
2. Build images
3. Create volumes
4. Create network
5. Start containers

Equivalent manual command:

```
docker compose -f srcs/docker-compose.yml up --build -d
```

---

# 6. Stopping and Cleaning

Stop containers:

```
make down
```

Equivalent:

```
docker compose -f srcs/docker-compose.yml down
```

Remove containers, images, and volumes:

```
make fclean
```

---

# 7. Container Management

## Check running containers

```
docker ps
```

## Inspect logs

```
docker logs <container_name>
```

## Execute command inside container

```
docker exec -it <container_name> sh
```

---

# 8. Volumes & Data Persistence

Two named volumes are used:

- WordPress database volume
- WordPress website files volume

They are mapped to:

```
/home/<your_login>/data
```

Data persists even if containers are removed.

To inspect volumes:

```
docker volume ls
```

To inspect volume details:

```
docker volume inspect <volume_name>
```

---

# 9. Networking

A custom Docker bridge network is defined in `docker-compose.yml`.

Properties:

- Containers communicate via service name
- No host network used
- No `--link` or `network: host`
- Required by subject

Example:

- WordPress connects to MariaDB using hostname: `mariadb`
- NGINX connects to WordPress using hostname: `wordpress`

---

# 10. Service Design Details

## 10.1 NGINX

- Only service exposing port 443
- TLSv1.2 or TLSv1.3 enforced
- Self-signed certificate
- Reverse proxy to php-fpm

No HTTP (port 80) exposed.

---

## 10.2 WordPress

- php-fpm only (no nginx inside)
- Configured via wp-cli or installation script
- Connects to MariaDB using environment variables

Two users must exist:

- One administrator (username must NOT contain admin/Admin/administrator)
- One regular user

---

## 10.3 MariaDB

- Custom configuration
- Database initialized using environment variables and secrets
- Root password stored as secret
- Database stored in named volume

---

# 11. Restart Policy

All containers use:

```
restart: always
```

Containers automatically restart in case of crash.

---

# 12. Compliance Checklist

✔ Custom Dockerfiles
✔ No `latest` tag
✔ No pre-built images (except Alpine/Debian base)
✔ Named volumes only (no bind mounts for DB/WP data)
✔ Custom Docker network
✔ Only port 443 exposed
✔ TLSv1.2 or TLSv1.3 only
✔ No passwords in Dockerfiles
✔ Environment variables required
✔ Docker secrets used
✔ No infinite loops (no tail -f, sleep infinity, while true)
✔ Proper PID 1 handling

---

# 13. Common Development Tasks

## Rebuild a single service

```
docker compose -f srcs/docker-compose.yml build <service_name>
```

## Restart a single service

```
docker compose -f srcs/docker-compose.yml restart <service_name>
```

## Remove unused images

```
docker image prune
```

---

# 14. Data Reset (Development Only)

To fully reset environment:

```
make fclean
```

⚠️ This deletes all persistent data.

---

# 15. Debugging Tips

If WordPress cannot connect to MariaDB:

- Check DB credentials
- Check network configuration
- Inspect MariaDB logs
- Verify secrets are mounted correctly

If NGINX returns 502:

- Check php-fpm is running
- Verify fastcgi configuration
- Check internal service hostname

---

# 16. Verifying Database Initialization

After starting the project, it is useful to verify that the MariaDB database and the WordPress database were created correctly.

## 16.1 Access the MariaDB Container

First, enter the MariaDB container:

```
docker exec -it <mariadb_container_name> mariadb -u root -p
```

You will be prompted for the root password stored in the Docker secret.

---

## 16.2 List Existing Databases

Inside the MariaDB client, run:

```
SHOW DATABASES;
```

You should see something similar to:

```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| wordpress          |
+--------------------+
```

The `wordpress` database confirms that the database was created successfully.

---

## 16.3 Check if Tables Were Created

To inspect the WordPress tables:

```
USE wordpress;
SHOW TABLES;
```

Example expected output:

```
+-----------------------+
| Tables_in_wordpress   |
+-----------------------+
| wp_posts              |
| wp_users              |
| wp_options            |
| wp_comments           |
| wp_terms              |
...
```

This confirms that WordPress successfully initialized the database schema.

---

## 16.4 Check Database Using WP-CLI (Alternative)

Inside the WordPress container:

```
docker exec -it <wordpress_container_name> sh
```

Then run:

```
wp db check --allow-root
```

Expected output:

```
Success: Database checked.
```

This confirms that WordPress can connect to MariaDB and that the database is healthy.

---

## 16.5 Automated Check (Optional)

Developers can also verify database existence using:

```
docker exec <mariadb_container_name>
mariadb -u root -p$(cat /run/secrets/db_root_password)
-e "SHOW DATABASES;"
```

This allows quick validation of the database from the host system.

---

# 17. Infrastructure Verification

This section provides commands that developers can use to verify that each component of the infrastructure is correctly configured and functioning.

---

# 17.1 Verify TLS Configuration (NGINX)

The project requires **TLSv1.2 or TLSv1.3 only**.

From the host machine, run:

```
curl -v https://<your_login>.42.fr
```

Look for the TLS handshake in the output:

```
SSL connection using TLSv1.3
```

or

```
SSL connection using TLSv1.2
```

If TLSv1.1 or TLSv1.0 appear, the configuration is incorrect.

---

### Alternative verification using OpenSSL

```
openssl s_client -connect <your_login>.42.fr:443
```

Expected output includes:

```
Protocol  : TLSv1.2
```
or
```
Protocol  : TLSv1.3
```
---

# 17.2 Verify Persistent Volumes

List Docker volumes:

```
docker volume ls
```

You should see volumes similar to:

```
wp_volume
db_volume
```

Inspect a specific volume:

```
docker volume inspect <volume_name>
```

This shows the mount point on the host machine.

The volumes must store data inside:

```
/home/<your_login>/data
```

Example check:

```
ls /home/<your_login>/data
```

Expected directories:

```
mariadb
wordpress
```

These confirm that data persists outside containers.

---

# 17.3 Verify Docker Network

List Docker networks:

```
docker network ls
```

Find the network created by the project.

Inspect the network:

```
docker network inspect <network_name>
```

Expected output should list the containers:

```
nginx
wordpress
mariadb
```

This confirms the containers are connected to the same internal network.

---

# 17.4 Verify Communication Between Containers

Enter the WordPress container:

```
docker exec -it <wordpress_container_name> sh
```

Test connectivity to MariaDB:

```
ping mariadb
```

Expected result:

```
PING mariadb (172.x.x.x)
```

Another useful test:

```
nc -zv mariadb 3306
```

Expected output:

```
Connection to mariadb 3306 port [tcp/mysql] succeeded!
```

This confirms that WordPress can communicate with the database.

---

# 17.5 Verify php-fpm is Running

Enter the WordPress container:

```
docker exec -it <wordpress_container_name> sh
```

Check running processes:

```
ps aux
```

You should see php-fpm processes similar to:

```
php-fpm: master process
php-fpm: pool www
php-fpm: pool www
```

This confirms that **php-fpm is running and managing PHP workers**.

---

### Alternative Check

Check if the php-fpm port is open inside the container:

```
ss -lntp
```

Expected output should show something like:

```
9000 php-fpm
```

This confirms that php-fpm is listening for connections from NGINX.

---

# 17.6 Verify Reverse Proxy (NGINX → PHP-FPM)

From the NGINX container:

```
docker exec -it <nginx_container_name> sh
```

Test connection to WordPress:

```
nc -zv wordpress 9000
```

Expected result:

```
Connection to wordpress 9000 port succeeded
```

This confirms that NGINX can reach php-fpm.

---

# 18. Development Notes

- PID 1 properly handled in containers
- No daemonization hacks used
- Services run in foreground
- No infinite loop entrypoints
- Strict separation of concerns between containers

---

# 19. AI Usage Disclosure

AI tools were used in the following way:

- To clarify Docker networking concepts
- To compare infrastructure design choices
- To review documentation structure
- To validate best practices for Dockerfiles
- To improve README clarity and English writing

All generated content was reviewed, understood, and adapted manually before inclusion in the project.

No critical implementation logic was copied blindly. All configuration files and scripts were written and tested manually.

---

This documentation is intended for developers who need to understand, modify, debug, or extend the project infrastructure.

