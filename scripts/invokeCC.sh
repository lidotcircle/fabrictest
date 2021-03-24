#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/PeerEnvs.sh
source $(dirname ${BASH_SOURCE[0]})/utils.sh

if [ ! $# -ge 3 ]; then
    error 'require at least 3 arguments CHANNEL CHAINCODE MESSAGE ORG PEER PORT'
fi

CHANNEL=$1
CHAINCODE=$2
MESSAGE=$3
ORG=${4:-org1}
PEER=${5:-peerx}
PORT=${6:-8052}

invokeCC() {
    setPeerEnvs $ORG $PEER $PORT
    info "invoke chaincode $CHAINCODE in $CHANNEL"
    peer chaincode invoke \
        -o localhost:8051 \
        --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
        --tls \
        --cafile $OrdererPeer1Cert \
        --channelID $CHANNEL \
        --name $CHAINCODE \
        --peerAddresses localhost:8052 \
        --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.maybe.com/peers/peerx.org1.maybe.com/tls/ca.crt \
        --peerAddresses localhost:8053 \
        --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.maybe.com/peers/peer0.org2.maybe.com/tls/ca.crt \
        -c "$MESSAGE"

    checkCmdExecution $? "invoke chaincode fail"
}

invokeCC

