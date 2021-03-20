#!/bin/bash

setPeerEnvs() {
    local ORG="$1"
    local PEER="$2"
    local PORT="$3"

    if [ ! $# -eq 3 ] || [ -z "${ORG}" ] || [ -z "${PEER}" ] || [ -z "${PORT}" ]; then
        echo "ERROR: require ORG and PEER be set" >&2
        exit 2
    fi

    export FABRIC_CFG_PATH=$PWD/config/
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_LOCALMSPID="${ORG^}MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/${ORG}.maybe.com/peers/${PEER}.${ORG}.maybe.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/${ORG}.maybe.com/users/Admin@${ORG}.maybe.com/msp
    export CORE_PEER_ADDRESS=${PEER}.${ORG}.maybe.com:${PORT}
}

