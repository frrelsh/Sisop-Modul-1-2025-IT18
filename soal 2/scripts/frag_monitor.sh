#!/bin/bash

LOG_DIR="../logs"
LOG_FILE="$LOG_DIR/fragment.log"

time=$(date +"%Y-%m-%d %H:%M:%S")

ram_total=$(free -m | awk '/Mem:/ {print $2}')   
ram_used=$(free -m | awk '/Mem:/ {print $3}')    
ram_usage_percent=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')  

log_entry="[$time] - Fragment Usage [$ram_usage_percent%] - Fragment Count [$ram_used MB] - Details [Total: $ram_total MB, Available: $ram_available MB]"
echo "$log_entry" >> "$LOG_FILE"

echo -e "${YELLOW}Total RAM: ${RESET}${ram_total} MB"
echo -e "${YELLOW}Used RAM: ${RESET}${ram_used} MB"
echo -e "${RED}RAM Usage: ${RESET}${ram_usage_percent}%"
