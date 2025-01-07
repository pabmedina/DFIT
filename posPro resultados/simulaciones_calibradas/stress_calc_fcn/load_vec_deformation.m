clc
clearvars

% Calculo de deformaciones para el caso de Opalius
% Propiedades elasticas:

E = 13.8; %[GPa] -> 2 Mpsi
nu = 0.24;

sigma_rr = [3.4 ; 6.9 ; 13.8]; % MPa

eps_xx = zeros(3,1);
eps_yy = zeros(3,1);
eps_zz = zeros(3,1);

for i = 1:size(sigma_rr,1)
    eps_xx(i) = sigma_rr(i)*(1 - nu -nu^2)/E/1e3;
    eps_yy(i) = sigma_rr(i)*(1 - nu -nu^2)/E/1e3;
    eps_zz(i) = sigma_rr(i)*nu*(1 - 2*nu)/E/1e3;

end

load_vec_1 = [eps_xx(1) eps_yy(1) eps_zz(1)];
load_vec_2 = [eps_xx(2) eps_yy(2) eps_zz(2)];
load_vec_3 = [eps_xx(3) eps_yy(3) eps_zz(3)];
