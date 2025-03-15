#!/bin/bash

LOG_DIR="../logs"
LOG_FILE="$LOG_DIR/core.log"

time=$(date +"%Y-%m-%d %H:%M:%S")

cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d ':' -f2 | sed 's/^ *//')

log_entry="[$time] - Core Usage [$cpu_usage%] - Terminal Model [$cpu_model]"

echo "$log_entry" >> "$LOG_FILE"

echo -e "${YELLOW}CPU Model: ${RESET}$cpu_model"
echo -e "${RED}CPU Usage: ${RESET}$cpu_usage%"

