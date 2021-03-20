#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/PeerEnvs.sh
setPeerEnvs org1 peerx 8052

peer channel create \
    -o orderer0.orderer1.maybe.com:8051 \
    --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
    -c channel1 \
    -f ./channel-artifacts/channel1.tx \
    --outputBlock ./channel-artifacts/channel1.block \
    --tls \
    --cafile ${PWD}/organizations/ordererOrganizations/orderer1.maybe.com/orderers/orderer0.orderer1.maybe.com/msp/tlscacerts/tlsca.orderer1.maybe.com-cert.pem

