#!/usr/bin/make

SHELL = /bin/sh

UID := $(shell id -u)
GID := $(shell id -g)
USER:= $(shell whoami)

export UID
export GID
export USER

# docker-compose down --rmi all --remove-orphans && docker-compose up --force-recreate
up:
	docker-compose up -d	
	