function stressAtiTime = stressAtTime(iTimeEspecifico, constitutivas, pGaussParam, paramDiscEle, meshInfo, dTimes, temporalProperties, Biot)
%{

La función calcula las tensiones para el iTimeEspecifico ingresado

iTimeEspecifico(calcTensionesenDrainTimes) = 2 <= drainTime.txt
iTimeEspecifico(calcTensionesenInicioISIP): 
          indiceTiempo = temporalProperties.drainTimes+1:iTime;
          tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo));
          iTimeEspecifico = find((tiempo>temporalProperties.tInicioISIP)); 
          iTimeEspecifico = iTime(1);
iTimeEspecifico(calcTensionesenISIP) =  iTime-1

%}

%- Tensiones. (Solo esta calculando para un tiempo en particular)
unod = pGaussParam.upg; 
stress = zeros(paramDiscEle.nel,paramDiscEle.nNodEl,6); %cell(nnodel,size(constitutivas{1},1),nel,length(Time));
for itime = iTimeEspecifico
    for iele = 1:paramDiscEle.nel 
        nodesEle = meshInfo.nodes(meshInfo.elements(iele,:),:);

        for npg = 1:size(unod,1)
        
            % Puntos nodales
            ksi  = unod(npg,1);
            eta  = unod(npg,2);
            zeta = unod(npg,3);

            % Derivadas de las funciones de forma respecto de ksi, eta, zeta         
  
            % Derivadas de las funciones de forma respecto de ksi, eta, zeta
            dN = [ ((eta - 1)*(zeta + 1))/8, -((eta - 1)*(zeta - 1))/8, ((eta + 1)*(zeta - 1))/8, -((eta + 1)*(zeta + 1))/8, -((eta - 1)*(zeta + 1))/8, ((eta - 1)*(zeta - 1))/8, -((eta + 1)*(zeta - 1))/8, ((eta + 1)*(zeta + 1))/8
                ((ksi - 1)*(zeta + 1))/8, -((ksi - 1)*(zeta - 1))/8, ((ksi - 1)*(zeta - 1))/8, -((ksi - 1)*(zeta + 1))/8, -((ksi + 1)*(zeta + 1))/8, ((ksi + 1)*(zeta - 1))/8, -((ksi + 1)*(zeta - 1))/8, ((ksi + 1)*(zeta + 1))/8
                ((eta - 1)*(ksi - 1))/8,  -((eta - 1)*(ksi - 1))/8,  ((eta + 1)*(ksi - 1))/8,  -((eta + 1)*(ksi - 1))/8,  -((eta - 1)*(ksi + 1))/8,  ((eta - 1)*(ksi + 1))/8,  -((eta + 1)*(ksi + 1))/8,  ((eta + 1)*(ksi + 1))/8 ];
            
            dN = dN(:,[8,4,1,5,7,3,2,6]);

            jac = dN*nodesEle;                

            % Derivadas de las funciones de forma respecto de x,y,z
            dNxyz = jac\dN;          % dNxyz = inv(jac)*dN
            
            B = zeros(6,paramDiscEle.nDofEl);

            B(1,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
            B(2,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:); 
            B(3,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
            B(4,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
            B(4,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
            B(5,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
            B(5,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
            B(6,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
            B(6,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);

            eleDofs = paramDiscEle.nodeDofs(meshInfo.elements(iele,:),:);
            eleDofs = reshape(eleDofs',[],1);

            stress(iele,npg,:) = (constitutivas{iele}(:,:,npg))*B*dTimes(eleDofs,itime); %+ initialStressSolPG{iele}(:,npg);
        end
    end
end

%- Presiones efectivas.
presionEfectiva = zeros(paramDiscEle.nel,paramDiscEle.nNodEl,6);
for itime = iTimeEspecifico
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

            presionEfectiva(iele,nP,:) = (Biot{iele}(:,:,nP)*N*pressureTimes(meshInfo.elements(iele,:)))';
        end
    end
end


tensionEfectiva = stress - presionEfectiva;

%% Exptrapolacion de valores en puntos de gauss al centro
% Para plotear necesito los valores nodales asique extrapolo los
% valores en los puntos de gauss a los nodos y hago el promedio de cada
% elementos.
% unodNodal            = pGaussParam.upg*3;

tensionEfectivaNodal = zeros(paramDiscEle.nel,6) ;
for iele = 1:paramDiscEle.nel
    
    ksi  = 0;   %unodNodal(ipg,1);
    eta  = 0;   %unodNodal(ipg,2);
    zeta = 0;   %unodNodal(ipg,3);
    
    % Funciones de forma
    N = [ (1-ksi)*(1-eta)*(1+zeta)/8, (1-ksi)*(1-eta)*(1-zeta)/8, (1-ksi)*(1+eta)*(1-zeta)/8....
        (1-ksi)*(1+eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1-zeta)/8....
        (1+ksi)*(1+eta)*(1-zeta)/8, (1+ksi)*(1+eta)*(1+zeta)/8 ];
    
    N = N(1,[8,4,1,5,7,3,2,6]);
    
    % Extrapolacion de puntos de gauss a nodos.
    tensionEfectivaNodal(iele,1) = N*tensionEfectiva(iele,:,1)';
    tensionEfectivaNodal(iele,2) = N*tensionEfectiva(iele,:,2)';
    tensionEfectivaNodal(iele,3) = N*tensionEfectiva(iele,:,3)';
    tensionEfectivaNodal(iele,4) = N*tensionEfectiva(iele,:,4)';
    tensionEfectivaNodal(iele,5) = N*tensionEfectiva(iele,:,5)';
    tensionEfectivaNodal(iele,6) = N*tensionEfectiva(iele,:,6)';
    
end

stressAtiTime = zeros(paramDiscEle.nel,1);

for iele=1:paramDiscEle.nel
    stressAtiTime(iele) = tensionEfectivaNodal(iele,1)+tensionEfectivaNodal(iele,2)+tensionEfectivaNodal(iele,3);
end


end