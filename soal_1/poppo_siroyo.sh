#!/bin/bash

# Download file
wget -q "https://drive.usercontent.google.com/u/0/uc?id=1l8fsj5LZLwXBlHaqhfJVjz_T0p7EJjqV&export=download" -O reading_data.csv

if [ "$1" == "soalA" ]; then
    awk -F',' '$2 ~ /Chris Hemsworth/ {++n} END {print "Chris Hemsworth membaca", n, "buku."}' reading_data.csv

elif [ "$1" == "soalB" ]; then
    awk -F',' '$8 ~ /Tablet/ {total+=$6; n++} END {
        if (n > 0) print "Rata-rata durasi membaca dengan Tablet adalah", total/n, "menit."; 
        else print "Tidak ada data membaca dengan Tablet."}' reading_data.csv

elif [ "$1" == "soalC" ]; then
    # Mencari pembaca dengan rating tertinggi
    awk -F',' 'NR > 1 {if ($7 > max) {max = $7; name = $2; book = $3}} 
    END {print "Pembaca dengan rating tertinggi:", name, "-", book, "-", max}' reading_data.csv

elif [ "$1" == "soalD" ]; then
    # Genre paling populer di Asia setelah 2023
    awk -F',' 'NR > 1 && $5 > "2023-12-31" && ($4 ~ /Asia/) {count[$9]++} 
    END {
        max_genre = ""; max_count = 0;
        for (genre in count) {
            if (count[genre] > max_count) {
                max_count = count[genre];
                max_genre = genre;
            }
        }
        print "Genre paling populer di Asia setelah 2023 adalah", max_genre, "dengan", max_count, "buku."
    }' reading_data.csv

else
    echo "Usage: $0 {soalA|soalB|soalC|soalD}"
fi
