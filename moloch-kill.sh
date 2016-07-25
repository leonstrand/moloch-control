#!/bin/bash

# leon.strand@medeanalytics.com


echo #verbose
if ps -Fu daemon | grep -qv UID; then
  echo $0: killing moloch... #verbose
  echo #verbose
  ps -Fu daemon
  echo #verbose
  for pid in $(ps -Fu daemon | grep -v UID | awk '{print $2}'); do
    command='sudo kill '$pid
    echo $command #verbose
    eval $command
  done
  sleep 1
else
  echo $0: no moloch process to kill #verbose
fi
echo #verbose
echo ps -Fu daemon #verbose
ps -Fu daemon
echo #verbose
