#!/bin/bash

configtxgen -profile TwoPeersGenesis \
            -channelID system-channel \
            -outputBlock ./system-genesis-block/genesis.block

