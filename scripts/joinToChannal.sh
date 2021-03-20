#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/PeerEnvs.sh
setPeerEnvs org1 peerx 8052

peer channel join \
    -b ./channel-artifacts/channel1.block \
    -o orderer0.orderer1.maybe.com:8051 \
    --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
    --tls \
    --cafile ${PWD}/organizations/ordererOrganizations/orderer1.maybe.com/orderers/orderer0.orderer1.maybe.com/msp/tlscacerts/tlsca.orderer1.maybe.com-cert.pem

