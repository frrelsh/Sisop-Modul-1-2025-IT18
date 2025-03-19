#!/bin/bash
REGISTER_SCRIPT="register.sh"
LOGIN_SCRIPT="login.sh"
CRONTAB_SCRIPT="./scripts/manager.sh"

show_menu() {
    clear
    echo "=============================="
    echo "     Welcome to Terminal      "
    echo "=============================="
    echo "1. Register"
    echo "2. Login"
    echo "3. Crontab Manager"
    echo "4. Exit"
    echo "=============================="
}

while true; do
    show_menu
    read -p "Pilih opsi (1-4): " choice

    case "$choice" in
        1)
            bash "$REGISTER_SCRIPT"
            ;;
        2)
            if bash "$LOGIN_SCRIPT"; then
                # Jika login berhasil, langsung buka CRONTAB_SCRIPT
                bash "$CRONTAB_SCRIPT"
            else
                echo "Login gagal. Silakan coba lagi."
                read -p "Tekan Enter untuk melanjutkan..."
            fi
            ;;
        3)
            bash "$CRONTAB_SCRIPT"
            ;;
        4)
            echo "Goodbye!"
            exit 0
            ;;
    esac
done

