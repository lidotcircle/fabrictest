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

queryCC() {
    setPeerEnvs $ORG $PEER $PORT
    info "query chaincode $CHAINCODE in $CHANNEL"
    peer chaincode query \
        --channelID $CHANNEL \
        --name $CHAINCODE \
        -c "$MESSAGE"

    checkCmdExecution $? "query chaincode fail"
}

queryCC

