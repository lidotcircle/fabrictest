#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/utils.sh


ORG=org1
PEER=peerx
PORT=8052
CHANNEL=channel1

if [ $# -eq 3 ]; then
    ORG=$1
    PEER=$2
    PORT=$3
elif [ ! $# -eq 0 ]; then
    error "require zero or three command line arguments"
    exit 1
fi

source $(dirname ${BASH_SOURCE[0]})/PeerEnvs.sh
setPeerEnvs $ORG $PEER $PORT

info "join $PEER.$ORG to $CHANNEL"
peer channel join \
    -b ./channel-artifacts/${CHANNEL}.block \
    -o localhost:8051 \
    --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
    --tls \
    --cafile $OrdererPeer1Cert

