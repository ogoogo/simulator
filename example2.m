clear()

% 編集引数
min_distance = 0;
max_distance = 200000;
min_deg = 0;
max_deg = 90;

celestial = "moon";
% celestial = "earth";



equ_source_name = sprintf("./orbit_equ_output/orbit_%d_%d_%d_%d.csv", min_distance, max_distance/10000, min_deg, max_deg);


addpath('~/simulator/mice/src/mice/')
addpath('~/simulator/mice/lib/')

% addpath('~/issl/research/simulator/mice/src/mice/')
% addpath('~/issl/research/simulator/mice/lib/')

if cspice_ktotal( 'ALL' ) >= 1
else
    disp('kernels settings')
    cspice_furnsh('../kernel/naif0012.tls');
    cspice_furnsh('../kernel/de440.bsp');
end


if exist('./information.csv') == 0
    id = 1;
else
    info = readmatrix('./information.csv');
    [row1,col1] = size(info);
    id = info(row1,1) + 1;
end





rng('shuffle');
% et_min = 7.2247686918289995e+08;
% et_max = 7.5962046918519998e+08;
%
% et = et_min + randi(round(et_max-et_min));
%
% date = cspice_et2utc(et,'C',6);
% disp(date)



% writematrix(l_moon,'l_moon.txt','Delimiter',',')
% writematrix(l_sun,'l_sun.txt','Delimiter',',')






if exist(equ_source_name) == 0
    for j = 0:85
        disp(j)
        fileName = sprintf('./orbit_equ/orbit_equ%d.dat',j);
        M = readmatrix(fileName);
        [row,col] = size(M);
        for i = 1:row

            r_equ = M(i,2:4);
            et = M(i,1);
            cspice_sun = cspice_spkezr('SUN', et, 'J2000','NONE','EARTH');
            r_sun = cspice_sun(1:3)';
            if celestial == "moon"
                cspice_cele = cspice_spkezr('MOON', et, 'J2000','NONE','EARTH');
                r_cele = cspice_cele(1:3)';
            else
                r_cele = [0,0,0];
            end
            norm_cele = norm(r_cele - r_equ);
            rad_cele = acos(dot(r_equ-r_cele,r_sun-r_cele)/(norm(r_equ-r_cele)*norm(r_sun-r_cele)));
            deg_cele = rad2deg(rad_cele);
            if min_distance < norm_cele && norm_cele < max_distance
                if min_deg < deg_cele && deg_cele < max_deg
                    writematrix(M(i,:), equ_source_name, 'WriteMode', 'append')
                end

            end
        end
    end

end

equ_source = readmatrix(equ_source_name);
[row2,col2] = size(equ_source);

source_i = randi(row2);
r_equ = equ_source(source_i,2:4);

et = equ_source(source_i,1);


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

cele_vector = l_cele - r_equ;


% while 1
%     for i = 1:row
%         if M(i,1) < et && et < M(i+1,1)
%             r_equ = M(i,2:4);
%             break
%         end
%     end
%     cele_vector = l_cele - r_equ;
%     norm_cele = norm(cele_vector);
%     if 0 < norm_cele && norm_cele < 700000
%
%         break
%     end
%
%
% end



% cele_vector = l_cele - r_equ;



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

dcm3 = cspice_rotmat(dcm2, dpsi, 1);

% 横方向にずらす
phi = deg2rad(2.79);
dphi_max = atan((l*tan(phi) - R/2)/l);
dphi = -dphi_max + dphi_max * randi(200) / 100;

dcm4 = cspice_rotmat(dcm3, dphi, 3);


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

if celestial == "moon"
    cele_dlp = (l_moon - r_equ)*dlp_dcm';
else
    cele_dlp = (- r_equ)*dlp_dcm';
end
disp(cele_dlp')

% 楕円係数を求める
Tcp = dcm_moon1/dlp_dcm;

A_mat = Tcp'*(1/R^2)*eye(3)*Tcp;
disp("A")
disp(A_mat)
r_vec = cele_dlp';
M_mat =A_mat*r_vec*(r_vec')*A_mat - (r_vec'*A_mat*r_vec - 1)*A_mat;
disp(M_mat);



A = M_mat(1,1);
B = 2*M_mat(1,2);
C = M_mat(2,2);
D = 2*M_mat(1,3);
F = 2*M_mat(2,3);
G = M_mat(3,3);
coefficient = [A,B,C,D,F,G];
disp(coefficient);

% 楕円を描画する範囲を指定
xMin = -5;
xMax = 5;
yMin = -5;
yMax = 5;



fnc = @(X,Y) A * X.^2 + B * X .* Y + C * Y.^2 + D * X + F * Y + G;

figure
fimplicit(fnc)
ylim([-1 1])
grid on

% % 描画用のグリッドを作成
% [X, Y] = meshgrid(linspace(xMin, xMax, 100), linspace(yMin, yMax, 100));
%
% % 楕円の方程式を計算
% Z = A * X.^2 + B * X .* Y + C * Y.^2 + D * X + F * Y + G;
%
% % 楕円をプロット
% figure;
% contour(X, Y, Z, [0 0], 'LineWidth', 2);  % 楕円を等高線で描画
% axis equal;  % アスペクト比を保持
% xlabel('X軸');
% ylabel('Y軸');
% title('楕円の描画');
% grid on;
%




inforow = [id, et, r_equ, l_moon, l_sun, dcm4(1,:), dcm4(2,:), dcm4(3,:), dlp_dcm(1,:), dlp_dcm(2,:), dlp_dcm(3,:), sun_dlp, cele_dlp];

writematrix(inforow, "information.csv", 'WriteMode', 'append')
writematrix(inforow,"inforow.txt", 'Delimiter',',')








