# Sisop-Modul-1-2025-IT18 
# Soal 1
# Soal 2
0. Pada soal ini diperintahkan untuk membuat sebuah shell script yang memiliki fitur register, login, manager crontab, dan terminal. dengan direktori sebagai berikut <br>
    ├── login.sh <br>
    ├── register.sh <br>
    ├── scripts/ <br>
    │   ├── core_monitor.sh <br>
    │   ├── frag_monitor.sh <br>
    │   └── manager.sh <br>
    └── terminal.sh <br>

2. Register
    <p>Pada script register ada beberapa function yang dijalankan di script ini, seperti validasi email dan validasi password</p>

    * Deklarasi Database
    <pre>
    db_file="data/player.csv"
    salt="SisopSusah"
    </pre>
    
    * Validasi Email
    <p>Function ini menerima inputan email user lalu akan divalidasi dengan regex pada function, jika bernilai false maka user diminta untuk mengisi ulang</p>
    <pre> validate_email() {
    local email="$1"
    if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0  
    else
        return 1  
    fi} </pre>

    * Validasi Password
    <p>Function ini berguna untuk memvalidasi password sesuai dengan regex yang ditentukan</p>
    <pre>
    validate_password() {
    local password="$1"
    if [[ ${#password} -ge 8 && "$password" =~ [a-z] && "$password" =~ [A-Z] && "$password" =~ [0-9] ]]; then
        return 0  
    else
        return 1  
    fi}
    </pre>

    * Menerima Inputan Email
    <p>Script ini untuk menerima inputan email dan menjalankan function validasi email</p>
    <pre>
    read -p "Enter your email: " email
    while ! validate_email "$email"; do
        echo "Invalid email format! Please enter a valid email."
        read -p "Enter your email: " email
    done
    </pre>

    * Mengecek apakah email sudah ada di database atau belum
    <pre>
    if grep -q "^$email," "$db_file"; then
    echo "Email already registered. Please use a different email."
    exit 1
    fi
    </pre>

    * Meminta inputan username dan password
    <pre>
    read -p "Enter your username: " username
    read -s -p "Enter password: " password
    echo ""
    </pre>

    * Menjalankan function validasi password, dan hashing, serta redirect data ke database
    <pre>
    while ! validate_password "$password"; do
    echo "Password must be at least 8 characters long, contain a lowercase letter, an uppercase letter, and a number."
    read -s -p "Enter password: " password
    echo ""
    done

    hashed_password=$(echo -n "$salt$password" | sha256sum | awk '{print $1}')

    echo "$email,$username,$hashed_password" >> "$db_file"
    echo "Registration successful!"
    </pre>
3. Login
    <p>Untuk script ini akan menjalankan fungsi login sebagai mana mestinya yang dimana scriptnya tidak jauh beda dengan script register</p>

    * Deklarasi Database
    <pre>
    db_file="data/player.csv"
    salt="SisopSusah"
    </pre>

    * Menerima inputan email dan mengecek apakah email ada pada database 
    <pre>
    read -p "Enter your email: " email
    if ! grep -q "^$email," "$db_file"; then
        echo "Email not found. Please register first."
        exit 1
    fi
    </pre>

    * Mengambil password dari database dan menerima inputan login passsword
    <pre>
    stored_hash=$(grep "^$email," "$db_file" | cut -d ',' -f3)
    read -s -p "Enter password: " password
    echo ""
    </pre>

    * Menjalankan fungsi hash dengan menyamakan hash dari input login dengan database
    <pre>
    input_hash=$(echo -n "$salt$password" | sha256sum | awk '{print $1}')
    if [[ "$input_hash" == "$stored_hash" ]]; then
        echo "Login successful!"
    else
        echo "Incorrect password!"
        exit 1
    fi
    </pre>
4. Core Monitor
    <p>Script ini untuk mencatat monitoring cpu secara realtime kedalam file log</p>

    * Path ke directory file log
    <pre>
    LOG_DIR="../logs"
    LOG_FILE="$LOG_DIR/core.log"
    </pre>

    * Time stamp
    <pre>
    time=$(date +"%Y-%m-%d %H:%M:%S")
    </pre>

    * Monitoring CPU
    <pre>
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d ':' -f2 | sed 's/^ *//')
    </pre>

    * Entry ke file log, dan menampilkan hasilnya ke terminal
    <pre>
    log_entry="[$time] - Core Usage [$cpu_usage%] - Terminal Model [$cpu_model]"
    echo "$log_entry" >> "$LOG_FILE"
    echo -e "${YELLOW}CPU Model: ${RESET}$cpu_model"
    echo -e "${RED}CPU Usage: ${RESET}$cpu_usage%"
    </pre>
5. Frag Monitor
    <p>Script ini untuk mencatat monitoring RAM secara realtime kedalam file log</p>

    * Path ke directory file log
    <pre>
    LOG_DIR="../logs"
    LOG_FILE="$LOG_DIR/frag.log"
    </pre>

    * Time stamp
    <pre>
    time=$(date +"%Y-%m-%d %H:%M:%S")
    </pre>

    * Monitoring RAM
    <pre>
    ram_total=$(free -m | awk '/Mem:/ {print $2}')   
    ram_used=$(free -m | awk '/Mem:/ {print $3}')    
    ram_usage_percent=$(free | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')   
    </pre>

    * Entry ke file log, dan menampilkan hasilnya ke terminal
    <pre>
    log_entry="[$time] - Fragment Usage [$ram_usage_percent%] - Fragment Count [$ram_used MB] - Details [Total: $ram_total MB, Available: $ram_available MB]"
    echo "$log_entry" >> "$LOG_FILE"
    echo -e "Total RAM: ${ram_total} MB"
    echo -e "Used RAM: ${ram_used} MB"
    echo -e "RAM Usage: ${ram_usage_percent}%"
    </pre>
6. Manager Crontab
    <p>Script ini diperuntukan untuk memanage crontab</p>

    * Deklarasi direktori dan warna
    <pre>
    CORE_MONITOR="$(pwd)/core_monitor.sh"
    FRAG_MONITOR="$(pwd)/frag_monitor.sh"

    GREEN="\033[0;32m"
    RED="\033[0;31m"
    RESET="\033[0m"
    </pre>

    * Function untuk menu pada terminal
    <pre>
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
    echo -ne "Choose an option: "}
    </pre>

    * Function untuk add cpu monitoring
    <p>Function ini bekerja dengan mengecek apakah ada crontab yang berjalan terlebi dahulu, jika belum ada maka fungsi core monitor akan dijalankan</p>
    <pre>
    add_cpu_monitor() {
    if crontab -l | grep -q "$CORE_MONITOR"; then
        echo -e "${RED}❌ CPU Monitoring is already active.${RESET}"
    else
        (crontab -l 2>/dev/null; echo "* * * * * $CORE_MONITOR >> $CORE_LOG 2>&1") | crontab -
        echo -e "${GREEN}✅ CPU Monitoring added!${RESET}"
    fi
    crontab -l | grep "$CORE_MONITOR"}
    </pre>

    * Function untuk remove cpu monitoring
    <pre>
    remove_cpu_monitor() {
    crontab -l | grep -v "$CORE_MONITOR" | crontab -
    echo -e "${RED}❌ CPU Monitoring removed.${RESET}"
    crontab -l}
    </pre>

    * Function untuk add ram monitoring
    <pre>
    add_ram_monitor() {
    if crontab -l | grep -q "$FRAG_MONITOR"; then
        echo -e "${RED}❌ RAM Monitoring is already active.${RESET}"
    else
        (crontab -l 2>/dev/null; echo "* * * * * $FRAG_MONITOR >> $FRAG_LOG 2>&1") | crontab -
        echo -e "${GREEN}✅ RAM Monitoring added!${RESET}"
    fi
    crontab -l | grep "$FRAG_MONITOR"}
    </pre>

    * Function untuk remove ram monitoring
    <pre>
    remove_ram_monitor() {
    crontab -l | grep -v "$FRAG_MONITOR" | crontab -
    echo -e "${RED}❌ RAM Monitoring removed.${RESET}"
    crontab -l}
    </pre>

    * Function active view jobs
    <p>Untuk melihat keseluruahn kerja crontab</p>
    <pre>
    view_jobs() {
    echo -e "${GREEN}🔍 Active crontab jobs:${RESET}"
    crontab -l}
    </pre>

    * Script ini digunakan menjalankan function menu
    <pre>
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
    </pre>
7. Terminal    
    <p>Script ini seperti home menu untuk soal ini</p>

    * Deklarasi ke masing" script
    <pre>
    REGISTER_SCRIPT="register.sh"
    LOGIN_SCRIPT="login.sh"
    CRONTAB_SCRIPT="./scripts/manager.sh"
    </pre>

    * Function menu
    <pre>
    show_menu() {
    clear
    echo "=============================="
    echo "     Welcome to Terminal      "
    echo "=============================="
    echo "1. Register"
    echo "2. Login"
    echo "3. Crontab Manager"
    echo "4. Exit"
    echo "=============================="}
    </pre>

    * Script ini menjalankan function menu
    <pre>
    while true; do
    show_menu
    read -p "Pilih opsi (1-4): " choice

    case "$choice" in
        1)
            bash "$REGISTER_SCRIPT"
            ;;
        2)
            bash "$LOGIN_SCRIPT"
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
    </pre>

    <h3>Note asistensi untuk soal 2</h2>

    * Untuk push ke repo cukup file script tidak perlu file csv dan log.
    
    * Untuk fungsi login di terminal, setelah login berhasil harus otomatis membuka crontab manager
    <pre>
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
    </pre>
    
    * Perubahannya ada pada opsi 2, sehingga ketika login berhasil maka crontab akan otomatis terbuka
    <pre>
    if bash "$LOGIN_SCRIPT"; then
                # Jika login berhasil, langsung buka CRONTAB_SCRIPT
                bash "$CRONTAB_SCRIPT"
            else
                echo "Login gagal. Silakan coba lagi."
                read -p "Tekan Enter untuk melanjutkan..."
            fi
            ;;
    </pre>
# Soal 3
# Soal 4
Pada soal ini kita diminta  untuk membuat script yang bernama pokemon_analysis.sh dengan fitur melihat summary dari data, mengurutkan pokemon berdasarkan kolom, mencari nama pokemon tertentu, mencari pokemon berdasarkan filter nama type, error handling, dan help screen.
