NAME = inception
COMPOSE_FILE = ./srcs/docker-compose.yaml

DATA_WP := /home/nfigueir/data/wp
DATA_DB := /home/nfigueir/data/db

all: build
	@echo "✅ A levantar a infraestrutura..."
	docker compose -f $(COMPOSE_FILE) up -d

up:
	docker compose -f $(COMPOSE_FILE) up -d

build:
	@echo "✅ A construir as imagens Docker..."
	@mkdir -p $(DATA_WP) $(DATA_DB)
	docker compose -f $(COMPOSE_FILE) build

start:
	docker compose -f ./srcs/docker-compose.yaml start

stop:
	@echo "✅ A parar os contentores..."
	docker compose -f $(COMPOSE_FILE) stop

down:
	@echo "✅ A remover os contentores..."
	docker compose -f $(COMPOSE_FILE) down

db:
	docker exec -it srcs-mariadb-1 mariadb -u root -hlocalhost -p

logs:
	docker compose -f $(COMPOSE_FILE) logs -f
clean:
	@echo "✅ Limpeza profunda..."
	docker compose -f $(COMPOSE_FILE) down --rmi local 	--volumes --remove-orphans || true

fclean: clean
	@echo "🗑️ Removendo TODOS os dados persistentes no host..."
	docker run --rm -v $(DATA_WP):/data alpine sh -c 'find /data -mindepth 1 -delete' 2>/dev/null || true
	docker run --rm -v $(DATA_DB):/data alpine sh -c 'find /data -mindepth 1 -delete' 2>/dev/null || true
	docker volume rm $$(docker volume ls) 2>/dev/null || true
	@echo "✅ fclean completo! Tudo apagado sem sudo."

re: fclean all

.PHONY: all build stop down clean fclean re
# configurações do mariadb
MYSQL_DB=wordpress
MYSQL_USER=nfigueir
MYSQL_HOST=mariadb


# configurações do wordpress
DOMAIN_NAME=nfigueir.42.fr
TITLE=inception-title
WP_ADM=inception
WP_ADM_EMAIL=matendafigueiredo@hotmail.com
WP_USER_LOGIN=nfigueir
WP_USER_ROLE=editor
WP_USER_EMAIL=treyclassper@gmail.com
WP_PORT=8000

SSL_PORT=5555
