clc, close all  
clearvars
numeroDeNodosBomba = 3;

cutOff = 12000;
%% Datos Excel
plotCurvaPiloto=1; %Pararlo porque despues hay un close all
mPa2psi = 145;

mainFolder = 'D:\Geomec\paper DFN\ITBA\Piloto\DFIT\'; % el mainFolder cambia segun usuario

if plotCurvaPiloto
    addpath('D:\Geomec\paper DFN\ITBA\Piloto\DFIT\posPro resultados\')
    [num, ~, ~] = xlsread('Injection Test ITBA Limpiado.xlsx');
    
    tiempoRelevado=num(:,1);
    bhpRelevado = num(:,6);
    caudalRelevado = num(:,8);
    
    tiempoRelevado = tiempoRelevado - 37;
    % presion relevada
    figure
    yyaxis left; % Asignar el eje izquierdo a la primera curva
    plot(tiempoRelevado,bhpRelevado,'b-')
    ylabel('Presion PSI');
    yyaxis right; % Asignar el eje derecho a la segunda curva
    plot(tiempoRelevado,caudalRelevado,'r')
    ylabel('Caudal BPM');
    title('Curva de Presiones y caudal en todo el DFIT')
    
    % presion relevado solo ISIP
    
    tiempoISIPRelevado = 127;
    figure;
    x=tiempoRelevado(tiempoISIPRelevado:end);
    y1=bhpRelevado(tiempoISIPRelevado:end);
    y2=caudalRelevado(tiempoISIPRelevado:end);
    yyaxis left; % Asignar el eje izquierdo a la primera curva
    plot(x, y1, 'b-');
    ylabel('Presion PSI');
    yyaxis right; % Asignar el eje derecho a la segunda curva
    plot(x, y2, 'r-');
    ylabel('Caudal BPM');
    title('Curva de Presiones y caudal en ISIP')
end

%% Levantamos lo resultado de corridas

%% DFIT
currentDirec = cd('D:\Geomec\paper DFN\ITBA\Piloto\DFIT\Resultados de corridas (.mat)');
load([currentDirec '\DFIT_NoRef\resultadosFinISIP_DFIT_NoRef.mat']);


p_DFIT_FEA=dTimes(paramDiscEle.nDofTot_U+bombaProperties.nodoBomba(1),5:end)*mPa2psi;
q_DFIT_FEA=QTimes(bombaProperties.nodoBomba(1),5:end)*numeroDeNodosBomba*2;
Tiempos_DFIT=cumsum(temporalProperties.deltaTs(temporalProperties.drainTimes+1:end));
iTimeInicioIsip_DFIT=find(Tiempos_DFIT>=temporalProperties.tInicioISIP,1); %Sin contar DrainTimes

boolCleanData = false(size(p_DFIT_FEA,1),1);
% boolCleanData(p_DFIT_FEA>cutOff) = true;
p_DFIT_FEA(boolCleanData) = []; 
q_DFIT_FEA(boolCleanData) = []; 
Tiempos_DFIT(boolCleanData) = []; 

% DFIT simulado
figure
hold on
yyaxis left; 
plot(Tiempos_DFIT,p_DFIT_FEA,'b')
ylabel('Presion PSI');
plot(tiempoRelevado,bhpRelevado,'r-')
yyaxis right; % Asignar el eje derecho a la segunda curva
plot(Tiempos_DFIT,q_DFIT_FEA,'g')
ylabel('Caudal BPM');
title('Curva de Presiones y caudal en todo el DFIT')
xlim([20 350])


figure
plot(Tiempos_DFIT(iTimeInicioIsip_DFIT:end),p_DFIT_FEA(iTimeInicioIsip_DFIT:end))
hold on
plot(x,y1,'r')

%% DFIT WI
currentDirec = cd('D:\Geomec\paper DFN\ITBA\Piloto\DFIT\Resultados de corridas (.mat)');
load([currentDirec '\DFIT_WINoRef\resultadosFinISIP_DFIT_WINoRef.mat']);


p_DFITWI_FEA=dTimes(paramDiscEle.nDofTot_U+bombaProperties.nodoBomba(1),5:end)*mPa2psi;
q_DFITWI_FEA=QTimes(bombaProperties.nodoBomba(1),5:end)*numeroDeNodosBomba*2;
Tiempos_WI=cumsum(temporalProperties.deltaTs(temporalProperties.drainTimes+1:end));
iTimeInicioIsip_WI=find(Tiempos_WI>=temporalProperties.tInicioISIP,1); %Sin contar DrainTimes

boolCleanData = false(size(p_DFITWI_FEA,1),1);
% boolCleanData(p_DFIT_FEA>cutOff) = true;
p_DFITWI_FEA(boolCleanData) = []; 
q_DFITWI_FEA(boolCleanData) = []; 
Tiempos_WI(boolCleanData) = []; 

% DFIT WI simulado
figure
hold on
yyaxis left; 
plot(Tiempos_WI,p_DFITWI_FEA,'b')
ylabel('Presion PSI');
plot(tiempoRelevado,bhpRelevado,'r-')
yyaxis right; % Asignar el eje derecho a la segunda curva
plot(Tiempos_WI,q_DFITWI_FEA,'g')
ylabel('Caudal BPM');
title('Curva de Presiones y caudal en todo el DFIT')
xlim([20 350])


figure
plot(Tiempos_WI(iTimeInicioIsip_WI:end),p_DFITWI_FEA(iTimeInicioIsip_WI:end))
hold on
plot(x,y1,'r')


%% DFIT DFN
currentDirec = cd('D:\Geomec\paper DFN\ITBA\Piloto\DFIT\Resultados de corridas (.mat)');
load([currentDirec '\DFIT_DFNNoRef\resultadosFinISIP_DFIT_DFNNoRef.mat']);

p_DFITDFN_FEA=dTimes(paramDiscEle.nDofTot_U+bombaProperties.nodoBomba(1),5:end)*mPa2psi;
q_DFITDFN_FEA=QTimes(bombaProperties.nodoBomba(1),5:end)*numeroDeNodosBomba*2;
Tiempos_DFN=cumsum(temporalProperties.deltaTs(temporalProperties.drainTimes+1:end));
iTimeInicioIsip_DFN=find(Tiempos_DFN>=temporalProperties.tInicioISIP,1); %Sin contar DrainTimes

% DFIT DFN simulado
figure
hold on
yyaxis left; 
plot(Tiempos_DFN,p_DFITDFN_FEA,'b')
ylabel('Presion PSI');
plot(tiempoRelevado,bhpRelevado,'r-')
yyaxis right; % Asignar el eje derecho a la segunda curva
plot(Tiempos_DFN,q_DFITDFN_FEA,'g')
ylabel('Caudal BPM');
title('Curva de Presiones y caudal en todo el DFIT')
xlim([20 350])

figure
plot(Tiempos_DFN(iTimeInicioIsip_WI:end),p_DFITDFN_FEA(iTimeInicioIsip_WI:end))
hold on
plot(x,y1,'r')

% TODO junto
figure
hold on
yyaxis left; 
plot(Tiempos_DFIT,p_DFIT_FEA,'b')
plot(Tiempos_WI,p_DFITWI_FEA,'r')
plot(Tiempos_DFN,p_DFITDFN_FEA,'g')
plot(tiempoRelevado,bhpRelevado,'k-')
ylabel('Presion PSI');
yyaxis right; % Asignar el eje derecho a la segunda curva
plot(Tiempos_DFN,q_DFITDFN_FEA,'m')
ylabel('Caudal BPM');
xlim([20 350])
ylim([9000 13000])

close all
%% Ploteamos Todo Junto
[num, txt, ~] = xlsread('Injection Test ITBA.xlsx');

figure
hold on

%% Plot ISIP

% plot(Tiempos_DFIT(iTimeInicioIsip_DFIT:end),ValoresP_DFIT(iTimeInicioIsip_DFIT:end).*145.038,'b-')
% plot(Tiempos_WI(iTimeInicioIsip_WI:end),ValoresP_WI(iTimeInicioIsip_WI:end).*145.038,'r')
% plot(Tiempos_DFN(iTimeInicioIsip_DFN:end),ValoresP_DFN(iTimeInicioIsip_DFN:end).*145.038,'g-')
% plot(90:392,num(127:429,2),'k');

%% Plot Corrida ajustada

plot(Tiempos_DFIT,p_DFIT_FEA.*145.038,'b*')
plot(Tiempos_WI,p_DFITWI_FEA.*145.038,'r')
plot(Tiempos_DFN,ValoresP_DFN.*145.038,'g-')
plot(1:390,num(31:420,2),'k'); %31 equivaldria al segundo 30

legend('Presion DFIT','Presion DFIT WI','Presion DFIT DFN','Data Piloto')

xlabel('Tiempo [s]')
ylabel('Presion [MPa]')
title('Presion vs Tiempo')
ylim([0 16000])
