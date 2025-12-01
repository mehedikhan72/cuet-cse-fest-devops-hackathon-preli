# ============================================================================
# CUET DevOps Hackathon - Makefile
# ============================================================================
# Docker Services:
#   up - Start services (use: make up [service...] or make up MODE=prod, ARGS="--build" for options)
#   down - Stop services (use: make down [service...] or make down MODE=prod, ARGS="--volumes" for options)
#   build - Build containers (use: make build [service...] or make build MODE=prod)
#   logs - View logs (use: make logs [service] or make logs SERVICE=backend, MODE=prod for production)
#   restart - Restart services (use: make restart [service...] or make restart MODE=prod)
#   shell - Open shell in container (use: make shell [service] or make shell SERVICE=gateway, MODE=prod, default: backend)
#   ps - Show running containers (use MODE=prod for production)
#
# Convenience Aliases (Development):
#   dev-up - Alias: Start development environment
#   dev-down - Alias: Stop development environment
#   dev-build - Alias: Build development containers
#   dev-logs - Alias: View development logs
#   dev-restart - Alias: Restart development services
#   dev-shell - Alias: Open shell in backend container
#   dev-ps - Alias: Show running development containers
#   backend-shell - Alias: Open shell in backend container
#   gateway-shell - Alias: Open shell in gateway container
#   mongo-shell - Open MongoDB shell
#
# Convenience Aliases (Production):
#   prod-up - Alias: Start production environment
#   prod-down - Alias: Stop production environment
#   prod-build - Alias: Build production containers
#   prod-logs - Alias: View production logs
#   prod-restart - Alias: Restart production services
#
# Backend:
#   backend-build - Build backend TypeScript
#   backend-install - Install backend dependencies
#   backend-type-check - Type check backend code
#   backend-dev - Run backend in development mode (local, not Docker)
#
# Database:
#   db-reset - Reset MongoDB database (WARNING: deletes all data)
#   db-backup - Backup MongoDB database
#
# Cleanup:
#   clean - Remove containers and networks (both dev and prod)
#   clean-all - Remove containers, networks, volumes, and images
#   clean-volumes - Remove all volumes
#
# Utilities:
#   status - Alias for ps
#   health - Check service health
#
# Help:
#   help - Display this help message
# ============================================================================

.PHONY: help
.DEFAULT_GOAL := help

# Colors for output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Environment detection
MODE ?= dev
SERVICE ?= backend
ARGS ?=
PROJECT_ROOT := $(shell pwd)

# Compose file selection
ifeq ($(MODE),prod)
	COMPOSE_FILE = docker/compose.production.yaml
	ENV_MODE = production
else
	COMPOSE_FILE = docker/compose.development.yaml
	ENV_MODE = development
endif

# Docker Compose command
DOCKER_COMPOSE = docker compose -f $(COMPOSE_FILE) --env-file $(PROJECT_ROOT)/.env

# ============================================================================
# Help Target
# ============================================================================
help: ## Display this help message
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║        CUET DevOps Hackathon - Makefile Commands              ║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Main Commands:$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  $(CYAN)%-18s$(NC) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Usage Examples:$(NC)"
	@echo "  make dev-up              # Start development environment"
	@echo "  make prod-up             # Start production environment"
	@echo "  make logs SERVICE=backend MODE=prod"
	@echo "  make shell SERVICE=gateway"
	@echo ""

# ============================================================================
# Core Docker Operations
# ============================================================================
up: ## Start services (MODE=dev|prod, ARGS=additional args)
	@echo "$(GREEN)Starting $(ENV_MODE) services...$(NC)"
	$(DOCKER_COMPOSE) up -d $(ARGS)
	@echo "$(GREEN)✓ Services started successfully!$(NC)"

down: ## Stop services (MODE=dev|prod, ARGS=additional args)
	@echo "$(YELLOW)Stopping $(ENV_MODE) services...$(NC)"
	$(DOCKER_COMPOSE) down $(ARGS)
	@echo "$(GREEN)✓ Services stopped successfully!$(NC)"

build: ## Build containers (MODE=dev|prod)
	@echo "$(GREEN)Building $(ENV_MODE) containers...$(NC)"
	$(DOCKER_COMPOSE) build --no-cache
	@echo "$(GREEN)✓ Build completed successfully!$(NC)"

restart: ## Restart services (MODE=dev|prod)
	@echo "$(YELLOW)Restarting $(ENV_MODE) services...$(NC)"
	$(DOCKER_COMPOSE) restart
	@echo "$(GREEN)✓ Services restarted successfully!$(NC)"

ps: ## Show running containers (MODE=dev|prod)
	@echo "$(CYAN)Running $(ENV_MODE) containers:$(NC)"
	$(DOCKER_COMPOSE) ps

logs: ## View logs (SERVICE=backend|gateway|mongo, MODE=dev|prod)
	@echo "$(CYAN)Viewing logs for $(SERVICE) in $(ENV_MODE) mode...$(NC)"
	$(DOCKER_COMPOSE) logs -f $(SERVICE)

shell: ## Open shell in container (SERVICE=backend|gateway|mongo, MODE=dev|prod)
	@echo "$(CYAN)Opening shell in $(SERVICE) container...$(NC)"
	$(DOCKER_COMPOSE) exec $(SERVICE) /bin/sh

# ============================================================================
# Development Convenience Commands
# ============================================================================
dev: ## Shortcut for dev-up
	@$(MAKE) dev-up

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

dev-shell: ## Open shell in backend container (development)
	@$(MAKE) shell SERVICE=backend MODE=dev

dev-ps: ## Show running development containers
	@$(MAKE) ps MODE=dev

# ============================================================================
# Production Convenience Commands
# ============================================================================
prod-up: ## Start production environment
	@$(MAKE) up MODE=prod ARGS="--build"

prod-down: ## Stop production environment
	@$(MAKE) down MODE=prod

prod-build: ## Build production containers
	@$(MAKE) build MODE=prod

prod-logs: ## View production logs
	@$(MAKE) logs MODE=prod

prod-restart: ## Restart production services
	@$(MAKE) restart MODE=prod

prod-ps: ## Show running production containers
	@$(MAKE) ps MODE=prod

# ============================================================================
# Service-Specific Shell Access
# ============================================================================
backend-shell: ## Open shell in backend container
	@$(MAKE) shell SERVICE=backend

gateway-shell: ## Open shell in gateway container
	@$(MAKE) shell SERVICE=gateway

mongo-shell: ## Open MongoDB shell
	@echo "$(CYAN)Opening MongoDB shell...$(NC)"
	@docker compose -f $(COMPOSE_FILE) exec mongo mongosh -u $${MONGO_INITDB_ROOT_USERNAME} -p $${MONGO_INITDB_ROOT_PASSWORD}

# ============================================================================
# Backend Development Commands
# ============================================================================
backend-build: ## Build backend TypeScript
	@echo "$(GREEN)Building backend TypeScript...$(NC)"
	cd backend && npm run build
	@echo "$(GREEN)✓ Backend build completed!$(NC)"

backend-install: ## Install backend dependencies
	@echo "$(GREEN)Installing backend dependencies...$(NC)"
	cd backend && npm install
	@echo "$(GREEN)✓ Dependencies installed!$(NC)"

backend-type-check: ## Type check backend code
	@echo "$(CYAN)Type checking backend code...$(NC)"
	cd backend && npm run type-check

backend-dev: ## Run backend in development mode (local, not Docker)
	@echo "$(GREEN)Starting backend in development mode...$(NC)"
	cd backend && npm run dev

# ============================================================================
# Database Operations
# ============================================================================
db-reset: ## Reset MongoDB database (WARNING: deletes all data)
	@echo "$(RED)⚠️  WARNING: This will delete all data!$(NC)"
	@echo "$(YELLOW)Press Ctrl+C to cancel, or wait 5 seconds to continue...$(NC)"
	@sleep 5
	@echo "$(YELLOW)Resetting database...$(NC)"
	$(DOCKER_COMPOSE) down -v
	$(DOCKER_COMPOSE) up -d mongo
	@echo "$(GREEN)✓ Database reset completed!$(NC)"

db-backup: ## Backup MongoDB database
	@echo "$(GREEN)Creating database backup...$(NC)"
	@mkdir -p backups
	@docker compose -f $(COMPOSE_FILE) exec -T mongo mongodump \
		--username=$${MONGO_INITDB_ROOT_USERNAME} \
		--password=$${MONGO_INITDB_ROOT_PASSWORD} \
		--authenticationDatabase=admin \
		--archive > backups/backup-$$(date +%Y%m%d-%H%M%S).archive
	@echo "$(GREEN)✓ Backup completed!$(NC)"

# ============================================================================
# Cleanup Commands
# ============================================================================
clean: ## Remove containers and networks (both dev and prod)
	@echo "$(YELLOW)Cleaning up containers and networks...$(NC)"
	docker compose -f docker/compose.development.yaml down
	docker compose -f docker/compose.production.yaml down
	@echo "$(GREEN)✓ Cleanup completed!$(NC)"

clean-all: ## Remove containers, networks, volumes, and images
	@echo "$(RED)⚠️  WARNING: This will remove all containers, networks, volumes, and images!$(NC)"
	@echo "$(YELLOW)Press Ctrl+C to cancel, or wait 5 seconds to continue...$(NC)"
	@sleep 5
	docker compose -f docker/compose.development.yaml down -v --rmi all
	docker compose -f docker/compose.production.yaml down -v --rmi all
	@echo "$(GREEN)✓ Complete cleanup finished!$(NC)"

clean-volumes: ## Remove all volumes
	@echo "$(RED)⚠️  WARNING: This will delete all persistent data!$(NC)"
	@echo "$(YELLOW)Press Ctrl+C to cancel, or wait 5 seconds to continue...$(NC)"
	@sleep 5
	docker compose -f docker/compose.development.yaml down -v
	docker compose -f docker/compose.production.yaml down -v
	@echo "$(GREEN)✓ Volumes removed!$(NC)"

# ============================================================================
# Utility Commands
# ============================================================================
status: ## Alias for ps
	@$(MAKE) ps

health: ## Check service health
	@echo "$(CYAN)Checking service health...$(NC)"
	@$(DOCKER_COMPOSE) ps --format json | jq -r '.[] | "\(.Name): \(.Health)"'

# ============================================================================
# Setup Commands
# ============================================================================
setup: ## Initial setup - create .env if not exists
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)Creating .env file...$(NC)"; \
		echo "MONGO_INITDB_ROOT_USERNAME=admin" > .env; \
		echo "MONGO_INITDB_ROOT_PASSWORD=securepassword123" >> .env; \
		echo "MONGO_URI=mongodb://admin:securepassword123@mongo:27017" >> .env; \
		echo "MONGO_DATABASE=ecommerce" >> .env; \
		echo "BACKEND_PORT=3847" >> .env; \
		echo "BACKEND_URL=http://backend:3847" >> .env; \
		echo "GATEWAY_PORT=5921" >> .env; \
		echo "NODE_ENV=development" >> .env; \
		echo "$(GREEN)✓ .env file created!$(NC)"; \
	else \
		echo "$(YELLOW).env file already exists$(NC)"; \
	fi

# ============================================================================
# Testing Commands
# ============================================================================
test: ## Run tests (if available)
	@echo "$(CYAN)Running tests...$(NC)"
	@echo "$(YELLOW)Tests not implemented yet$(NC)"

# ============================================================================
# Monitoring Commands
# ============================================================================
stats: ## Show container resource usage
	@echo "$(CYAN)Container resource usage:$(NC)"
	@docker stats --no-stream $$(docker compose -f $(COMPOSE_FILE) ps -q)
