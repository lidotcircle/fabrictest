#!/bin/bash

configtxgen -profile TwoPeersGenesis \
            -configPath $PWD \
            -channelID system-channel \
            -outputBlock ./system-genesis-block/genesis.block

