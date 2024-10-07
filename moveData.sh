#!/bin/bash
set -ex

while true; do
    clickhouse-client --query "SELECT DISTINCT table, partition FROM system.parts WHERE disk_name LIKE 'old_disk' LIMIT 100" > /tmp/partitions.txt
    if [ "$(wc -l /tmp/partitions.txt | awk '{print $1}')" == "0" ]; then
        exit 0
    fi

    while read -r line; do
        read arr[{1..2}] <<< $(echo $line)
        clickhouse-client --query "ALTER TABLE ${arr[1]} MOVE PARTITION ${arr[2]} TO DISK 'new_disk'" --receive_timeout=6000
    done < /tmp/partitions.txt

done
