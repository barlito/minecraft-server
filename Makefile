# Get container ID using docker-compose
app_container_id = $(shell docker compose ps -q mc)

.PHONY: bash
bash:
	docker exec -it -u root $(app_container_id) bash

.PHONY: deploy
deploy:
	docker compose up -d

.PHONY: undeploy
undeploy:
	make save-world
	docker compose down

.PHONY: stop
stop:
	docker-compose down

.PHONY: restart
restart:
	make undeploy
	make deploy

.PHONY: save-world
save-world:
	docker exec $(app_container_id) rcon-cli /save-all

.PHONY: logs
logs:
	docker compose logs -f

.PHONY: send-message
send-message:
	docker exec $(app_container_id) rcon-cli /say $(MESSAGE)

.PHONY: status
status:
	docker compose ps

.PHONY: backup
backup:
	@echo "Creating backup..."
	tar -czf backup-$(shell date +%Y%m%d-%H%M%S).tar.gz minecraft-data worlds mods plugins modpacks
	@echo "Backup created: backup-$(shell date +%Y%m%d-%H%M%S).tar.gz"

.PHONY: console
console:
	echo "To get out docker attach : CTRL + P followed by CTRL + Q"
	docker attach $(app_container_id)

.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make deploy        - Start the Minecraft server"
	@echo "  make undeploy      - Save world and stop the server"
	@echo "  make stop          - Stop the server without saving (useful if server crashed)"
	@echo "  make restart       - Restart the server"
	@echo "  make logs          - Stream server logs"
	@echo "  make status        - Show container status"
	@echo "  make bash          - Access container shell (root)"
	@echo "  make console       - Attach to server console"
	@echo "  make save-world    - Force save the world"
	@echo "  make backup        - Create a backup of all server data"
	@echo "  make send-message  - Send message to players (use MESSAGE='text')"
