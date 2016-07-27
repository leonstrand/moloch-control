#!/bin/bash

# leon.strand@medeanalytics.com


source=/data/moloch
destination=~/tmp

echo $0: source: $source #verbose
echo $0: destination: $destination #verbose

for directory in $source/*; do
  echo #verbose
  echo $0: directory: $directory #verbose
  base=$(basename $directory)
  case $base in
    bin|db|elastic*|etc|include|lib|parsers|plugins|share|viewer|wiseService)
      echo $0: copying #verbose
      cp -r $directory $destination
    ;;
    #data|logs|raw)
    *)
      echo $0: only making directory #verbose
      mkdir -vp $destination/$base
    ;;
  esac
done

cd $destination
echo $0: time tar czf ~/moloch.tgz . #verbose
time tar czf ~/moloch.tgz .
