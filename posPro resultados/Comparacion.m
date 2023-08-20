% Comparación corridas
mpa2psi = 145.038;

% Path de resultados a comparar
addpath('/Users/leilafraga/Documents/GitHub/DFIT/Resultados de corridas (.mat)/DFIT_TrialSRV18_2')
addpath('/Users/leilafraga/Documents/GitHub/DFIT/Resultados de corridas (.mat)/DFIT_TrialSRV19_2')

% Nombre de los archivos con los datos a comparar
file1 = 'resultadosCorrida_DFIT_TrialSRV18.mat';
file2 = 'resultadosCorrida_DFIT_TrialSRV19.mat';

% Carga, filtro y verificación de los datos a comparar
val1 = load(file1, 'dTimes', 'paramDiscEle', 'bombaProperties');
dofParam1 = val1.paramDiscEle;
ndofU1 = dofParam1.nDofTot_U;
ndofP1 = dofParam1.nDofTot_P;
dTimes1 = val1.dTimes;
nodoBomba1 = val1.bombaProperties.nodoBomba(1);

val2 = load(file2, 'dTimes', 'paramDiscEle', 'bombaProperties');
dofParam2 = val2.paramDiscEle;
ndofU2 = dofParam2.nDofTot_U;
ndofP2 = dofParam2.nDofTot_P;
dTimes2 = val2.dTimes;
nodoBomba2 = val2.bombaProperties.nodoBomba(1);


if size(dTimes1,2) ~= size(dTimes2,2)
    warning('Las corridas a comparar no poseen la misma cantidad de tiempos.')
    s1 = size(dTimes1,2);
    s2 = size(dTimes2,2);
    cut = s1 - s2;
    if cut > 0
        dTimes1 = dTimes1(:,1:end-cut);
    else
        dTimes2 = dTimes2(:,1:end+cut);
    end
end

dTimes1U = dTimes1(1:ndofU1,:);
dTimes1P = dTimes1(ndofU1+1:ndofU1+ndofP1,:);

dTimes2U = dTimes2(1:ndofU2,:);
dTimes2P = dTimes2(ndofU2+1:ndofU2+ndofP2,:);

% Análisis
deltaU = dTimes1U - dTimes2U;
stdU = std(deltaU);
idU = stdU == max(stdU);
maxErrU = deltaU(:,idU)./dTimes1U(:,idU);

deltaP = dTimes1P - dTimes2P;
stdP = std(deltaP);
idP = stdP == max(stdP);
maxErrP = deltaP(:,idP)./dTimes1P(:,idP);

% Plots
figure
plot(1:size(dTimes1,2), stdU, '-r')
xlabel('iTime')
ylabel('std desplazamientos')
title(['La máxima desviación es en el tiempo ', num2str(find(idU))])

figure
plot(1:size(dTimes1,2), stdP, '-b')
xlabel('iTime')
ylabel('std presiones')
title(['La máxima desviación es en el tiempo ', num2str(find(idP))])

figure
plot(1:size(dTimes1P,2), dTimes1P(nodoBomba1,:)*mpa2psi, '-', 'LineWidth', 2)
hold on
plot(1:size(dTimes2P,2), dTimes2P(nodoBomba2,:)*mpa2psi, ':', 'LineWidth', 2)
legend('Presión 1', 'Presión 2')
title('Presión en el nodo bomba')
xlabel('iTime')
ylabel('Presión [psi]')


