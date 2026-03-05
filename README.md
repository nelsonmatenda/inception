*This project has been created as part of the 42 curriculum by nfigueir.*

# Inception

## Description

**Inception** is a System Administration project from the 42 curriculum focused on containerization using Docker and Docker Compose.

The objective of this project is to build a small infrastructure composed of multiple isolated services running in dedicated Docker containers inside a Virtual Machine. Each service is built manually using custom Dockerfiles (no pre-built images except Alpine/Debian base images).

The infrastructure includes:

- An NGINX container with TLSv1.2 or TLSv1.3 enabled
- A WordPress container running with php-fpm (without nginx)
- A MariaDB container (without nginx)
- Two persistent named volumes:
  - One for the WordPress database
  - One for the WordPress website files
- A dedicated Docker network connecting the containers

The only entrypoint to the infrastructure is **NGINX over HTTPS (port 443)**.

---

# Project Architecture

## Services

### 1. NGINX
- Terminates TLS (TLSv1.2 / TLSv1.3 only)
- Serves WordPress content
- Connects to WordPress via internal Docker network
- Only exposed service (port 443)

### 2. WordPress + php-fpm
- Runs php-fpm only (no nginx inside)
- Connects to MariaDB
- Stores website files in a named volume

### 3. MariaDB
- Database server
- Stores data in a named volume
- Not publicly exposed

---

# Technical Explanations

## Virtual Machines vs Docker

Virtual machines (VMs) emulate full hardware and OS, providing strong isolation but with higher resource overhead (e.g., each VM needs its own kernel, leading to slower startups in minutes). Docker containers share the host kernel, making them lightweight with near-native performance and millisecond startups, ideal for microservices. However, Docker offers less isolation, potentially risking host exposure if not secured properly. Use VMs for OS-level testing; Docker for app deployment efficiency.

| Virtual Machine | Docker |
|----------------|--------|
| Emulates full OS | Shares host kernel |
| Heavy resource usage | Lightweight |
| Slower boot time | Fast startup |
| Full isolation | Process-level isolation |

In this project, Docker is used because it provides lightweight service isolation while keeping performance high. The project still requires running Docker inside a VM to simulate a real production environment and avoid host pollution.

---

## Secrets vs Environment Variables

Docker secrets encrypt data at rest and in transit, accessible only to granted services via /run/secrets/, reducing leak risks. Environment variables are plaintext, visible in processes/logs, and easily leaked (e.g., via docker inspect). Secrets suit production for sensitive info; env vars for non-sensitive config. Inception uses secrets for passwords to mitigate exposure.

**Environment Variables (.env)**
- Used for non-sensitive configuration (domain name, DB name, usernames, etc.)
- Loaded automatically by Docker Compose

**Docker Secrets**
- Used for sensitive information (database passwords, root password)
- Not stored in Dockerfiles
- Not committed to Git
- Mounted securely at runtime

Secrets are preferred for credentials because they are not exposed in image layers or logs.

---

## Docker Network vs Host Network

Docker networks (e.g., bridge) isolate containers with virtual IPs, enabling secure inter-communication without exposing the host. Host network shares the host's stack, offering native performance but no isolation, risking port conflicts and security breaches. Use Docker networks for multi-container apps; host for high-performance, low-isolation needs. Inception employs a custom network for safety.

**Docker Network (bridge)**
- Containers communicate internally
- Services isolated from host
- Explicit network declaration in docker-compose.yml
- Required by subject

**Host Network**
- Container shares host network stack
- Breaks isolation
- Forbidden in this project

The bridge network ensures proper service isolation and controlled communication between containers.

---

## Docker Volumes vs Bind Mounts

Volumes are Docker-managed, stored in /var/lib/docker/volumes/, with easy backups and portability across hosts. Bind mounts link host paths directly, offering flexibility but less Docker integration and potential permission issues. Volumes suit production for managed persistence; binds for dev with host file access. Inception mandates named volumes for compliance.

**Named Volumes**
- Managed by Docker
- Persistent across container recreation
- Required by subject
- Stored in `/home/nfigueir/data`

**Bind Mounts**
- Direct host path mapping
- More flexible
- Not allowed for database/wordpress storage in this project

Named volumes are used to ensure portability, safety, and compliance with project requirements.

---

# Instructions

## Prerequisites

- Linux Virtual Machine
- Docker
- Docker Compose
- Proper domain configuration in `/etc/hosts`:

```

127.0.0.1    <your_login>.42.fr

```

---

## Setup

1. Clone the repository:
```
git clone <repository_url>
cd inception
```

2. Create required folders:
```
mkdir -p /home/<your_login>/data
```

3. Configure `.env` file inside `srcs/`:
```
DOMAIN_NAME=<your_login>.42.fr
MYSQL_DB=...
MYSQL_USER=...
...
```

---

## Build and Run

From project root:

```
make
```

This will:
- Build Docker images
- Create network
- Create volumes
- Start containers

---

## Stop Project

```
make down
```

---
## Clean Everything

```
make fclean
```
---

# How to Access

- Website:
```

https://<your_login>.42.fr

```

- WordPress Admin Panel:
```

https://<your_login>.42.fr/wp-admin

```

---

# Persistent Data

Data is stored inside:

```
/home/<your_login>/data
```

Volumes:
- WordPress database
- WordPress website files

Containers can be deleted without losing data.

---

# Security Considerations

- No passwords inside Dockerfiles
- No `latest` tag used
- TLSv1.2 / TLSv1.3 only
- Only port 443 exposed
- Containers restart on crash
- No infinite loops (no `tail -f`, no `sleep infinity`)
- Proper PID 1 handling

---

# Resources

## Docker
Official guides on Dockerfiles, Compose, and networking.
- https://docs.docker.com/
- https://docs.docker.com/compose/

## NGINX
Best practices for TLSv1.2/1.3. Dome tutorials.
- https://nginx.org/en/docs/

## WordPress
Tutorials on configuring WordPress with PHP-FPM.
- https://wordpress.org/support/

## MariaDB
Database setup in containers.
- https://mariadb.org/documentation/

---

# AI Usage Disclosure

AI tools were used in the following way:

- To clarify Docker networking concepts
- To compare infrastructure design choices
- To review documentation structure
- To validate best practices for Dockerfiles
- To improve README clarity and English writing

All generated content was reviewed, understood, and adapted manually before inclusion in the project.

No critical implementation logic was copied blindly. All configuration files and scripts were written and tested manually.

---

# Conclusion

This project demonstrates:

- Docker containerization
- Service isolation
- Secure credential management
- TLS configuration
- Persistent storage with volumes
- Infrastructure orchestration using Docker Compose

It reflects core system administration principles applied in a modern containerized environment.
```
