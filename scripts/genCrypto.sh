#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/utils.sh

info "generate crypto stuff"
cryptogen generate \
    --config=config/crypto-config.yaml \
    --output=organizations

