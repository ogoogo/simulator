#!/bin/sh

input_csv="./informations/information1004.csv"
/Applications/MATLAB_R2022b.app/bin/matlab -nodesktop -nosplash -r 'build; exit'
 # /usr/local/MATLAB/R2023a/bin/matlab -nodesktop -nosplash -r 'example2; exit'


id=1

while IFS= read -r line; do
   
    echo "$line" > "inforow.txt"
    povray povray.pov +W659 +H494 Output_File_Name=./output/$id
    echo "ID{$id}の画像生成"
    ((id++))

done < "$input_csv"

