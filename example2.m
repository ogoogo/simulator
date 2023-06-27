clear()

addpath('~/simulator/mice/src/mice/')
addpath('~/simulator/mice/lib/')

if cspice_ktotal( 'ALL' ) >= 1
else
    disp('kernels settings')
    cspice_furnsh('../kernel/naif0012.tls');
    cspice_furnsh('../kernel/de440.bsp');
end


info = readmatrix('./information.csv');
[row1,col1] = size(info);
id = info(row1,1) + 1;

if isnan(id)
    id = 1;
end



rng('shuffle');
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

% writematrix(l_moon,'l_moon.txt','Delimiter',',') 
% writematrix(l_sun,'l_sun.txt','Delimiter',',')

M = readmatrix('./orbit_equ/orbit_equ.dat');

[row,col] = size(M);

for i = 1:row
    if M(i,1) < et && et < M(i+1,1)
        r_equ = M(i,2:4);
        break
    end
end
disp(r_equ)
% writematrix(r_equ,'r_equ.txt','Delimiter',',') 


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


% writematrix(dcm4(1,:),'dcm1.txt','Delimiter',',')
% writematrix(dcm4(2,:),'dcm2.txt','Delimiter',',')
% writematrix(dcm4(3,:),'dcm3.txt','Delimiter',',')

% dlpから見た姿勢
dlp_dcm = cspice_rotmat(dcm4, pi, 2);

% writematrix(dlp_dcm(1,:),'dcm1.txt','Delimiter',',')
% writematrix(dlp_dcm(2,:),'dcm2.txt','Delimiter',',')
% writematrix(dlp_dcm(3,:),'dcm3.txt','Delimiter',',')

% dlpから見た太陽方向
sun_dlp = l_sun*dlp_dcm';
disp(sun_dlp)

% 月の座標変換
moon_i = l_moon/norm(l_moon);
z = acos(norm([l_moon(1),l_moon(2)])/norm(l_moon));
if l_moon(3)>0
    moon_dk = [0, 0, norm(l_moon)/sin(z)] - l_moon;
else
    moon_dk = -([0, 0, -norm(l_moon)/sin(z)] - l_moon);
end
moon_k = moon_dk/norm(moon_dk);
moon_j = cross(moon_k,moon_i);

dcm_moon1 = [moon_i;moon_j;moon_k];
% dcm_moon2 = [1,0,0;0,0,1;0,-1,0]*[moon_i;moon_j;moon_k];
dcm_moon2 = cspice_rotmat(dcm_moon1,pi/2,1);
dcm_moon = [dcm_moon2(1,:),dcm_moon2(2,:),dcm_moon2(3,:)];
writematrix(dcm_moon,"moondcm.txt", 'Delimiter',',')



inforow = [id, et, r_equ, l_moon, l_sun, dcm4(1,:), dcm4(2,:), dcm4(3,:), dlp_dcm(1,:), dlp_dcm(2,:), dlp_dcm(3,:), sun_dlp];

writematrix(inforow, "information.csv", 'WriteMode', 'append')
writematrix(inforow,"inforow.txt", 'Delimiter',',')






    
 
