cd srcs && docker compose down -v
docker rm -f `(docker ps -aq)`
docker rmi -f `(docker images -aq)`
docker system prune -f
