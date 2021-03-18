#!/bin/bash

export FABRIC_CFG_PATH=$PWD/config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.maybe.com/peers/peerx.org1.maybe.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.maybe.com/users/Admin@org1.maybe.com/msp
export CORE_PEER_ADDRESS=peerx.org1.maybe.com:8052

peer channel create \
    -o orderer0.orderer1.maybe.com:8051 \
    --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
    -c channel1 \
    -f ./channel-artifacts/channel1.tx \
    --outputBlock ./channel-artifacts/channel1.block \
    --tls \
    --cafile ${PWD}/organizations/ordererOrganizations/orderer1.maybe.com/orderers/orderer0.orderer1.maybe.com/msp/tlscacerts/tlsca.orderer1.maybe.com-cert.pem

