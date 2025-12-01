.PHONY: help up down build logs restart shell ps clean clean-all clean-volumes \
        dev-up dev-down dev-build dev-logs dev-restart dev-shell dev-ps \
        prod-up prod-down prod-build prod-logs prod-restart \
        backend-shell gateway-shell mongo-shell \
        backend-build backend-install backend-type-check backend-dev \
        db-reset db-backup status health

# Default target
.DEFAULT_GOAL := help

# Variables
MODE ?= dev
SERVICE ?= backend
COMPOSE_FILE_DEV = -f docker/compose.development.yaml
COMPOSE_FILE_PROD = -f docker/compose.production.yaml
COMPOSE_CMD = docker compose
ARGS ?=

# Determine which compose file to use
ifeq ($(MODE),prod)
	COMPOSE_FILE = $(COMPOSE_FILE_PROD)
	ENV_FILE = --env-file .env
else
	COMPOSE_FILE = $(COMPOSE_FILE_DEV)
	ENV_FILE = --env-file .env
endif

##@ Docker Services

up: ## Start services (use: make up [service...] or make up MODE=prod, ARGS="--build" for options)
	@echo "Starting services in $(MODE) mode..."
	$(COMPOSE_CMD) $(COMPOSE_FILE) $(ENV_FILE) up -d $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

down: ## Stop services (use: make down [service...] or make down MODE=prod, ARGS="--volumes" for options)
	@echo "Stopping services in $(MODE) mode..."
	$(COMPOSE_CMD) $(COMPOSE_FILE) $(ENV_FILE) down $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

build: ## Build containers (use: make build [service...] or make build MODE=prod)
	@echo "Building containers in $(MODE) mode..."
	$(COMPOSE_CMD) $(COMPOSE_FILE) $(ENV_FILE) build $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

logs: ## View logs (use: make logs [service] or make logs SERVICE=backend, MODE=prod for production)
	@echo "Showing logs for $(MODE) mode..."
	$(COMPOSE_CMD) $(COMPOSE_FILE) $(ENV_FILE) logs -f $(if $(filter-out $@,$(MAKECMDGOALS)),$(filter-out $@,$(MAKECMDGOALS)),$(if $(filter logs,$(MAKECMDGOALS)),$(SERVICE),))

restart: ## Restart services (use: make restart [service...] or make restart MODE=prod)
	@echo "Restarting services in $(MODE) mode..."
	$(COMPOSE_CMD) $(COMPOSE_FILE) $(ENV_FILE) restart $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

shell: ## Open shell in container (use: make shell [service] or make shell SERVICE=gateway, MODE=prod, default: backend)
	@echo "Opening shell in $(if $(filter-out $@,$(MAKECMDGOALS)),$(word 1,$(filter-out $@,$(MAKECMDGOALS))),$(SERVICE)) container ($(MODE) mode)..."
	$(COMPOSE_CMD) $(COMPOSE_FILE) $(ENV_FILE) exec $(if $(filter-out $@,$(MAKECMDGOALS)),$(word 1,$(filter-out $@,$(MAKECMDGOALS))),$(SERVICE)) sh

ps: ## Show running containers (use MODE=prod for production)
	@echo "Running containers in $(MODE) mode:"
	$(COMPOSE_CMD) $(COMPOSE_FILE) $(ENV_FILE) ps

##@ Development Aliases

dev-up: ## Start development environment
	@$(MAKE) up MODE=dev

dev-down: ## Stop development environment
	@$(MAKE) down MODE=dev

dev-build: ## Build development containers
	@$(MAKE) build MODE=dev

dev-logs: ## View development logs
	@$(MAKE) logs MODE=dev

dev-restart: ## Restart development services
	@$(MAKE) restart MODE=dev

dev-shell: ## Open shell in backend container (dev)
	@$(MAKE) shell MODE=dev SERVICE=backend

dev-ps: ## Show running development containers
	@$(MAKE) ps MODE=dev

backend-shell: ## Open shell in backend container
	@$(MAKE) shell SERVICE=backend

gateway-shell: ## Open shell in gateway container
	@$(MAKE) shell SERVICE=gateway

mongo-shell: ## Open MongoDB shell
	@echo "Opening MongoDB shell..."
	$(COMPOSE_CMD) $(COMPOSE_FILE) $(ENV_FILE) exec mongo mongosh -u $(shell grep MONGO_INITDB_ROOT_USERNAME .env | cut -d '=' -f2) -p $(shell grep MONGO_INITDB_ROOT_PASSWORD .env | cut -d '=' -f2) --authenticationDatabase admin

##@ Production Aliases

prod-up: ## Start production environment
	@$(MAKE) up MODE=prod

prod-down: ## Stop production environment
	@$(MAKE) down MODE=prod

prod-build: ## Build production containers
	@$(MAKE) build MODE=prod

prod-logs: ## View production logs
	@$(MAKE) logs MODE=prod

prod-restart: ## Restart production services
	@$(MAKE) restart MODE=prod

##@ Backend Development

backend-build: ## Build backend TypeScript
	@echo "Building backend TypeScript..."
	cd backend && npm run build

backend-install: ## Install backend dependencies
	@echo "Installing backend dependencies..."
	cd backend && npm install

backend-type-check: ## Type check backend code
	@echo "Type checking backend code..."
	cd backend && npm run type-check

backend-dev: ## Run backend in development mode (local, not Docker)
	@echo "Starting backend in local development mode..."
	cd backend && npm run dev

##@ Database Management

db-reset: ## Reset MongoDB database (WARNING: deletes all data)
	@echo "WARNING: This will delete all data in the database!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "Resetting database..."; \
		$(COMPOSE_CMD) $(COMPOSE_FILE) $(ENV_FILE) exec mongo mongosh -u $(shell grep MONGO_INITDB_ROOT_USERNAME .env | cut -d '=' -f2) -p $(shell grep MONGO_INITDB_ROOT_PASSWORD .env | cut -d '=' -f2) --authenticationDatabase admin --eval "use $(shell grep MONGO_DATABASE .env | cut -d '=' -f2); db.dropDatabase();"; \
		echo "Database reset complete."; \
	else \
		echo "Database reset cancelled."; \
	fi

db-backup: ## Backup MongoDB database
	@echo "Creating database backup..."
	@mkdir -p backups
	$(COMPOSE_CMD) $(COMPOSE_FILE) $(ENV_FILE) exec -T mongo mongodump --username $(shell grep MONGO_INITDB_ROOT_USERNAME .env | cut -d '=' -f2) --password $(shell grep MONGO_INITDB_ROOT_PASSWORD .env | cut -d '=' -f2) --authenticationDatabase admin --db $(shell grep MONGO_DATABASE .env | cut -d '=' -f2) --archive > backups/mongo-backup-$(shell date +%Y%m%d-%H%M%S).archive
	@echo "Backup saved to backups/ directory"

##@ Cleanup

clean: ## Remove containers and networks (both dev and prod)
	@echo "Cleaning up containers and networks..."
	$(COMPOSE_CMD) $(COMPOSE_FILE_DEV) $(ENV_FILE) down
	$(COMPOSE_CMD) $(COMPOSE_FILE_PROD) $(ENV_FILE) down

clean-all: ## Remove containers, networks, volumes, and images
	@echo "WARNING: This will remove all containers, networks, volumes, and images!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "Removing all resources..."; \
		$(COMPOSE_CMD) $(COMPOSE_FILE_DEV) $(ENV_FILE) down --volumes --rmi all; \
		$(COMPOSE_CMD) $(COMPOSE_FILE_PROD) $(ENV_FILE) down --volumes --rmi all; \
		echo "Cleanup complete."; \
	else \
		echo "Cleanup cancelled."; \
	fi

clean-volumes: ## Remove all volumes
	@echo "WARNING: This will delete all data in volumes!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "Removing volumes..."; \
		$(COMPOSE_CMD) $(COMPOSE_FILE_DEV) $(ENV_FILE) down --volumes; \
		$(COMPOSE_CMD) $(COMPOSE_FILE_PROD) $(ENV_FILE) down --volumes; \
		echo "Volumes removed."; \
	else \
		echo "Volume removal cancelled."; \
	fi

##@ Utilities

status: ps ## Alias for ps

health: ## Check service health
	@echo "Checking service health..."
	@echo "\n=== Gateway Health ==="
	@curl -s http://localhost:5921/health | grep -q '"ok":true' && echo "✓ Gateway: Healthy" || echo "✗ Gateway: Unhealthy"
	@echo "\n=== Backend Health (via Gateway) ==="
	@curl -s http://localhost:5921/api/health | grep -q '"ok":true' && echo "✓ Backend: Healthy" || echo "✗ Backend: Unhealthy"
	@echo "\n=== Container Status ==="
	@$(MAKE) ps MODE=$(MODE)

##@ Help

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

# Allow passing targets as arguments
%:
	@:


