clear()

et_min = 7.2247686918289995e+08;
et_max = 7.5962046918519998e+08;

et = et_min + randi(round(et_max-et_min));

date = cspice_et2utc(et,'C',6);
disp(date)

celestial = "moon";
% celestial = "earth";

moon = cspice_spkezr('MOON', et, 'J2000','NONE','EARTH');
sun = cspice_spkezr('SUN', et, 'J2000','NONE','EARTH');

l_moon = moon(1:3).';
l_sun = sun(1:3).';

if celestial == "moon"
    l_cele = l_moon;
    R = 1737.4;
else
    l_cele = [0,0,0];
    R = 6378.1;
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
disp(r_equ)
writematrix(r_equ,'r_equ.txt','Delimiter',',') 


cele_vector = l_cele - r_equ;

% グラムシュミット法
a1 = [1,0,0];
a2 = [0,1,0];
dcm1_y = cele_vector/norm(cele_vector);
b1 = a1 - dot(a1,dcm1_y)*dcm1_y;
dcm1_x = b1/norm(b1);
dcm1_z = cross(dcm1_x,dcm1_y);

dcm1 = [dcm1_x; dcm1_y; dcm1_z];


% ランダムにずらす
l = norm(cele_vector);

% 回転させる
dcm2 = cspice_rotmat(dcm1, 2*pi*randi(100)/100, 2);

%縦方向にずらす
psi = deg2rad(2.09);
dpsi_max = atan((l*tan(psi) - R/2)/l);
dpsi = -dpsi_max + dpsi_max * randi(200) / 100;

dcm3 = cspice_rotmat(dcm1, dpsi, 1);

% 横方向にずらす
phi = deg2rad(2.79);
dphi_max = atan((l*tan(phi) - R/2)/l);
dphi = -dphi_max + dphi_max * randi(200) / 100;

dcm4 = cspice_rotmat(dcm2, dphi, 3);


writematrix(dcm4(1,:),'dcm1.txt','Delimiter',',')
writematrix(dcm4(2,:),'dcm2.txt','Delimiter',',')
writematrix(dcm4(3,:),'dcm3.txt','Delimiter',',')






    
 