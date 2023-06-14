clear()

et_min = 7.2247686918289995e+08;
et_max = 7.5962046918519998e+08;

et = et_min + randi(round(et_max-et_min));

date = cspice_et2utc(et,'C',6);
disp(date)

% celestial = "moon";
celestial = "earth";

moon = cspice_spkezr('MOON', et, 'J2000','NONE','EARTH');
sun = cspice_spkezr('SUN', et, 'J2000','NONE','EARTH');

l_moon = moon(1:3).';
l_sun = sun(1:3).';

if celestial == "moon"
    l_cele = l_moon;
else
    l_cele = [0,0,0];
end

writematrix(l_moon,'l_moon.txt','Delimiter',',') 
writematrix(l_sun,'l_sun.txt','Delimiter',',')

M = readmatrix('./orbit_equ/orbit_equ.dat');

[row,col] = size(M);

for i = 1:row
    if M(i,1) < et && et < M(i+1,1)
        r_equ = M(i,2:4);
        break
    end
end


cele_vector = l_cele - r_equ;

% グラムシュミット法
a1 = [1,0,0];
a2 = [0,1,0];
dcm1_y = cele_vector/norm(cele_vector);
b1 = a1 - dot(a1,dcm1_y)*dcm1_y;
dcm1_x = b1/norm(b1);
dcm1_z = cross(dcm1_x,dcm1_y);






writematrix(dcm1_x,'dcm1.txt','Delimiter',',')
writematrix(dcm1_y,'dcm2.txt','Delimiter',',')
writematrix(dcm1_z,'dcm3.txt','Delimiter',',')


disp(r_equ)
writematrix(r_equ,'r_equ.txt','Delimiter',',') 



    
 
