#!/bin/bash

configtxgen -profile TwoPeersChannel \
            -outputCreateChannelTx ./channel-artifacts/channel1.tx \
            -channelID channel1

