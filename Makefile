# SHELL=/bin/bash -o pipefail
# SHELL = /bin/bash

.ONESHELL:
.SHELL := /bin/bash

BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

CURRENT_DIR = $$(pwd)
UNAME := $(shell uname)
BUILD_DATE := $(shell date +%Y%m%d-%H%M)
VERSION_FILE=./VERSION

ifneq (,$(wildcard .env))
	include .env
	export $(shell sed 's/=.*//' .env)
	# export
endif

TARGETS := $(shell ls scripts | grep -vE 'clean|dev|run|help|release*|build-moby|run-moby')

#help: .checker
help:
	@echo "\n$(GREEN)Available commands$(RESET)"
	@echo "---------------------------------------------------------------------"
	@grep -h -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "----------------------------------------------------------------------------"
	@#echo "GOPATH: ${GOPATH}"

.checker:
ifeq ($(shell test -e $(VERSION_FILE) && echo -n yes),yes)
	@$(eval VERSION=$(shell cat $(VERSION_FILE)))
else
	@echo File $(VERSION_FILE) does not exist
	@exit 0;
endif

build: ## Build command
	@echo "start build"

.dapper:
	@echo Downloading dapper
	@curl -sL https://releases.rancher.com/dapper/latest/dapper-`uname -s`-`uname -m` > .dapper.tmp
	@@chmod +x .dapper.tmp
	@./.dapper.tmp -v
	@mv .dapper.tmp .dapper

$(TARGETS): .dapper
	@rm -rf ./dist ./build
	./.dapper $@

.DEFAULT_GOAL := default

.PHONY: $(TARGETS)
# .PHONY: help info run-live packer-proxmox $(TARGETS)