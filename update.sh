#!/bin/bash
SERVER_PATH=$(dirname $0)
VERSION=$1
URL=$2

cd $SERVER_PATH
source ./_server.sh
wget -O server-${VERSION}.jar $URL
status=$?
if [ $status -ne 0 ]; then
  echo "Download failed. Aborting"
  exit 1
fi
./backup.sh upgrade
sleep 1
actionbar "Server going down for an upgrade"
sleep 2
quickstop
rm server.jar && ln -s server-${VERSION}.jar server.jar
start
