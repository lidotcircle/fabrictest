#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/PeerEnvs.sh

invokeCC() {
    peer chaincode invoke \
        -o orderer0.orderer1.maybe.com:8051 \
        --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
        --tls \
        --cafile $OrdererPeer1Cert \
        --channelID channel1 \
        --name basic \
        --peerAddresses peerx.org1.maybe.com:8052 \
        --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.maybe.com/peers/peerx.org1.maybe.com/tls/ca.crt \
        --peerAddresses peer0.org2.maybe.com:8053 \
        --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.maybe.com/peers/peer0.org2.maybe.com/tls/ca.crt \
        -c '{"function":"InitLedger","Args":[]}'

    checkCmdExecution $? "invoke chaincode fail"
}

queryCC() {
    setPeerEnvs org1 peerx 8052
    peer chaincode invoke \
        --channelID channel1 \
        --name basic-go \
        -c '{"Args":["GetAllAssets"]}'

    checkCmdExecution $? "query chaincode fail"
}


# queryCC
invokeCC

