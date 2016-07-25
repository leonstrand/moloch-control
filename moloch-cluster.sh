#!/bin/bash

# leon.strand@medeanalytics.com


until curl -sS http://127.0.0.1:9200/_cluster/health?pretty; do
  sleep 0.1
done
