HOST='mc.example.com'
PASS='s00perp4ss'
RCON="/home/mc/bin/mcrcon -s -p $PASS -H $HOST "
spinner=''
_repeattext() {
  while true; do
    rcon "title @a actionbar $@"
    sleep 2
  done
}

rcon() {
  $RCON "$@"
}

actionbar() {
  if [ "x$spinner" != "x" ]; then
    kill $spinner
  fi
  _repeattext "$@" &
  spinner=$!
}

subtitle() {
  time=$(shift)
  rcon "title @a subtitle $@"
}


title() {
  time=$1
  shift
  rcon "title @a times 20 $time 20"
  rcon "title @a title $@"
}

cleanup() {
  if [ "x$spinner" != "x" ]; then
    sleep 1
    kill $spinner 2> /dev/null
  fi
}

warnfail() {
  status=$1
  actionbar '{"text":"Server backup failed! Backup command exited '${status}'! Go find SnoFox","color":"red"}' &
  echo "Failed!"
  sleep 3600
  exit 1
}

pushd() {
  builtin pushd "$@" > /dev/null
}

popd() {
  builtin popd "$@" > /dev/null
}

start() {
  if is_running; then
    echo "Server already running"
    exit 1
  fi
  # https://howtodoinjava.com/java/garbage-collection/all-garbage-collection-algorithms/#g1-gc
  #-Dsun.rmi.dgc.server.gcInterval=2147483646 \
    #-XX:G1MaxNewSizePercent=50 \ # percentage, lower than default
    #-XX:+PrintGCDetails \
  exec java -d64 \
    -XX:+UseG1GC \
    -XX:+UnlockExperimentalVMOptions \
    -XX:G1ReservePercent=20 \
    -XX:GCPauseIntervalMillis=1000 \
    -XX:MaxGCPauseMillis=500 \
    -XX:GCHeapFreeLimit=20 \
    -XX:GCTimeLimit=60 \
    -XX:G1HeapRegionSize=4M \
    -XX:ParallelGCThreads=8 \
    -XX:G1MixedGCLiveThresholdPercent=60 \
    -Xmx8G \
    -Xms8G \
    -verbose:gc \
    -XX:+PrintTenuringDistribution \
    -jar server.jar > logs/stdout.log 2> logs/stderr.log &
  echo $! > server.pid
  echo "It's up; PID $(cat server.pid)"
}

comment() {
  exit
    -XX:+UseConcMarkSweepGC \
    -XX:+UseParNewGC \
    -XX:ParallelGCThreads=8 \
    -XX:+CMSParallelRemarkEnabled \
    -XX:+DisableExplicitGC \
    -XX:MaxGCPauseMillis=500 \
    -XX:SurvivorRatio=16 \
    -XX:TargetSurvivorRatio=90 \
    noop
}

quickstop() {
  if ! is_running; then
    echo "Server isn't running"
    exit 2
  fi
  really_stop
}

intstop() {
  echo "Caught SIGINT, exiting faster"
  quickstop
  if [ $command == "restart" ]; then
    start
  fi
  exit
}

stop() {
  if ! is_running; then
    echo "Server isn't running"
    exit 2
  fi
  let countdown=5
  echo "Waiting for ${countdown} minutes..."
  trap intstop SIGINT
  while [ $countdown -gt 0 ]; do
    actionbar '{"text":"Server restarting in '${countdown}'min! Get safe!"}'
    let countdown--
    sleep 60
    echo -n .
  done
  really_stop
}

really_stop() {
  subtitle '{"text":"Come back in a few minutes"}'
  title 100 '{"text":"- Server Restarting -"}'
  sleep 3
  rcon 'kick @a Server restarting...'
  rcon stop
  echo "Stopping server"
  while is_running; do
    echo -n "."
    sleep 1
  done
  rm server.pid
  echo
  echo "Server stopped"
}

is_running() {
  if [ ! -f server.pid ]; then
    return 1
  else
    return $(kill -0 $(cat server.pid) 2> /dev/null)
  fi
}
trap cleanup EXIT SIGINT SIGTERM
