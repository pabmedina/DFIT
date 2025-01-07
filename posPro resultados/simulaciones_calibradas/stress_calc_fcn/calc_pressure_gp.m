function [presionEfectivaPG, strainPorePressure] = calc_pressure_gp(pGaussParam,paramDiscEle,dTimes,times,meshInfo,constitutivas,Biot,temporalProperties)
% Funcion hecha para el re-arreglo de las presiones porales. Se hace
% previo al calculo de tensiones efectivas.

%- Presiones efectivas.
unod = pGaussParam.upg;
presionEfectivaPG = zeros(paramDiscEle.nel,paramDiscEle.nNodEl,6,times);
strainPorePressure = zeros(paramDiscEle.nel,paramDiscEle.nNodEl,6,times);
for itime = 1:1:times
    pressureTimes = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,itime)*temporalProperties.preCond;
    for iele = 1:paramDiscEle.nel
        for nP = 1:size(unod,1)
            
            ksi  = unod(nP,1);
            eta  = unod(nP,2);
            zeta = unod(nP,3);
            
            % Funciones de forma
            
            N = [ (1-ksi)*(1-eta)*(1+zeta)/8, (1-ksi)*(1-eta)*(1-zeta)/8, (1-ksi)*(1+eta)*(1-zeta)/8....
                (1-ksi)*(1+eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1-zeta)/8....
                (1+ksi)*(1+eta)*(1-zeta)/8, (1+ksi)*(1+eta)*(1+zeta)/8 ];
            
            N = N(1,[8,4,1,5,7,3,2,6]);
            
            %             presionEfectiva(iele,nP,:) = (Biot{iele}(:,:,nP)*N*pressureTimes(meshInfo.elements(iele,:)))'+ (Biot{iele}(:,:,nP)*initialPPoral)';
            presionEfectivaPG(iele,nP,:,itime) = (Biot{iele}(:,:,nP)*N*pressureTimes(meshInfo.elements(iele,:)))';
            p = [presionEfectivaPG(iele,nP,1);presionEfectivaPG(iele,nP,2);presionEfectivaPG(iele,nP,3);presionEfectivaPG(iele,nP,4);presionEfectivaPG(iele,nP,5);presionEfectivaPG(iele,nP,6)];
            strainPorePressure(iele,nP,:,itime) = constitutivas{iele}(:,:,nP)\ p;
        end
    end
end
end

