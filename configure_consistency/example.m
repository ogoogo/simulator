clear()


et    = cspice_str2et('2023 February 12, 18:36:20 UTC');
revNum = '230211-0100';
fileNum = '230212-0100';
fileName = append('./source/',fileNum, '_HK_stored_svtlm.csv');

date = cspice_et2utc(et,'C',6);

ti = et2TiConverter_multiv0(et,revNum);
disp(ti)

log = readmatrix(fileName);

[row1,col1] = size(log);

for i = 1:row1
    if log(i,2) < ti && ti < log(i+1,2)
        quat = log(i,188:191);
        break
    end
end

q = [quat(4), quat(1), quat(2), quat(3)]';
disp(q)





moon = cspice_spkezr('MOON', et, 'J2000','NONE','EARTH');
sun = cspice_spkezr('SUN', et, 'J2000','NONE','EARTH');


% disp(moon(1:3))
% disp(sun(1:3))

l_moon = moon(1:3).';
l_sun = sun(1:3).';

dcm = inv(cspice_q2m(q));





M = readmatrix('./../orbit_equ/orbit_equ.dat');

[row,col] = size(M);

for i = 1:row
    if M(i,1) < et && et < M(i+1,1)
        r_equ = M(i,2:4);
        break
    end
end
disp(r_equ)
disp(dcm)


% dlpから見た姿勢
dlp_dcm = cspice_rotmat(dcm, pi, 2);
disp(dlp_dcm)


% dlpから見た太陽方向
sun_dlp = l_sun*dlp_dcm';
% disp(sun_dlp)


id = 1;
inforow = [id, et, r_equ, l_moon, l_sun, dcm(1,:), dcm(2,:), dcm(3,:), dlp_dcm(1,:), dlp_dcm(2,:), dlp_dcm(3,:), sun_dlp];

writematrix(inforow,"./../inforow.txt", 'Delimiter',',')



    
 
