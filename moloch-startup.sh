#!/bin/bash

# leon.strand@medeanalytics.com


if [ $(id -u) -ne 0 ]; then
  echo $0: error: must be run with elevated privileges, e.g. as root, with sudo, etc #verbose
  exit 1
fi

execute() {
  case "$1" in
    n) shift;;
    *) echo;; #verbose
  esac
  __command="$@"
  echo $__command #verbose
  eval $__command
}


directory=/data/moloch/bin

components='
elasticsearch
viewer
capture
'


if [ -f $(pwd)/nohup.out ]; then
  echo #debug
  echo sudo lsof $(pwd)/nohup.out 2\>/dev/null #debug
  sudo lsof $(pwd)/nohup.out 2>/dev/null #debug
  if ! sudo lsof $(pwd)/nohup.out 2>/dev/null; then
    echo #verbose
    echo $0: $(pwd)/nohup.out present but not open
    echo sudo rm -v nohup.out #verbose
    sudo rm -v nohup.out
  fi
fi

for component in $components; do
  echo #verbose
  echo #verbose
  echo component: $component #verbose
  case $component in
    elasticsearch)
      if ps -Fu daemon | grep -q java; then
        echo $0: $component already running #verbose 
        echo ps -F \| head -1\; ps -Fu daemon \| grep java #verbose
        ps -F | head -1
        ps -Fu daemon | grep java
      else
        echo $0: $component not already running, starting... #verbose 
        server=$directory/run_es.sh
        command='time nohup '$server
        execute $command
        sleep 1
        command='cat nohup.out'
        execute $command
        command='ps -Fu daemon | grep java'
        execute $command
        #command='curl -sS http://127.0.0.1:9200/_cluster/health?pretty'
        #execute $command
        echo #verbose
        until curl -sS http://127.0.0.1:9200/_cluster/health?pretty; do
          echo $0: elasticsearch cluster not up yet #verbose
          sleep 1
        done
      fi
    ;;
    viewer|capture)
      if ps -Fu daemon | grep -q $component; then
        echo $0: $component already running #verbose 
        echo ps -F \| head -1\; ps -Fu daemon \| grep $component #verbose
        ps -F | head -1
        ps -Fu daemon | grep $component
      else 
        echo $0: $component not already running, starting... #verbose 
        server=$directory/run_$component.sh
        echo time nohup $server \& #verbose
        time nohup $server &
        sleep 1
        command='cat nohup.out'
        execute $command
        echo #verbose
        echo ps -F \| head -1\; ps -Fu daemon \| grep $component #verbose
        ps -F | head -1
        until ps -Fu daemon | grep $component; do
          :
        done
      fi
    ;;
  esac
  #echo $0: server: $server #debug
  #ls -alh $server #debug
done

sleep 1
echo #verbose
echo #verbose
echo netstat -lntp \| egrep \'Active\|Proto\|8005\|9200\|9300\' #verbose
netstat -lntp | egrep 'Active|Proto|8005|9200|9300'
echo #verbose
echo ps -Fu daemon
ps -Fu daemon

echo #verbose
