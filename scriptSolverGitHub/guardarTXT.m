indiceTiempo = temporalProperties.drainTimes+1:temporalProperties.nTimes;
tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo));
pFEA = zeros(1,temporalProperties.nTimes);
for iTime = 1:temporalProperties.nTimes
    pTime           = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
    pFEA(:,iTime)     = pTime(bombaProperties.nodoBomba(1));    % Presion en el nodo Bomba calculada por FEA en cada iTime.
end

%% Tiempos
fid = fopen(['tiempo_',nombreCorrida,'.txt'],'wt');
fprintf(fid,'%.6f\n',tiempo);
fclose(fid);
%% Presiones
p = pFEA(1,temporalProperties.drainTimes+1:end)*1e6/6894.76;
fid = fopen(['presion_',nombreCorrida,'.txt'],'wt');
fprintf(fid,'%.6f\n',p);

fclose('all');
%% Caudales
Q = QTimes(bombaProperties.nodoBomba,temporalProperties.drainTimes+1:end);
fid = fopen(['Q_',nombreCorrida,'.txt'],'wt');
fprintf(fid,'%.6f\n',Q);

fclose('all');
