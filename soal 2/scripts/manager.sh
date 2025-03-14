#!/bin/bash

CORE_MONITOR="$(pwd)/core_monitor.sh"
FRAG_MONITOR="$(pwd)/frag_monitor.sh"

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

show_menu() {
    echo -e "\n=============================="
    echo -e "        CRONTAB MANAGER         "
    echo -e "==============================\n"
    echo -e "1) Add CPU Monitoring"
    echo -e "2) Remove CPU Monitoring"
    echo -e "3) Add RAM Monitoring"
    echo -e "4) Remove RAM Monitoring"
    echo -e "5) View Active Jobs"
    echo -e "6) Exit"
    echo -ne "Choose an option: "
}

add_cpu_monitor() {
    if crontab -l | grep -q "$CORE_MONITOR"; then
        echo -e "${RED}❌ CPU Monitoring is already active.${RESET}"
    else
        (crontab -l 2>/dev/null; echo "* * * * * $CORE_MONITOR >> $CORE_LOG 2>&1") | crontab -
        echo -e "${GREEN}✅ CPU Monitoring added!${RESET}"
    fi
    crontab -l | grep "$CORE_MONITOR"
}

remove_cpu_monitor() {
    crontab -l | grep -v "$CORE_MONITOR" | crontab -
    echo -e "${RED}❌ CPU Monitoring removed.${RESET}"
    crontab -l
}

add_ram_monitor() {
    if crontab -l | grep -q "$FRAG_MONITOR"; then
        echo -e "${RED}❌ RAM Monitoring is already active.${RESET}"
    else
        (crontab -l 2>/dev/null; echo "* * * * * $FRAG_MONITOR >> $FRAG_LOG 2>&1") | crontab -
        echo -e "${GREEN}✅ RAM Monitoring added!${RESET}"
    fi
    crontab -l | grep "$FRAG_MONITOR"
}

remove_ram_monitor() {
    crontab -l | grep -v "$FRAG_MONITOR" | crontab -
    echo -e "${RED}❌ RAM Monitoring removed.${RESET}"
    crontab -l
}

view_jobs() {
    echo -e "${GREEN}🔍 Active crontab jobs:${RESET}"
    crontab -l
}

while true; do
    show_menu
    read choice
    case $choice in
        1) add_cpu_monitor ;;
        2) remove_cpu_monitor ;;
        3) add_ram_monitor ;;
        4) remove_ram_monitor ;;
        5) view_jobs ;;
        6) echo -e "${RED}Exiting...${RESET}"; exit ;;
        *) echo -e "${RED}❌ Invalid Option! Try Again.${RESET}" ;;
    esac
done