#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/utils.sh

info "removing crypto stuff"
rm -fr ./organizations
rm -fr ./system-genesis-block
rm -fr ./channel-artifacts

info "cleaning docker containers and volumes"
docker-compose down
docker-compose rm
docker volume prune -f

