#!/bin/bash

ORG=org1
PEER=peerx
PORT=8052
CHANNEL=channel1

if [ $# -eq 3 ]; then
    ORG=$1
    PEER=$2
    PORT=$3
elif [ ! $# -eq 0 ]; then
    echo "ERROR: require zero or three command line arguments"
    exit 1
fi

source $(dirname ${BASH_SOURCE[0]})/PeerEnvs.sh
setPeerEnvs $ORG $PEER $PORT

peer channel join \
    -b ./channel-artifacts/${CHANNEL}.block \
    -o orderer0.orderer1.maybe.com:8051 \
    --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
    --tls \
    --cafile $OrdererPeer1Cert

