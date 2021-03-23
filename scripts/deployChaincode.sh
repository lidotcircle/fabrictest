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

    if [ -e $PWD/chaincode/$NAME/package.json ]; then
        pushd $PWD/chaincode/$NAME && tsc && popd
        checkCmdExecution $?
    fi

    if [ ! -d $PWD/chaincode/$NAME ]; then
        echo "ERROR: can't find chaincode in $PWD/chaincode/$NAME"
        exit 1
    fi

    peer lifecycle chaincode package \
        $PWD/ccpackage/$NAME.tar.gz \
        --path $PWD/chaincode/$NAME \
        --lang golang \
        --label $LABEL
    checkCmdExecution $?
}

installChaincodeInOrg1() {
    setPeerEnvs org1 peerx 8052
    peer lifecycle chaincode install $PWD/ccpackage/$NAME.tar.gz
    checkCmdExecution $? 'org1-peerx install fail'
    peer lifecycle chaincode queryinstalled
    checkCmdExecution $? 'org1-peerx query install fail'
}

installChaincodeInOrg2() {
    setPeerEnvs org2 peer0 8053
    peer lifecycle chaincode install $PWD/ccpackage/$NAME.tar.gz
    checkCmdExecution $? 'org2-peer0 install fail'
    peer lifecycle chaincode queryinstalled
    checkCmdExecution $? 'org2-peer0 query install fail'
}

approveByEnvs() {
    if [ ! $# -eq 1 ]; then
        echo 'ERROR: require one argument'
        exit 2
    fi

    PACKAGE_ID=$1
    peer lifecycle chaincode approveformyorg \
        -o localhost:8051 \
        --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
        --tls \
        --cafile $OrdererPeer1Cert \
        --channelID $CHANNEL \
        --name $NAME \
        --version $CCVERSION \
        --package-id ${NAME}_${CCVERSION}:${PACKAGE_ID} \
        --sequence 1 \
#        --signature-policy "AND('Org1MSP.peer', 'Org2MSP.peer')" \

    checkCmdExecution $? 'approveformyorg fail'
}

approveByOrg1() {
    setPeerEnvs org1 peerx 8052
    approveByEnvs $1
}

approveByOrg2() {
    setPeerEnvs org2 peer0 8053
    approveByEnvs $1
}

commitChaincode() {
    setPeerEnvs org1 peerx 8052

    echo "committing chaincode $NAME"
    peer lifecycle chaincode commit \
        -o localhost:8051 \
        --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
        --tls \
        --cafile $OrdererPeer1Cert \
        --channelID $CHANNEL \
        --name $NAME \
        --version $CCVERSION \
        --sequence 1 \
        --peerAddresses localhost:8052 \
        --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.maybe.com/peers/peerx.org1.maybe.com/tls/ca.crt \
        --peerAddresses localhost:8053 \
        --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.maybe.com/peers/peer0.org2.maybe.com/tls/ca.crt

    checkCmdExecution $? "fail to commit chaincode ${NAME}"

    peer lifecycle chaincode querycommitted \
        --channelID $CHANNEL
}

setPeerEnvs org2 peer0 8053
packChaincode
installChaincodeInOrg1
installChaincodeInOrg2

PackageId=$(\
    peer lifecycle chaincode queryinstalled |\
    grep -se '^Package ID:.*$' |\
    tail -n 1 |\
    grep -soe '[a-z0-9]\{16,\}')

approveByOrg1 "$PackageId"
approveByOrg2 "$PackageId"

commitChaincode

