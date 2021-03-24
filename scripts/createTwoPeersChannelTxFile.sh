#!/bin/bash

configtxgen -profile TwoPeersChannel \
            -configPath $PWD \
            -outputCreateChannelTx ./channel-artifacts/channel1.tx \
            -channelID channel1

