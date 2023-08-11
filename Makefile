## for start mySQL container:
SHELL := /bin/bash
LOCAL_COMPOSE_FILE := infra/dev/docker-compose.local.yaml

COLOR_RESET = \033[0m
COLOR_GREEN = \033[32m
COLOR_YELLOW = \033[33m

.DEFAULT_GOAL := help
.PHONY: help

help:  # Show help
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: runbot-init
runbot-init: deletedb rundb migrate filldb runbot-db
	@echo -e "$(COLOR_YELLOW)Starting initialization...$(COLOR_RESET)"

.PHONY: rundb
rundb: # Build and run Database Docker-image
	@echo -e "$(COLOR_YELLOW)Starting database...$(COLOR_RESET)"
	@until docker compose -f $(LOCAL_COMPOSE_FILE) up -d; do \
	  echo -e "$(COLOR_YELLOW)Waiting database to be started...$(COLOR_RESET)"; \
	  sleep 5 ;\
	done
	@sleep 3 ;
	@echo -e "$(COLOR_GREEN)Database started$(COLOR_RESET)"


.PHONY: stopdb
stopdb: # Stop mySQL Database Docker-image
	@echo -e "$(COLOR_YELLOW)Stopping database...$(COLOR_RESET)"
	@docker compose -f $(LOCAL_COMPOSE_FILE) down
	@echo -e "$(COLOR_GREEN)Database stopped$(COLOR_RESET)"


.PHONY: deletedb
deletedb: ## Stop and delete mySQL database Docker-image and volumes
	@echo -e "$(COLOR_YELLOW)Deleting database...$(COLOR_RESET)"
	@until docker compose -f $(LOCAL_COMPOSE_FILE) down --volumes; do \
	  echo -e "$(COLOR_YELLOW)Waiting database to be deleted...$(COLOR_RESET)"; \
	  sleep 5 ;\
	done
	@sleep 3 ;
	@echo -e "$(COLOR_GREEN)Database deleted$(COLOR_RESET)"


.PHONY: runbot-db
runbot-db: # Run Telegram bot on Uvicorn
	@echo -e "$(COLOR_YELLOW)Starting bot...$(COLOR_RESET)"
	@cd src && poetry run uvicorn config.asgi:application --reload && cd .. && \
	echo -e "$(COLOR_GREEN)Bot stopped$(COLOR_RESET)"

.PHONY: filldb
filldb: # Fill Docker-image Database with test data
	@echo -e "$(COLOR_YELLOW)Filing database...$(COLOR_RESET)"
	@until python src/manage.py filldb; do \
	  echo -e "$(COLOR_YELLOW)Waiting database to be filled...$(COLOR_RESET)"; \
	  sleep 5 ;\
	done
	@sleep 3 ;
	@echo -e "$(COLOR_GREEN)Database filled$(COLOR_RESET)"

.PHONY: collectstatic
collectstatic: # Collect project static files
	@echo -e "$(COLOR_YELLOW)Collecting static...$(COLOR_RESET)"
	@until python src/manage.py collectstatic; do \
	  echo -e "$(COLOR_YELLOW)Waiting static to be collected...$(COLOR_RESET)"; \
	  sleep 5 ;\
	done
	@sleep 3;
	@echo -e "$(COLOR_GREEN)Static collected$(COLOR_RESET)"

.PHONY: migrate
migrate: # Commit migrations to Database
	@echo -e "$(COLOR_YELLOW)Migrating...$(COLOR_RESET)"
	@until python src/manage.py migrate; do \
	  echo "Waiting for migrations..."; \
	  sleep 5; \
	done
	@sleep 3;
	@echo -e "$(COLOR_GREEN)Migrated$(COLOR_RESET)"