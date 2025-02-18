#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/PeerEnvs.sh
source $(dirname ${BASH_SOURCE[0]})/utils.sh


NAME=basic
CHANNEL=channel1
if [ $# -ge 1 ]; then
    NAME=$1
fi

if [ $# -ge 2 ]; then
    CHANNEL=$2
fi

if [ $# -gt 2 ]; then
    error "require 0 to 2 command line arguments, but gets $#"
    exit 2
fi
LANGUAGE=
SEQUENCE=
CCVERSION=

if [ -e $PWD/chaincode/$NAME/package.json ]; then
    LANGUAGE=node
elif [ -e $PWD/chaincode/$NAME/go.mod ]; then
    LANGUAGE=golang
else
    error "invalid chaincode"
    exit 2
fi

setPeerEnvs org1 peerx 8052
SEQUENCE=$(\
    peer lifecycle chaincode querycommitted -C $CHANNEL |\
    grep -se "Name: $NAME," |\
    sed -e "s/^.*Sequence: \([[:digit:]]\+\),.*$/\1/g")
[ -n "$SEQUENCE" ] && SEQUENCE=$[${SEQUENCE}+1] || SEQUENCE=1

if [ -z "$CCVERSION" ]; then
    CCVERSION=${SEQUENCE}.0
fi
LABEL=${NAME}_${CCVERSION}
info "installing chaincode $LABEL into $CHANNEL with sequence $SEQUENCE"


packChaincode() {
    if [ ! -d $PWD/ccpackage ]; then
        mkdir $PWD/ccpackage
        checkCmdExecution $?
    fi

    if [ "$LANGUAGE" == "node" ]; then
        pushd $PWD/chaincode/$NAME && tsc && popd
        checkCmdExecution $?
    fi

    if [ ! -d $PWD/chaincode/$NAME ]; then
        error "can't find chaincode in $PWD/chaincode/$NAME"
        exit 1
    fi

    info "packaging chaincode $NAME"
    peer lifecycle chaincode package \
        $PWD/ccpackage/$NAME.tar.gz \
        --path $PWD/chaincode/$NAME \
        --lang $LANGUAGE \
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
        error 'require one argument'
        exit 2
    fi

    PACKAGE_ID=${LABEL}:$1
    info "approve ${PACKAGE_ID}"
    peer lifecycle chaincode approveformyorg \
        -o localhost:8051 \
        --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
        --tls \
        --cafile $OrdererPeer1Cert \
        --channelID $CHANNEL \
        --name $NAME \
        --version $CCVERSION \
        --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE} \

    checkCmdExecution $? 'approveformyorg fail'

    peer lifecycle chaincode checkcommitreadiness \
        --channelID $CHANNEL \
        --name $NAME \
        --version $CCVERSION \
        --sequence ${SEQUENCE} \
        --output json
    checkCmdExecution $? 'check commit readiness fail'
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

    info "committing chaincode $NAME in $CHANNEL"
    peer lifecycle chaincode commit \
        -o localhost:8051 \
        --ordererTLSHostnameOverride orderer0.orderer1.maybe.com \
        --tls \
        --cafile $OrdererPeer1Cert \
        --channelID $CHANNEL \
        --name $NAME \
        --version $CCVERSION \
        --sequence ${SEQUENCE} \
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

PackageIdHash=$(\
    peer lifecycle chaincode queryinstalled |\
    grep -se '^Package ID:.*$' |\
    grep -se " ${LABEL}:" |\
    grep -soe '[a-z0-9]\{16,\}')

approveByOrg1 "$PackageIdHash"
approveByOrg2 "$PackageIdHash"

commitChaincode

