clc, close all 
clearvars 

mainFolder = 'D:\Geomec\paper DFN\ITBA\Piloto\DFIT\'; 
pathAdderV3
resultsFolder = str5;
wantOnlyISIP = false;

deltaP_Dyn = 1800-60; %Asumimos una cierta cantidad de psi
numberOfFolders = 5;

dataRead = 'kappaDFN_{100}';%'kappaDFN_{10}'; %'kappaDFN_{1}'; %'kappaDFN_{0.1}';%  
resultFolder1 = 'DFIT_WIplusDFNs_permNerfDFNsKappaBase\'; % corridaBase

switch dataRead
    case 'kappaDFN_{0.1}'
        resultFolder2 = 'DFIT_WIplusDFNs_permNerfDFNsKappaVariable1\'; % a la corridaBase le damos una permeabilidad de DFN (kappaDFN = 0.1)
        resultFolder3 = 'DFIT_WIplusDFNs_permBuffKappa0.1ISIP1\'; % a la corrida base + el kappaDFN = 0.1 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e3)
        resultFolder4 = 'DFIT_WIplusDFNs_permBuffKappa0.1ISIP2\'; % a la corrida base + el kappaDFN = 0.1 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e4)
        resultFolder5 = 'DFIT_WIplusDFNs_permBuffKappa0.1ISIP3\'; % a la corrida base + el kappaDFN = 0.1 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e5)
    case 'kappaDFN_{1}'
        resultFolder2 = 'DFIT_WIplusDFNs_permNerfDFNsKappaVariable2\'; % a la corridaBase le damos una permeabilidad de DFN (kappaDFN = 1)
        resultFolder3 = 'DFIT_WIplusDFNs_permBuffKappa1ISIP1\'; % a la corrida base + el kappaDFN = 1 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e3)
        resultFolder4 = 'DFIT_WIplusDFNs_permBuffKappa1ISIP2\'; % a la corrida base + el kappaDFN = 1 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e4)
        resultFolder5 = 'DFIT_WIplusDFNs_permBuffKappa1ISIP3\'; % a la corrida base + el kappaDFN = 1 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e5)   
    case 'kappaDFN_{10}'
        resultFolder2 = 'DFIT_WIplusDFNs_permNerfDFNsKappaVariable3\'; % a la corridaBase le damos una permeabilidad de DFN (kappaDFN = 1)
        resultFolder3 = 'DFIT_WIplusDFNs_permBuffKappa10ISIP1\'; % a la corrida base + el kappaDFN = 10 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e3)
        resultFolder4 = 'DFIT_WIplusDFNs_permBuffKappa10ISIP2\'; % a la corrida base + el kappaDFN = 10 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e4)
        resultFolder5 = 'DFIT_WIplusDFNs_permBuffKappa10ISIP3\'; % a la corrida base + el kappaDFN = 10 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e5) 
    case 'kappaDFN_{100}'
        resultFolder2 = 'DFIT_WIplusDFNs_permNerfDFNsKappaVariable4\'; % a la corridaBase le damos una permeabilidad de DFN (kappaDFN = 1)
        resultFolder3 = 'DFIT_WIplusDFNs_permBuffKappa100ISIP1\'; % a la corrida base + el kappaDFN = 100 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e3)
        resultFolder4 = 'DFIT_WIplusDFNs_permBuffKappa100ISIP2\'; % a la corrida base + el kappaDFN = 100 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e4)
        resultFolder5 = 'DFIT_WIplusDFNs_permBuffKappa100ISIP3\'; % a la corrida base + el kappaDFN = 100 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e5) 
        resultFolder6 = 'DFIT_WIplusDFNs_permBuffKappa100ISIP4\'; % a la corrida base + el kappaDFN = 100 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 1e6)
        resultFolder7 = 'DFIT_WIplusDFNs_permBuffKappa100ISIP5ReStartBilineal\'; % a la corrida base + el kappaDFN = 100 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 2.5e6)
        resultFolder8 = 'DFIT_WIplusDFNs_permBuffKappa100ISIP6\'; % a la corrida base + el kappaDFN = 100 le aumentamos el SRV en funcion del invariante. (ImproveFactor = 5e6)
        resultFolder9 = 'DFIT_WIplusDFNs_permNerfFractSensivity1\';
        resultFolder10 = 'DFIT_WIplusDFNs_permNerfFractSensivityMiniDFNs0\';
        resultFolder11 = 'DFIT_WIplusDFNs_permNerfFractSensivityMiniDFNs1\';
        resultFolder12 = 'DFIT_WIplusDFNs_permNerfFractSensivityMiniDFNs3\';
        resultFolder13 = 'DFIT_WIplusDFNs_permNerfFractSensivity5\';
        resultFolder14 = 'DFIT_WIplusDFNs_permBuffFractSensivityMiniDFNs4DFNs1\';
        resultFolder15 = 'DFIT_WIplusDFNs_permBuffFractSensivityMiniDFNs4DFNs2\';
        resultFolder16 = 'DFIT_WIplusDFNs_permBuffFractSensivityMiniDFNs4DFNs5\';
        
        
%         resultFolder10 = 'DFIT_WIplusDFNs_permNerfFractSensivity2\';
end

% resultFolder1 = 'DFIT_redDFN_v1\';
% resultFolder2 = 'DFIT_redDFN_v2\';
% resultFolder3 = 'DFIT_redDFN_v3\';
% resultFolder4 = 'DFIT_triple_b1\'; 
result = {numberOfFolders};
result{1} = resultFolder1; result{2} = resultFolder2; 
result{3} = resultFolder3; result{4} = resultFolder4; 
result{5} = resultFolder5; result{6} = resultFolder6; 
result{7} = resultFolder7; result{8} = resultFolder8;
result{9} = resultFolder9; result{10} = resultFolder10;
result{11} = resultFolder11; result{12} = resultFolder12;
result{13} = resultFolder13;  result{14} = resultFolder14; 
result{15} = resultFolder15;  result{16} = resultFolder16; 
% result = [ resultFolder1 ; resultFolder2 ; resultFolder3 ; resultFolder4];

addpath([resultsFolder, resultFolder1])
addpath([resultsFolder, resultFolder2])
addpath([resultsFolder, resultFolder3])
addpath([resultsFolder, resultFolder4])
addpath([resultsFolder, resultFolder5])
addpath([resultsFolder, resultFolder6])
addpath([resultsFolder, resultFolder7])
addpath([resultsFolder, resultFolder8])
addpath([resultsFolder, resultFolder9])
addpath([resultsFolder, resultFolder10])
addpath([resultsFolder, resultFolder11])
addpath([resultsFolder, resultFolder12])
addpath([resultsFolder, resultFolder13])
addpath([resultsFolder, resultFolder14])
addpath([resultsFolder, resultFolder15])
addpath([resultsFolder, resultFolder16])
figure; hold on
%% estandar
p = {numberOfFolders};
for i=11:size(result,2)
    
%     load(['resultadosFinISIP_' result{i}(1:end-1) '.mat'],'iTime','temporalProperties','paramDiscEle','bombaProperties','dTimes')
    load(['resultadosCorrida_' result{i}(1:end-1) '.mat'],'iTime','temporalProperties','paramDiscEle','bombaProperties','dTimes')
 
    
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
    
    pRawAll = pFEA(temporalProperties.drainTimes+1:iTimeFinalISIP)*1e6/6894.76;
    pCorregidaAll = pFEA(temporalProperties.drainTimes+1:iTimeFinalISIP)*1e6/6894.76 + deltaP_Dyn;
    
    pRawISIP = pFEA(iTimeInicioISIP:iTimeFinalISIP,1)*1e6/6894.76;
    pCorregidaISIP = pFEA(iTimeInicioISIP:iTimeFinalISIP,1)*1e6/6894.76 + deltaP_Dyn;
    
    if wantOnlyISIP
        p{i} = plot(tiempo(iTimeInicioISIP-temporalProperties.drainTimes:iTimeFinalISIP-temporalProperties.drainTimes),pCorregidaISIP);
    else % solo si se quiere plotear fractura + ISIP
       
        p{i} = plot(tiempo(temporalProperties.drainTimes+1:iTimeFinalISIP),pCorregidaAll);

    end
   
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

tiempoCrudoISIP = table2array(T(122:430,1)); % 300 segundos de DFIT
presionCrudaISIP = table2array(T(122:430,6)); % valor de presion para los 300 segundos de declinacion 

tiempoCrudoAll = table2array(T(33:430,1));
presionCrudaAll = table2array(T(33:430,6));

corrimientoEnX = -33; % en toria voy a estar corriendo 33 segundos el problema. Porque el tiempo de fractura lo reduje
tiempoCorregidoISIP = tiempoCrudoISIP + corrimientoEnX;
tiempoCorregidoAll = tiempoCrudoAll - 21;

% presionCorregida = presionCruda - deltaP_Dyn;
% plot(tiempoCrudo,presionCruda,'g','lineWidth',2)
if wantOnlyISIP
    d = plot(tiempoCorregidoISIP,presionCrudaISIP,'m','lineWidth',2);
else
    d = plot(tiempoCorregidoAll,presionCrudaAll,'m','lineWidth',2);
end
title(['ISIP DFNs vs Data' dataRead])
legend([ p{11} p{12} p{13} p{14} p{15} p{16}  d ],'miniDFNS2' ,'miniDFNS3' ,'kappa alto','mini4DFNS1','mini4DFNS2','mini4DFNS3','DATA1031h')
grid minor
xlim([50 200])
% legend([p{7} p{9} p{13}  d ],'Base',['Base' dataRead],[dataRead 'f=1e3'],[dataRead 'f=1e4'],[dataRead 'f=1e5'],[dataRead 'f=1e6'],[dataRead 'f=2.5e6'],[dataRead 'f=5e6'],'DATA1031h')

