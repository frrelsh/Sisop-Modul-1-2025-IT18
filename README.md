# Sisop-Modul-1-2025-IT18 
# Soal 1
# Soal 2
0. Pada soal ini diperintahkan untuk membuat sebuah shell script yang memiliki fitur register, login, manager crontab, dan terminal 
1. Register
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
2. Login
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

    *Menjalankan fungsi hash dengan menyamakan hash dari input login dengan database
    <pre>
    input_hash=$(echo -n "$salt$password" | sha256sum | awk '{print $1}')
    if [[ "$input_hash" == "$stored_hash" ]]; then
        echo "Login successful!"
    else
        echo "Incorrect password!"
        exit 1
    fi
    </pre>
3. Core Monitor
4. Frag Monitor
5. Manager Crontab
# Soal 3
# Soal 4
