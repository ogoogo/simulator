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
% disp(moon(1:3))
% disp(sun(1:3))

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

dcm2 = cele_vector/norm(cele_vector);

b1 = a1 - dot(a1,dcm2)*dcm2;
dcm1 = b1/norm(b1);

% b3 = a2 - dot(a2,dcm2)*dcm2 - dot(a2,dcm1)*dcm1;
% dcm3 = b3/norm(b3);

dcm3 = cross(dcm1,dcm2);

% cele_x= cele_vector(1,1);
% cele_y= cele_vector(1,2);
% cele_z= cele_vector(1,3);
% 
% theta = subspace([0;1;0],cele_vector');
% lambda = [cele_z/(cele_x^2 + cele_z^2)^0.5; 0; cele_x/(-cele_x^2 + cele_z^2)^0.5];
% 
% quaternion = [cos(theta/2); lambda(1)*sin(theta/2); lambda(2)*sin(theta/2); lambda(3)*sin(theta/2)];
% 
% dcm = cspice_q2m(quaternion);



writematrix(dcm1,'dcm1.txt','Delimiter',',')
writematrix(dcm2,'dcm2.txt','Delimiter',',')
writematrix(dcm3,'dcm3.txt','Delimiter',',')





% disp(attitude_equ)
% disp(attitude_equ(2,:))
% 
% writematrix(attitude_equ(2,:),'attitude_equ.txt','Delimiter',',') 



disp(r_equ)
writematrix(r_equ,'r_equ.txt','Delimiter',',') 



    
 
