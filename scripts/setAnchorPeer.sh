#!/bin/bash

ORG=${1:-"org1"}
PEER=${2:-"peerx"}
PORT=${3:-"8052"}
CHANNEL=${4:-"channel1"}
ORGMSP=${ORG^}MSP

source $(dirname ${BASH_SOURCE[0]})/PeerEnvs.sh

setPeerEnvs $ORG $PEER $PORT
configtxgen \
    -profile TwoPeersChannel \
    --configPath $PWD \
    -outputAnchorPeersUpdate ./channel-artifacts/${ORG}_${CHANNEL}_anchors.tx \
    -channelID $CHANNEL \
    -asOrg $ORGMSP
checkCmdExecution $?


peer channel update \
    -o localhost:8051 \
    --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
    -c $CHANNEL \
    -f ./channel-artifacts/${ORG}_${CHANNEL}_anchors.tx \
    --tls \
    --cafile ${PWD}/organizations/ordererOrganizations/orderer1.maybe.com/orderers/orderer0.orderer1.maybe.com/msp/tlscacerts/tlsca.orderer1.maybe.com-cert.pem
checkCmdExecution $?

