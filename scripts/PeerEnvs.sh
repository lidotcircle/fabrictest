#!/bin/bash

source $(dirname ${BASH_SOURCE[0]})/utils.sh


setPeerEnvs() {
    local ORG="$1"
    local PEER="$2"
    local PORT="$3"
    info "USING Peer in $ORG.$PEER with local address localhost:$PORT"

    if [ ! $# -eq 3 ] || [ -z "${ORG}" ] || [ -z "${PEER}" ] || [ -z "${PORT}" ]; then
        error "require ORG and PEER be set" >&2
        exit 2
    fi

    export FABRIC_CFG_PATH=$PWD/config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="${ORG^}MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/${ORG}.maybe.com/peers/${PEER}.${ORG}.maybe.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/${ORG}.maybe.com/users/Admin@${ORG}.maybe.com/msp
#    export CORE_PEER_ADDRESS=${PEER}.${ORG}.maybe.com:${PORT}
    export CORE_PEER_ADDRESS=localhost:${PORT}
}


checkCmdExecution() {
    if [ ! $# -ge 1 ] || [ ! $1 -eq 0 ]; then
        error "cmd execution exit with $1"
        if [ -n "$2" ]; then
            error "$2"
        fi
        exit $1
    fi
}


OrdererPeer1Cert=${PWD}/organizations/ordererOrganizations/orderer1.maybe.com/orderers/orderer0.orderer1.maybe.com/msp/tlscacerts/tlsca.orderer1.maybe.com-cert.pem
OrdererPeer2Cert=${PWD}/organizations/ordererOrganizations/orderer2.maybe.com/orderers/orderer0.orderer2.maybe.com/msp/tlscacerts/tlsca.orderer2.maybe.com-cert.pem

