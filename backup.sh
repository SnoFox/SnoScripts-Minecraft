#!/bin/bash
WORLDS=(world)
SAVE=5
SERVER_PATH=$(dirname $0)

pushd $SERVER_PATH
source ./_server.sh

actionbar '{"text":"World backup is running...","color":"light_purple"}'

prefix=${1:-custom}
backup() {
  backup_dir="${SERVER_PATH}/backups/${prefix}_$(date +%F_%s)"
  mkdir -p $backup_dir
  rcon 'save-off'
  echo 'Turned off saving'
  sleep 10
  for world in "${WORLDS[@]}"; do
    rsync -a ${SERVER_PATH}/${world} $backup_dir
    status=$?
    if [ $status -ne 0 ]; then
      warnfail $status
    fi
  done
  rcon 'save-on'
  echo 'Turned on saving'
  actionbar '{"text":"World backup finished!","color":"green"}'
  echo "Success! Created $backup_dir"
}

clean() {
  if [ "$prefix" == "custom" ]; then
    return
  fi
  backup_dir="${SERVER_PATH}/backups"
  pushd $backup_dir
  for dir in $(ls -td ${prefix}_*|tail -n +${SAVE}); do
    rm -rf $dir
  done
  popd
}

backup
clean
popd
