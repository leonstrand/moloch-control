#!/bin/bash

# leon.strand@medeanalytics.com


execute() {
  case "$1" in
    n) shift;;
    *) echo;; #verbose
  esac
  __command="$@"
  echo $__command #verbose
  eval $__command
}

pids=''
if [ -n "$1" ]; then
  components="$@"
  for component in $components; do
    case $component in
      elasticsearch|viewer|capture) ;;
      es|e) component='elasticsearch';;
      v)    component='viewer';;
      c)    component='capture';;
      *)    echo #verbose
            echo $0: warning: component $component unrecogized, skipping #verbose
            continue
      ;;
    esac
    echo #verbose
    echo $0: getting pid of moloch component $component #verbose
    pids=$pids' '$(ps -Fu daemon | grep -v UID | grep $component | awk '{print $2}')
  done
  pids=$(echo $pids | sed 's/ $//')
else
  pids=$(ps -Fu daemon | grep -v UID | awk '{print $2}')
fi

if [ -n "$pids" ]; then
  for pid in $pids; do
    command='sudo kill '$pid
    echo $command #verbose
    eval $command
  done
  sleep 1
else
  echo #verbose
  echo $0: no moloch process to kill #verbose
fi

echo #verbose
echo ps -Fu daemon #verbose
ps -Fu daemon
echo #verbose
