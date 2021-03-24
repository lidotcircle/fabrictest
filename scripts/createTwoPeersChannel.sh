#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/PeerEnvs.sh
source $(dirname ${BASH_SOURCE[0]})/utils.sh
setPeerEnvs org1 peerx 8052

CHANNEL=${1:-channel1}

info 'creating channel '
peer channel create \
    -o localhost:8051 \
    --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
    -c ${CHANNEL} \
    -f ./channel-artifacts/${CHANNEL}.tx \
    --outputBlock ./channel-artifacts/${CHANNEL}.block \
    --tls \
    --cafile ${PWD}/organizations/ordererOrganizations/orderer1.maybe.com/orderers/orderer0.orderer1.maybe.com/msp/tlscacerts/tlsca.orderer1.maybe.com-cert.pem

