#!/bin/bash

BASE_DIR=~/.wifi_auto_login
CREDFILE="$BASE_DIR/creds.txt"
LOGFILE="$BASE_DIR/logs.txt"

mkdir -p $BASE_DIR

if [ ! -f "$CREDFILE" ]; then
    echo "Credentials file not found at $CREDFILE"
    exit 1
fi

source $CREDFILE

while true; do

     resp=$(curl -s -o /dev/null -w "%{http_code}" http://www.gstatic.com/generate_204)

     if [ "$resp" -ne 204 ]; then
          TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
     
          echo "$TIMESTAMP (-) Captive portal detected (Attempting to log in)" | tee -a "$LOGFILE"

          curl -s -o /dev/null -X POST "http://172.20.28.1:8002/index.php?zone=hostelzone" \
               -d "auth_user=$USERNAME" \
               -d "auth_pass=$PASSWORD" \
               -d "accept=Login"

          echo "$TIMESTAMP (+) Login attempt finished" | tee -a "$LOGFILE"
     fi

     sleep 10
done
