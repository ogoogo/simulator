#!/bin/sh

input_csv="./informations/information1004.csv"


id=1

while IFS= read -r line; do
   
    echo "$line" > "inforow.txt"
    povray povray.pov +W659 +H494 Output_File_Name=./output/$id
    echo "ID{$id}の画像生成"
    ((id++))

done < "$input_csv"

