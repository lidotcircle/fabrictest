#!/bin/bash

NAME=c1
CHANNEL=channel1
CCVERSION=1.0
if [ $# -ge 1 ]; then
    NAME=$1
fi

if [ $# -ge 2 ]; then
    CHANNEL=$2
fi

if [ $# -gt 2 ]; then
    echo "ERROR: require 0 to 2 command line arguments, but gets $#"
    exit 2
fi
LABEL=cc_${NAME}_${CCVERSION}

source $(dirname ${BASH_SOURCE[0]})/PeerEnvs.sh

packChaincode() {
    if [ ! -d $PWD/ccpackage ]; then
        mkdir $PWD/ccpackage
        checkCmdExecution $?
    fi
    pushd $PWD/chaincode/$NAME && tsc && popd
    checkCmdExecution $?

    if [ ! -d $PWD/chaincode/$NAME ]; then
        echo "ERROR: can't find chaincode in $PWD/chaincode/$NAME"
        exit 1
    fi

    peer lifecycle chaincode package \
        $PWD/ccpackage/$NAME.tar.gz \
        --path $PWD/chaincode/$NAME \
        --lang node \
        --label $LABEL
    checkCmdExecution $?
}

installChaincodeInOrg1() {
    setPeerEnvs org1 peerx 8052
    peer lifecycle chaincode install $PWD/ccpackage/$NAME.tar.gz
    checkCmdExecution $?
}

installChaincodeInOrg2() {
    setPeerEnvs org2 peer0 8053
    peer lifecycle chaincode install $PWD/ccpackage/$NAME.tar.gz
    checkCmdExecution $?
}

approveByEnvs() {
    peer lifecycle chaincode approveformyorg \
        -o orderer0.orderer1.maybe.com:8051 \
        --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
        --tls \
        --cafile $OrdererPeer1Cert \
        --channelID $CHANNEL \
        --name $NAME \
        --version $CCVERSION \
        --package-id ${NAME}_${CCVERSION}:${PackageId} \
        --sequence 1 \
#        --signature-policy "AND('Org1MSP.peer', 'Org2MSP.peer')" \

    checkCmdExecution $?
}

approveByOrg1() {
    setPeerEnvs org1 peerx 8052
    approveByEnvs
}

approveByOrg2() {
    setPeerEnvs org2 peer0 8053
    approveByEnvs
}


setPeerEnvs org2 peer0 8053
PackageId=$(\
    peer lifecycle chaincode queryinstalled |\
    grep -se '^Package ID:.*$' |\
    tail -n 1 |\
    grep -soe '[a-z0-9]\{16,\}')


# packChaincode
# installChaincodeInOrg1
# installChaincodeInOrg2
approveByOrg1
approveByOrg2

