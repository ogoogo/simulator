clear()

n = 10;
min_distance = 70000;
max_distance = 200000;
min_deg = 0;
max_deg = 90;

situation = "mac";
celestial = "moon";

output_name = "./informations/information1004.csv";

path_setting(situation)

equ_source_name = create_csv(min_distance,max_distance,min_deg,max_deg, celestial);

for i = 1:n
    calculate_data(equ_source_name,output_name, celestial)
    disp(i+"回")
end