NAME = inception
COMPOSE_FILE = ./srcs/docker-compose.yaml

all: build
	@echo "🚀 A levantar a infraestrutura..."
	docker compose -f $(COMPOSE_FILE) up -d

up:
	docker compose -f $(COMPOSE_FILE) up -d

build:
	@echo "🏗️ A construir as imagens Docker..."
	@mkdir -p /home/nfigueir/data/wp
	@mkdir -p /home/nfigueir/data/db
	docker compose -f $(COMPOSE_FILE) build

stop:
	@echo "🛑 A parar os contentores..."
	docker compose -f $(COMPOSE_FILE) stop

down:
	@echo "📉 A remover os contentores..."
	docker compose -f $(COMPOSE_FILE) down

db:
	docker exec -it srcs-mariadb-1 mariadb -u root -hlocalhost -p

logs:
	docker compose -f $(COMPOSE_FILE) logs -f
clean: down
	@echo "🧹 Limpeza profunda..."
	docker system prune -a

fclean: clean
	@echo "🗑️ A remover volumes e dados persistentes..."
	docker volume rm $$(docker volume ls -q) || true
	rm -rf /home/nfigueir/data/wp
	rm -rf /home/nfigueir/data/db

re: fclean all

.PHONY: all build stop down clean fclean re
