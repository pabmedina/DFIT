clc, clear all, close all

load('pforGfunction.mat')
load('tforGfunction.mat')
pIsip=pFEACorregida(96:end);
t=tFEA(96:end); %asumi q fue cada un segundo siempre, poner data real despues

tiempo0=96; %segundos de Frac
tiempoActual=96:1:43094+95; %300 de isip

delta = (tiempoActual-tiempo0)/tiempo0;
% delta0= [0, 0.25, 0.5, 0.75, 1]; % Parametro de matcheo pero en el paper siempre ponen variar curvas y plotean todas juntas
delta0=0;

gT=(4/3)*((1+delta).^1.5-delta.^1.5-1);
g0=(4/3)*((1+delta0).^1.5-delta0.^1.5-1);

G=4/pi*(gT-g0);
G=G';
figure;hold on
plot(G,pIsip)
title('P en funcion de G')

pendiente=diff(pIsip) ./ diff(G);

figure; hold on
plot(G(1:end-1),pendiente)
title('dP/dG en funcion de G')

valoresY=G(1:end-1).*pendiente;
figure; hold on
plot(G(1:end-1),valoresY)
title('G*dp/dG en funcion de G')
