# USER DOCUMENTATION

## 1. Overview

This project provides a containerized web infrastructure composed of:

- NGINX (HTTPS reverse proxy)
- WordPress (running with php-fpm)
- MariaDB (database server)

The services are isolated in Docker containers and communicate through a dedicated Docker network.

The only public entrypoint is:

```
https://<your_login>.42.fr
```

All persistent data is stored using Docker named volumes.

---

# 2. Services Provided

## NGINX
- Handles HTTPS connections (TLSv1.2 / TLSv1.3 only)
- Acts as reverse proxy
- Forwards requests to WordPress
- Only exposed service (port 443)

## WordPress
- Content Management System (CMS)
- Allows content creation and management
- Connects to MariaDB internally
- Accessible through web browser

## MariaDB
- Database server
- Stores WordPress data (users, posts, settings)
- Not accessible from outside the Docker network

---

# 3. How to Start the Project

From the project root directory:

```
make
```

This command will:

- Build Docker images
- Create the network
- Create volumes (if not already created)
- Start all containers

---

# 4. How to Stop the Project

To stop containers:

```
make down
```

To stop and remove everything (containers, images, volumes):

```
make fclean
```

⚠️ Warning: `make fclean` may remove persistent data depending on implementation.

---

# 5. Accessing the Website

Make sure your `/etc/hosts` file contains:

```
127.0.0.1    <your_login>.42.fr
```

Then open your browser and visit:

```
https://<your_login>.42.fr
```

Because the project uses a self-signed certificate, your browser may show a security warning.
You can safely accept it for local testing.

---

# 6. Accessing the WordPress Admin Panel

Go to:

```
https://<your_login>.42.fr/wp-admin
```

Log in using the administrator credentials defined in:

- `.env` file (username)
- Docker secrets (password)

⚠️ The administrator username does NOT contain:
- admin
- Admin
- administrator
- Administrator

---

# 7. Where Credentials Are Stored

Sensitive credentials are stored securely using:

- Docker Secrets (recommended)
- `.env` file (non-sensitive configuration only)

Secrets are located in:

```
/secrets/
```

They are NOT stored in:
- Dockerfiles
- Public Git repository
- docker-compose.yml

---

# 8. Persistent Data Location

All persistent data is stored in:

```
/home/<your_login>/data
```

This includes:

- WordPress database files
- WordPress website files

This ensures that:

- Data is not lost if containers are deleted
- Containers can be rebuilt safely

---

# 9. Checking if Services Are Running

To check container status:

```
docker ps
```

You should see:

- nginx
- wordpress
- mariadb

To check logs:

```
docker logs <container_name>
```

Example:

```
docker logs nginx
docker logs wordpress
docker logs mariadb
```

---

# 10. Verifying HTTPS

To verify TLS version:

```
curl -v https://<your_login>.42.fr
```
You should see:

- TLSv1.2 or TLSv1.3
- Successful HTTPS handshake

---

# 11. Troubleshooting

If the website does not load:

1. Check containers are running:
```
docker ps
```

2. Check logs:
```
docker logs <container_name>
```

3. Verify domain configuration in `/etc/hosts`.

4. Restart the project:
```
make down
make
```

---

# 12. Important Notes

- Only port 443 is exposed.
- MariaDB is not publicly accessible.
- No passwords are stored inside Dockerfiles.
- Containers restart automatically if they crash.
- No infinite loops (tail -f, sleep infinity, while true) are used.

---

# 13. Project Compliance Summary

✔ Custom Dockerfiles
✔ No `latest` tag
✔ No pre-built images (except Alpine/Debian base)
✔ Named volumes only
✔ Proper Docker network
✔ TLSv1.2 / TLSv1.3 only
✔ Environment variables required
✔ Docker secrets used for credentials
✔ Only NGINX exposed

---

This documentation is intended for end users and evaluators to understand how to use and validate the project.
```
