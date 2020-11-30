#!/bin/bash

configtxgen -profile TwoOrdererTwoPeerGenesis \
            -channelID system-channel \
            -outputBlock ./system-genesis-block/genesis.block

