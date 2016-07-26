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

interface='eth0'
if ! dpkg -l | grep -q ethtool; then
  command='time apt-get -y install ethtool'
  execute $command
fi
echo #verbose
echo $0: checking for network interface features for $interface in /etc/rc.local recommended by moloch #verbose
if grep '^\s*ethtool\s*-K\s*eth0\s*tx\s*off\s*sg\s*off\s*gro\s*off\s*gso\s*off\s*lro\s*off\s*tso\s*off\s*$' /etc/rc.local; then
  echo $0: already present #verbose
else
  echo $0: not already present, setting... #verbose
  echo \(echo\; echo \'ethtool -K eth0 tx off sg off gro off gso off lro off tso off\'\) \| tee -a /etc/rc.local
  (echo; echo 'ethtool -K eth0 tx off sg off gro off gso off lro off tso off') | tee -a /etc/rc.local
fi
echo #verbose
echo $0: setting execute mode for all classes on /etc/rc.local #verbose
command='chmod -v a+x /etc/rc.local'
execute n $command
echo #verbose
echo $0: setting network interface features for $interface in /etc/rc.local recommended by moloch in current session #verbose
command='ethtool -k $interface >/tmp/ethtool1'
execute n $command
command='ethtool -K eth0 tx off sg off gro off gso off lro off tso off'
execute n $command
command='ethtool -k $interface >/tmp/ethtool2'
execute n $command
command='diff /tmp/ethtool1 /tmp/ethtool2'
execute n $command

if ! dpkg -l | grep -q software-properties-common; then
  command='time apt-get -y install software-properties-common'
  execute $command
fi
if ! dpkg -l | grep -q oracle-java8-installer; then
  command='echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections -v'
  execute $command
  command='time add-apt-repository -y ppa:webupd8team/java'
  execute $command
  command='time apt-get update'
  execute $command
  command='time apt-get -y install oracle-java8-installer'
  execute $command
fi

command='time apt-get -y install python'
execute $command

if [ -d ~/moloch ]; then
  echo #verbose
  echo $0: detected existing moloch directory, removing #verbose
  command='time rm -rf ~/moloch'
  execute $command
fi
command='cd ~'
execute $command
command='time git clone https://github.com/leonstrand/moloch'
execute $command
command='cd ~/moloch'
execute $command
command='time ./easybutton-singlehost.sh'
execute $command

config=/data/moloch/etc/config.ini
if [ -f $config ]; then
  echo $0: checking for readTruncatedPackets in $config #verbose
  if grep -q '^\s*readTruncatedPackets\s*=\s*true\s*$' $config; then
    echo $0: already present #verbose
  else
    echo $0: adding #verbose
    (echo; echo 'readTruncatedPackets = true') | tee -a $config
  fi
  command='grep -C5 readTruncatedPackets '$config
  execute  $command
else
  echo $0: error $config does not exist
  exit 1
fi
