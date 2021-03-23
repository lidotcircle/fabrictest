#!/bin/bash

source $PWD/scripts/PeerEnvs.sh

$PWD/scripts/cleanDir.sh
checkCmdExecution $?
$PWD/scripts/genCrypto.sh
checkCmdExecution $?
$PWD/scripts/genGenesisBlock.sh
checkCmdExecution $?
$PWD/scripts/createTwoPeersChannelTxFile.sh
checkCmdExecution $?
docker-compose up -d
checkCmdExecution $?
sleep 10

$PWD/scripts/createTwoPeersChannel.sh
checkCmdExecution $?
$PWD/scripts/joinToChannal.sh org1 peerx 8052
checkCmdExecution $?
$PWD/scripts/joinToChannal.sh org2 peer0 8053
checkCmdExecution $?
$PWD/scripts/setAnchorPeer.sh org1 peerx 8052
checkCmdExecution $?
$PWD/scripts/setAnchorPeer.sh org2 peer0 8053
checkCmdExecution $?
$PWD/scripts/deployChaincode.sh basic-go
checkCmdExecution $?

