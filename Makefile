#!/usr/bin/make -f

SRC_PATH:=src
DOCKER_NAME:=pyarchetype

# Do not modify these variables:
PWD := $(shell pwd)
OLD_TAG := v$(shell cat VERSION)
ENV_RUNNING := $(shell docker-compose -f Dockerfiles/docker-compose-dev.yml ps | grep Exit | wc -l | tr -d '[[:space:]]')
ES_HOSTNAME := $(shell docker-compose -f Dockerfiles/docker-compose-dev.yml ps | grep elasticsearch | cut -d' ' -f 1)

run: checkenv checkargs
	docker build -f Dockerfiles/Dockerfile -t $(DOCKER_NAME):local .
	docker run --rm \
			--link $(ES_HOSTNAME):elasticsearch \
			$(DOCKER_NAME):local \
			$(args)

startenv:
	docker-compose -f Dockerfiles/docker-compose-dev.yml up -d

killenv:
	docker-compose -f Dockerfiles/docker-compose-dev.yml kill
	docker-compose -f Dockerfiles/docker-compose-dev.yml rm -f

checkargs:
ifndef args
	$(error 'args' is not set)
endif

checkenv:
ifneq ($(ENV_RUNNING),0)
	$(error No docker environment is running)
endif

checkpart:
ifndef part
	$(error 'part' is not set)
endif

release: checkpart 
	sh make_release.sh $(part)
	
clean:
	# nothing to do yet	
	
.PHONY: startenv killenv checkenv checkscript checkargs package run release clean
