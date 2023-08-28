 clc, close all


% addpath('D:\Corridas\Paper geomec DFN\Santi\DFIT 7 del 23\DFIT\Resultados de corridas (.mat)\DFIT_DFIT_CorteAumentado_Qextendido')
% addpath('D:\Corridas\Paper geomec DFN\Santi\DFIT 7 del 23\DFIT\Resultados de corridas (.mat)\DFIT_DFIT_CorteAumentado_Qextendido_buff')
addpath('D:\Corridas\Paper geomec DFN\Santi\DFIT 7 del 23\Resultados de corridas 24_8(.mat)\DFIT_redDFN_v1\')
addpath('D:\Corridas\Paper geomec DFN\Santi\DFIT 7 del 23\Resultados de corridas 24_8(.mat)\DFIT_redDFN_v2\')
addpath('D:\Corridas\Paper geomec DFN\Santi\DFIT 7 del 23\Resultados de corridas 24_8(.mat)\DFIT_redDFN_v3\')
addpath('D:\Corridas\Paper geomec DFN\Santi\DFIT 7 del 23\Resultados de corridas 24_8(.mat)\DFIT_redDFN_v4\')
addpath('D:\Corridas\Paper geomec DFN\Santi\DFIT 7 del 23\Resultados de corridas 24_8(.mat)\DFIT_redDFN_v5\')




figure; hold on
%% estandar
for i=2:4
load(['resultadosFinISIP_DFIT_redDFN_v' num2str(i) '.mat'],'iTime','temporalProperties','paramDiscEle','bombaProperties','dTimes')

if ~exist('temporalProperties.nTimes','var')
    temporalProperties.nTimes=iTime-1;
end


indiceTiempo = temporalProperties.drainTimes+1:temporalProperties.nTimes;
tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo));
%- Plot: Presion nodo bomba calculado por FEA.
pFEA = zeros(1,temporalProperties.nTimes);
for i=1:size(bombaProperties.nodoBomba,1)
    for iTime = 1:temporalProperties.nTimes
        pTime           = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
        pFEA(iTime,i)     = pTime(bombaProperties.nodoBomba(i));    % Presion en el nodo Bomba calculada por FEA en cada iTime.
    end
end
iTimeInicioISIP = sum(tiempo<=temporalProperties.tInicioISIP)+temporalProperties.drainTimes;
iTimeFinalISIP = sum(tiempo<=temporalProperties.tFinalISIP)+temporalProperties.drainTimes;

plot(tiempo(iTimeInicioISIP-temporalProperties.drainTimes:iTimeFinalISIP-temporalProperties.drainTimes),pFEA(iTimeInicioISIP:iTimeFinalISIP,1)*1e6/6894.76);

clear all
end
%% buff
% load(['resultadosFinISIP_DFIT_DFIT_CorteAumentado_Qextendido_buff.mat'],'iTime','temporalProperties','paramDiscEle','bombaProperties','dTimes')
% 
% 
% if ~exist('temporalProperties.nTimes','var')
%     temporalProperties.nTimes=iTime-1;
% end
% 
% 
% indiceTiempo = temporalProperties.drainTimes+1:temporalProperties.nTimes;
% tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo));
% %- Plot: Presion nodo bomba calculado por FEA.
% pFEA = zeros(1,temporalProperties.nTimes);
% for i=1:size(bombaProperties.nodoBomba,1)
%     for iTime = 1:temporalProperties.nTimes
%         pTime           = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
%         pFEA(iTime,i)     = pTime(bombaProperties.nodoBomba(i));    % Presion en el nodo Bomba calculada por FEA en cada iTime.
%     end
% end
% iTimeInicioISIP = sum(tiempo<=temporalProperties.tInicioISIP)+temporalProperties.drainTimes;
% iTimeFinalISIP = sum(tiempo<=temporalProperties.tFinalISIP)+temporalProperties.drainTimes;
% 
% plot(tiempo(iTimeInicioISIP-temporalProperties.drainTimes:iTimeFinalISIP-temporalProperties.drainTimes),pFEA(iTimeInicioISIP:iTimeFinalISIP,1)*1e6/6894.76);
% 

%% data


T = readtable('Injection Test ITBA.xlsx');

plot(table2array(T(144:436,1))-38,table2array(T(154:446,6))-760,'g','lineWidth',2)
title('ISIP Red de DFN´s')
legend('Perm 1e3','Perm 1e2','Perm 1e1','Data')
