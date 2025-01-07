function [stress_eff,strain_eff] = calc_stress_tot(times,paramDiscEle,pGaussParam,meshInfo,C,dTimes,initialSrainSolPG)
% Funcion que calcula las tensiones EFECTVAS para todos los tiempos de
% simulaciones.
unod = pGaussParam.upg;
stress_eff = zeros(paramDiscEle.nel,paramDiscEle.nNodEl,6,times);
strain_eff = zeros(paramDiscEle.nel,paramDiscEle.nNodEl,6,times);
for itime = 1:1:times
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
           
            stress_eff(iele,npg,:,itime) = (C{iele}(:,:,npg))*B*dTimes(eleDofs,itime) + (C{iele}(:,:,npg))*initialSrainSolPG{iele}(:,npg);
            strain_eff(iele,npg,:,itime) = B*dTimes(eleDofs,itime) + initialSrainSolPG{iele}(:,npg);
        end
    end
end

end

