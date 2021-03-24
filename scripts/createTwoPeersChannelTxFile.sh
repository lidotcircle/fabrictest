#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/utils.sh

PROFILE=${1:-TwoPeersChannel}
CHANNEL=${2:-channel1}

info "generate transaction for creating channel $CHANNEL with profile $PROFILE"
configtxgen -profile $PROFILE \
            -configPath $PWD/config \
            -outputCreateChannelTx ./channel-artifacts/$CHANNEL.tx \
            -channelID $CHANNEL

