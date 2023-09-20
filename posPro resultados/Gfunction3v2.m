

load('pforGfunction.mat')
load('tforGfunction.mat')
pIsip=pFEACorregida(96:end);
t=tFEA(96:end); %asumi q fue cada un segundo siempre, poner data real despues

tiempo0=90; %segundos de Frac
tiempoActual=tiempo0+t; %300 de isip

delta = (tiempoActual-tiempo0)/tiempo0;
% delta0= [0, 0.25, 0.5, 0.75, 1]; % Parametro de matcheo pero en el paper siempre ponen variar curvas y plotean todas juntas
delta0=0;

gT=(4/3)*((1+delta).^1.5-delta.^1.5-1);
g0=(4/3)*((1+delta0).^1.5-delta0.^1.5-1);

G=4/pi*(gT-g0);

% plot(pIsip,G)
% title('P en funcion de G')

pendiente=diff(pIsip) ./ diff(G);

valoresY=G(1:end-1).*pendiente;

plot(G(1:end-1),pendiente)
title('dp/dG en funcion de G')
