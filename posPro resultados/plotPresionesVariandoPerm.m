clc, close all 
clearvars 

mainFolder = 'D:\Geomec\paper DFN\ITBA\Piloto\DFIT\';
pathAdderV2
resultsFolder = str5;

deltaP_Dyn = 1390; %Asumimos una cierta cantidad de psi
resultFolder1 = 'DFIT_redDFN_v1\';
resultFolder2 = 'DFIT_redDFN_v2\';
resultFolder3 = 'DFIT_redDFN_v3\';
resultFolder4 = 'DFIT_triple_b1\'; 

result = [ resultFolder1 ; resultFolder2 ; resultFolder3 ; resultFolder4];

addpath([resultsFolder, resultFolder1])
addpath([resultsFolder, resultFolder2])
addpath([resultsFolder, resultFolder3])
addpath([resultsFolder, resultFolder4])
figure; hold on
%% estandar
for i=1:size(result,1)
    if i<4
        load(['resultadosFinISIP_' result(i,1:end-1) '.mat'],'iTime','temporalProperties','paramDiscEle','bombaProperties','dTimes')
    else
        load(['resultadosCorrida_' result(i,1:end-1) '.mat'],'iTime','temporalProperties','paramDiscEle','bombaProperties','dTimes')
    end
    
    if ~exist('temporalProperties.nTimes','var')
        temporalProperties.nTimes=iTime-1;
    end

    indiceTiempo = temporalProperties.drainTimes+1:temporalProperties.nTimes;
    tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo));
    %- Plot: Presion nodo bomba calculado por FEA.
    pFEA = zeros(1,temporalProperties.nTimes);
    for j=1:size(bombaProperties.nodoBomba,1)
        for iTime = 1:temporalProperties.nTimes
            pTime          = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
            pFEA(iTime,j)  = pTime(bombaProperties.nodoBomba(j));    % Presion en el nodo Bomba calculada por FEA en cada iTime.
        end
    end
    iTimeInicioISIP = sum(tiempo<=temporalProperties.tInicioISIP)+temporalProperties.drainTimes;
    iTimeFinalISIP = sum(tiempo<=temporalProperties.tFinalISIP)+temporalProperties.drainTimes;
    
    plot(tiempo(iTimeInicioISIP-temporalProperties.drainTimes:iTimeFinalISIP-temporalProperties.drainTimes),pFEA(iTimeInicioISIP:iTimeFinalISIP,1)*1e6/6894.76);
    
    clear temporalProperties bombaProperties dTimes iTime
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

tiempoCrudo = table2array(T(130:430,1)); % 300 segundos de DFIT
presionCruda = table2array(T(130:430,6)); % valor de presion para los 300 segundos de declinacion 
corrimientoEnX = -33; % en toria voy a estar corriendo 33 segundos el problema. Porque el tiempo de fractura lo reduje

tiempoCorregido = tiempoCrudo + corrimientoEnX;
presionCorregida = presionCruda - deltaP_Dyn;
plot(tiempoCrudo,presionCruda,'g','lineWidth',2)
plot(tiempoCorregido,presionCorregida,'m','lineWidth',2)
title('ISIP Red de DFN´s')
legend('Perm 1e3','Perm 1e2','Perm 1e1','Data')
