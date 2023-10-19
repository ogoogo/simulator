#!/bin/sh



id=65439

csv_count=$((id / 10000 + 1))
echo "$csv_count"

for j in `seq $csv_count 61`
do

    input_csv="./informations/output/output_${j}.csv"
    echo "$input_csv"

    tail -n +$((id % 10000)) "$input_csv" | while IFS= read -r line; do
   
        echo "$line" > "inforow.txt"
        povray povray.pov +W659 +H494 Output_File_Name=./output/$id
        echo "ID{$id}の画像生成"
        id=$((id + 1))

    done



done



