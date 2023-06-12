et    = cspice_str2et('2023-02-12T18:36:20');

moon = cspice_spkezr('MOON', et, 'J2000','NONE','EARTH');
sun = cspice_spkezr('SUN', et, 'J2000','NONE','EARTH');
% disp(moon(1:3))
% disp(sun(1:3))

l_moon = moon(1:3).';
l_sun = sun(1:3).';

writematrix(l_moon,'l_moon.txt','Delimiter',',') 
writematrix(l_sun,'l_sun.txt','Delimiter',',')

qua_equ = [0.44994;0.654557;-0.041124;0.606151];

attitude_equ = inv(cspice_q2m(qua_equ));
% r1 = eye(3);
% r2 = cspice_rotmat(r1, cspice_halfpi, 1);
% r3 = cspice_rotmat(r2, cspice_halfpi, 3);
% r_dlp = cspice_rotmat(r_equ, -cspice_halfpi, 1);


disp(attitude_equ)
disp(attitude_equ(2,:))

writematrix(attitude_equ(2,:),'attitude_equ.txt','Delimiter',',') 


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



    
 
