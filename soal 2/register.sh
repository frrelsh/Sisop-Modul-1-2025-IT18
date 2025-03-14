#!/bin/bash

db_file="data/player.csv"
salt="SisopSusah"  

validate_email() {
    local email="$1"
    if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0  
    else
        return 1  
    fi
}

validate_password() {
    local password="$1"
    if [[ ${#password} -ge 8 && "$password" =~ [a-z] && "$password" =~ [A-Z] && "$password" =~ [0-9] ]]; then
        return 0  
    else
        return 1  
    fi
}

read -p "Enter your email: " email
while ! validate_email "$email"; do
    echo "Invalid email format! Please enter a valid email."
    read -p "Enter your email: " email
done

if grep -q "^$email," "$db_file"; then
    echo "Email already registered. Please use a different email."
    exit 1
fi


read -p "Enter your username: " username

read -s -p "Enter password: " password
echo ""
while ! validate_password "$password"; do
    echo "Password must be at least 8 characters long, contain a lowercase letter, an uppercase letter, and a number."
    read -s -p "Enter password: " password
    echo ""
done

hashed_password=$(echo -n "$salt$password" | sha256sum | awk '{print $1}')

echo "$email,$username,$hashed_password" >> "$db_file"
echo "Registration successful!"
