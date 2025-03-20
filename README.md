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
0. Diminta membuat shell script untuk menjalankan perintah ./dsotm.sh --play="<Track>", dengan fitur:
1. Speak to Me: Menampilkan word of affirmation setiap detik dari API
<pre>
    #!/bin/bash

clear

speak_to_me() {
    while true; do
        echo " $(curl -s https://www.affirmations.dev/ | jq -r '.affirmation')"
        sleep 1
    done
}
</pre>

<pre>
#!/bin/bash
clear
</pre>
* Menentukan bahwa script ini akan dijalankan dengan Bash & Membersihkan terminal sebelum script berjalan

<pre>
    speak_to_me() {
    while true; do
        echo " $(curl -s https://www.affirmations.dev/ | jq -r '.affirmation')"
        sleep 1
    done
</pre>
Fungsi ini menampilkan word of affirmation setiap detik
* while true; do ... done → Loop tak terbatas, jalan terus sampai dihentikan
* curl -s https://www.affirmations.dev/ → Ambil data dari API
* jq -r '.affirmation' → Ekstrak teks afirmasi dari JSON
* sleep 1 → Tunggu 1 detik sebelum menampilkan afirmasi berikutnya

2. On the Run: Progress bar dengan interval random (0.1-1 detik)
<pre>
on_the_run() {
    local width=$(tput cols)
    local progress=0
    local max=100
</pre>
* Fungsi on_the_run ini bikin progress bar di terminal. Lebar bar disesuaikan dengan ukuran terminal (tput cols). Progress dimulai dari 0 hingga 100%, dan nanti bakal bertambah secara bertahap dengan jeda waktu yang random

<pre>
    while [ $progress -le $max ]; do
        sleep $(awk -v min=0.1 -v max=1 'BEGIN{srand(); print min+rand()*(max-min)}')
</pre>
* Loop ini jalan terus selama progress belum lebih dari max (100)
Di dalam loop, ada sleep dengan durasi random antara 0.1 hingga 1 detik. Ini dibuat pakai awk, yang menghasilkan angka acak dalam rentang tersebut

<pre>
        local filled=$((progress * width / max))
        printf "\r[%-*s] %d%%" "$width" "$(printf '%*s' "$filled" '' | tr ' ' '#')" "$progress"

        ((progress += 5))
    done
    
    echo -e "\nDone!"
}
</pre>
Bagian ini menampilkan progress bar dengan persentase
* local filled=$((progress * width / max)) → Hitung panjang progress bar berdasarkan lebar terminal
* printf "\r[%-*s] %d%%" "$width" "$(printf '%*s' "$filled" '' | tr ' ' '#')" "$progress"
* \r → Menghapus baris sebelumnya (overwrite)
* [%-*s] → Format bar dengan panjang width, diisi dengan #
* %d%% → Menampilkan persentase progress
* ((progress += 5)) → Menambah progress 5% setiap iterasi
* echo -e "\nDone!" → Menampilkan "Done!" setelah progress 100%


3. Time: Live clock menampilkan tanggal & waktu yang diperbarui setiap detik
<pre>
show_time() {
    while true; do
        clear
        echo "==== LIVE CLOCK ===="
        echo " "
        date +"%Y-%m-%d %H:%M:%S"
        sleep 1
    done
}
</pre>
Bagian ini menampilkan jam live (real-time clock) di terminal
* while true; do → Loop tak terbatas agar jam terus diperbarui
* clear → Membersihkan layar sebelum menampilkan jam baru
* echo "==== LIVE CLOCK ====" → Menampilkan header
* date +"%Y-%m-%d %H:%M:%S" → Menampilkan tanggal dan waktu dalam format YYYY-MM-DD HH:MM:SS
* sleep 1 → Menunggu 1 detik sebelum memperbarui tampilan

4. Money: Simulasi efek cmatrix dengan simbol mata uang
<pre>
show_money() {
    CURRENCIES=("💲" "€" "£" "¥" "₹" "₿" "₩" "¢" "₣" "₴")

    clear
    tput civis
</pre>
Bagian ini membuat efek "matrix" dengan simbol mata uang di terminal
* CURRENCIES=("💲" "€" "£" "¥" "₹" "₿" "₩" "¢" "₣" "₴") → Daftar simbol mata uang yang akan ditampilkan
* clear → Membersihkan layar sebelum mulai menampilkan efek
* tput civis → Menyembunyikan kursor agar tampilan lebih rapi

<code><pre>
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
</code></pre>
* Kode ini mencetak pola acak di terminal dengan efek animasi. Loop luar mengontrol tinggi tampilan, sedangkan loop dalam mengisi setiap baris dengan simbol atau spasi secara acak. Setelah mencetak satu baris, program menunggu sebentar (sleep 0.1) lalu menghapus layar (clear) untuk menciptakan efek bergerak seperti hujan kode           
Loop ini membentuk tampilan "hujan" simbol mata uang di terminal:
* Loop baris → Mengisi terminal secara vertikal (tinggi HEIGHT).
* Loop kolom → Mengisi tiap baris secara horizontal (lebar WIDTH).
* Random simbol → Dengan peluang 10%, karakter diisi simbol mata uang, sisanya spasi.
* Cetak ke terminal → Setiap baris hasil loop langsung ditampilkan.
* Efeknya bikin tampilan seperti "matrix rain" tapi pakai simbol uang.
        

5. Brain Damage: Task manager di terminal yang diperbarui setiap detik
<pre>
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
</pre>
* Fungsi brain_damage() ini adalah sebuah skrip Bash yang secara terus-menerus menampilkan daftar proses yang menggunakan CPU tertinggi di sistem

6.Bagian ini adalah struktur conditional dalam shell script yang menentukan fungsi mana yang akan dijalankan berdasarkan argumen yang diberikan saat menjalankan script.
<pre>
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
</pre>

7. Fungsinya untuk menangani input yang tidak valid. Kalau pengguna menjalankan script tanpa argumen yang sesuai (--play=<track>), maka program akan menampilkan pesan penggunaan yang benar dan daftar track yang tersedia, lalu keluar dengan kode error (exit 1)
<pre>
    echo "Usage: $0 --play=<track>"
    echo "Available tracks: speak_to_me, on_the_run, show_time, show_money, brain_damage"
    exit 1
fi
</pre>

# Soal 4
Pada soal ini kita diminta  untuk membuat script yang bernama pokemon_analysis.sh dengan fitur melihat summary dari data, mengurutkan pokemon berdasarkan kolom, mencari nama pokemon tertentu, mencari pokemon berdasarkan filter nama type, error handling, dan help screen.

1. Variabel Input
    <pre>
    #!/bin/bash
        
    file=$1
    </pre>
    $1 adalah argumen pertama yang diberikan saat menjalankan skrip (csv) dan variabel file menyimpan nama file yang akan diproses.
   
2. Fitur Summary
   <pre>
   --info)
    awk -F',' 'NR > 1 {
        if ($2+0 > maxUsage) { maxUsage = $2+0; maxPokeUsage = $1 }
        if ($3+0 > maxRaw) { maxRaw = $3+0; maxPokeRaw = $1 }
    }
    END {
        printf "Highest Adjusted Usage: %s with %.4f%%\n", maxPokeUsage, maxUsage;
        printf "Highest Raw Usage: %s with %d uses\n", maxPokeRaw, maxRaw
    }' "$file"
    ;;
   </pre>
   Case untuk menampilkan nama Pokemon dengan Usage% dan RawUsage paling tinggi.
   * Cara mengakses: <pre> ./pokemon_analysis.sh pokemon_usage.csv --info </pre>

3. Fitur Sort
   <pre>
    --sort)
        if [[ -z $3 ]]; then
            echo "Error: No sorting column provided"
            echo "Use -h or --help for more information"
            exit 1
        fi
        case $3 in
            usage) column=2 ;;
            rawusage) column=3 ;;
            name) column=1 ;;
            hp) column=6 ;;
            atk) column=7 ;;
            def) column=8 ;;
            spatk) column=9 ;;
            spdef) column=10 ;;
            speed) column=11 ;;
            *) echo "Error: Invalid sorting column"; exit 1 ;;
        esac
        (head -n 1 "$file" && tail -n +2 "$file" | sort -t',' -k$column,${column}nr)
        ;;
    </pre>
    Case untuk mengurutkan Pokemon berdasarkan kolom yang dipilih.
     * Cara mengakses: <pre> ./pokemon_analysis.sh pokemon_usage.csv --sort usage </pre>

 4. Fitur Grep
    <pre>
    --grep)
         if [[ -z $3 ]]; then
             echo "Error: No name provided"
             echo "Use -h or --help for more information"
             exit 1
         fi
         search_name=$3
         (head -n 1 "$file" && tail -n +2 "$file" | grep -i "^$search_name,")
         ;;
    </pre>
    Case untuk mencari nama Pokemon tertentu.
     * Cara mengakses: <pre> ./pokemon_analysis.sh pokemon_usage.csv --grep malamar </pre>

 5. Fitur Filter
    <pre>
     --filter)
        if [[ -z $3 ]]; then
            echo "Error: No filter type provided"
            echo "Use -h or --help for more information"
            exit 1
        fi
        type_filter=$3
        (head -n 1 "$file" && tail -n +2 "$file" | awk -F',' -v type="$type_filter" '$4 == type || $5 == type' | sort ->        ;;    
    </pre>
    Case untuk mencari atau memfilter Pokemon berdasarkan tipenya.
     * Cara mengakses: <pre> ./pokemon_analysis.sh pokemon_usage.csv --filter Dark </pre>

 6. Fitur Help Screen
    <pre>
    -h|--help)
        cat << EOF
      Usage:
        ./pokemon_analysis.sh <file.csv> <command> [options]

      Options:
        --info          : Show highest usage% and raw usage
        --sort <method> : Sort Pokemon by column
                name      Sort by Pokemon name
                usage     Sort by Adjusted Usage
                raw       Sort by Raw Usage
                hp        Sort by HP
                atk       Sort by Attack
                def       Sort by Defense
                spatk     Sort by Special Attack
                spdef     Sort by Special Defense
                speed     Sort by Speed
        --grep <name>   : Search a specific Pokemon
        --filter <type> : Filter Pokemon by type
        -h, --help      : Show this help message
     EOF
     </pre>
     Case untuk menampilkan help screen.
      * Cara mengakses: <pre> ./pokemon_analysis.sh pokemon_usage.csv -h </pre>

 7. Error handling
    <pre>
    if [[ $# -lt 2 ]]; then
    echo "Error: Invalid number of arguments."
    echo "Use -h or --help for more information."
    exit 1
    fi    
    </pre>
    Error handling akan muncul apabila kita memberikan argumen yang kurang dari dua.
     * Misal: <pre> ./pokemon_analysis.sh pokemon_usage.csv </pre>
