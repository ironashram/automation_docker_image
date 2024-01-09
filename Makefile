NAME   := quay.io/m1k_cloud/automation_docker_image
TAG    := latest
IMG    := ${NAME}:${TAG}

.PHONY: help
help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v @fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: all
all: login build push  ## Builds docker image and pushes it into the repo. Usage: make all

.PHONY: build
build: ## Builds docker image. Usage: make build
	@docker build \
		--rm \
		--no-cache \
		--tag ${IMG} \
		.

.PHONY: debug
debug: build ##build and run locally
	@docker run -it ${NAME}:${TAG} bash

.PHONY: login
login: ##logins you into your account
	@docker login quay.io

.PHONY: push
push: ##Pushes the image to the repository
	@docker push ${IMG}

%:
	@:
