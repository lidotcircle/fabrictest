#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/utils.sh

info "generate genesis block for network"
configtxgen -profile TwoPeersGenesis \
            -configPath $PWD/config \
            -channelID system-channel \
            -outputBlock ./system-genesis-block/genesis.block

