#!/bin/bash

configtxgen -profile TwoPeerGenesis \
            -channelID system-channel \
            -outputBlock ./system-genesis-block/genesis.block

