#!/bin/bash
db_file="data/player.csv"
salt="SisopSusah"  

read -p "Enter your email: " email

if ! grep -q "^$email," "$db_file"; then
    echo "Email not found. Please register first."
    exit 1
fi

stored_hash=$(grep "^$email," "$db_file" | cut -d ',' -f3)

read -s -p "Enter password: " password
echo ""

input_hash=$(echo -n "$salt$password" | sha256sum | awk '{print $1}')
if [[ "$input_hash" == "$stored_hash" ]]; then
    echo "Login successful!"
else
    echo "Incorrect password!"
    exit 1
fi

