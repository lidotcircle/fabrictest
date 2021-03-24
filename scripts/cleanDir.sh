#!/bin/bash

rm -fr ./organizations
rm -fr ./system-genesis-block
rm -fr ./channel-artifacts

docker-compose down
docker-compose rm
docker volume prune -f

