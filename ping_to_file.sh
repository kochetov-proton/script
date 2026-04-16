#!/bin/bash 
TARGET="8.8.8.8" 
LOGFILE="/var/log/ping_monitor.log"
while true; do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

    if ping -c 1 -W 1 $TARGET > /dev/null; then
        STATUS=1
    else
        STATUS=0
    fi

    echo "{\"time\": \"$TIMESTAMP\", \"status\": $STATUS}" >> $LOGFILE

    sleep 5
done
