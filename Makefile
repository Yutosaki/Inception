all: up

ps:
	cd srcs && docker compose ps
up:
	cd srcs && docker compose up -d
build:
	cd srcs && docker compose build --no-cache $(CONTAINER)
restart:
	cd srcs && docker compose restart $(CONTAINER)
logs:
	cd srcs && docker compose logs -f $(CONTAINER)
exec:
	cd srcs && docker compose exec -it $(CONTAINER) /bin/bash
clean:
	./clean.sh
