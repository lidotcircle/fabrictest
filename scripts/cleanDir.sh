#!/bin/bash

rm -r ./organizations
rm -r ./system-genesis-block
rm -r ./channel-artifacts

docker-compose down
docker-compose rm
docker volume prune -f

