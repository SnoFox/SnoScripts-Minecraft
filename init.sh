#!/bin/bash
# exit codes
# 0 = success
# 1 = server already running
# 2 = server not running
SERVER_PATH=$(dirname $0)
source ${SERVER_PATH}/_server.sh

status() {
  if [ -f server.pid ]; then
    if is_running; then
      echo "Server is running as $(cat server.pid)"
    else
      echo "Server not running; dead pidfile exists"
      exit 2
    fi
  else
    echo "Server is not running"
    exit 2
  fi
}

usage() {
  echo "Usage: $0 <start|restart|stop|quickstop|quickrestart|status>"
}

pushd $SERVER_PATH
command=$1
case $1 in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  quickrestart)
    quickstop
    start
    ;;
  quickstop)
    quickstop
    ;;
  status)
    status
    ;;
  *)
    usage
esac
popd
