#!/bin/bash

clear

speak_to_me() {
    while true; do
        echo " $(curl -s https://www.affirmations.dev/ | jq -r '.affirmation')"
        sleep 1
    done
}

on_the_run() {
    local width=$(tput cols)
    local progress=0
    local max=100

    while [ $progress -le $max ]; do
        sleep $(awk -v min=0.1 -v max=1 'BEGIN{srand(); print min+rand()*(max-min)}')

        local filled=$((progress * width / max))
        printf "\r[%-*s] %d%%" "$width" "$(printf '%*s' "$filled" '' | tr ' ' '#')" "$progress"

        ((progress += 5))
    done
    
    echo -e "\nDone!"
}

show_time() {
    while true; do
        clear
        echo "==== LIVE CLOCK ===="
        echo " "
        date +"%Y-%m-%d %H:%M:%S"
        sleep 1
    done
}

show_money() {
    CURRENCIES=("💲" "€" "£" "¥" "₹" "₿" "₩" "¢" "₣" "₴")

    clear
    tput civis

    while true; do
        WIDTH=$(tput cols)
        HEIGHT=$(tput lines)

        for ((i=0; i<HEIGHT; i++)); do
            LINE=""
            for ((j=0; j<WIDTH; j++)); do
                if (( RANDOM % 10 == 0 )); then
                    LINE+="${CURRENCIES[RANDOM % ${#CURRENCIES[@]}]}"
                else
                    LINE+=" "
                fi
            done
            echo -e "$LINE"
        done
        
        sleep 0.1
        clear
    done
}

brain_damage() {
    clear
    tput civis 

    while true; do
        clear
        echo "PID   USER      %CPU  %MEM  COMMAND"
        echo "-----------------------------------"
        ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 11
        sleep 1
    done
}

trap "tput cnorm; clear; exit" SIGINT SIGTERM

if [ "$1" == "--play=speak_to_me" ]; then
    speak_to_me
elif [ "$1" == "--play=on_the_run" ]; then
    on_the_run
elif [ "$1" == "--play=show_time" ]; then
    show_time
elif [ "$1" == "--play=show_money" ]; then
    show_money
elif [ "$1" == "--play=brain_damage" ]; then
    brain_damage
else
    echo "Usage: $0 --play=<track>"
    echo "Available tracks: speak_to_me, on_the_run, show_time, show_money, brain_damage"
    exit 1
fi
