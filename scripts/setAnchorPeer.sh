#!/bin/bash

configtxgen \
    -profile TwoPeersChannel \
    -outputAnchorPeersUpdate ./channel-artifacts/org1_anchors.tx \
    -channelID channel1 \
    -asOrg Org1MSP


if [ ! $? -eq 0 ]; then 
    printf "ERROR: configtxgen fail"
    exit 1; 
fi
source $(dirname ${BASH_SOURCE[0]})/PeerEnvs.sh
setPeerEnvs org1 peerx 8052


peer channel update \
    -o orderer0.orderer1.maybe.com:8051 \
    --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
    -c channel1 \
    -f ./channel-artifacts/org1_anchors.tx \
    --tls \
    --cafile ${PWD}/organizations/ordererOrganizations/orderer1.maybe.com/orderers/orderer0.orderer1.maybe.com/msp/tlscacerts/tlsca.orderer1.maybe.com-cert.pem

