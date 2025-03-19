# Sisop-Modul-1-2025-IT18 
# Soal 1
# Soal 2
0. Pada soal ini diperintahkan untuk membuat sebuah shell script yang memiliki fitur register, login, manager crontab, dan terminal 
1. Register
    <p>Pada script register ada beberapa function yang dijalankan di script ini, seperti validasi email dan validasi password</p>
    <pre></pre>
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
    <pre>
    read -p "Enter your email: " email
    while ! validate_email "$email"; do
        echo "Invalid email format! Please enter a valid email."
        read -p "Enter your email: " email
    done
    </pre>
2. Login
3. Core Monitor
4. Frag Monitor
5. Manager Crontab
# Soal 3
# Soal 4
