stack_name=minecraft_server

app_container_id = $(shell docker ps --filter name="$(stack_name)" -q)

.PHONY: bash
bash:
	docker exec -it -u root $(app_container_id) bash

.PHONY: deploy
deploy:
	docker-compose up -d

.PHONY: undeploy
undeploy:
	make save-world
	docker-compose down

.PHONY: restart
restart:
	make undeploy
	make deploy

.PHONY: save-world
save-world:
	docker exec minecraft-vanilla-2024_mc_1 rcon-cli /save-all

.PHONY: logs
logs:
	docker-compose logs -f

.PHONY: send-message
send-message:
	docker exec minecraft-vanilla-2024_mc_1 rcon-cli /say $(MESSAGE)


