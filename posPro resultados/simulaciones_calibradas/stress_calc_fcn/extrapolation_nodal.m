function [field_nodal_1, field_nodal_2] = extrapolation_nodal(times,pGaussParam,paramDiscEle,field_gp_1, field_gp_2)
% Extrapola un campo desde sus puntos de gauss (gp) a sus valores nodales. Este
% caso esta hecho para tensiones pero deberia ser indistinto. El caso es
% para elementos H8.

u_nod_nodal  = pGaussParam.upg*3;
field_nodal_1 = zeros(paramDiscEle.nel,8,6,times) ;
field_nodal_2 = zeros(paramDiscEle.nel,8,6,times) ;
for itime = 1:1:times
    for iele = 1:paramDiscEle.nel
        for ipg = 1:size(u_nod_nodal,1)
            
            ksi  = u_nod_nodal(ipg,1);
            eta  = u_nod_nodal(ipg,2);
            zeta = u_nod_nodal(ipg,3);
            
            % Funciones de forma
            N = [ (1-ksi)*(1-eta)*(1+zeta)/8, (1-ksi)*(1-eta)*(1-zeta)/8, (1-ksi)*(1+eta)*(1-zeta)/8....
                (1-ksi)*(1+eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1-zeta)/8....
                (1+ksi)*(1+eta)*(1-zeta)/8, (1+ksi)*(1+eta)*(1+zeta)/8 ];
            
            N = N(1,[8,4,1,5,7,3,2,6]);
            % Extrapolacion de puntos de gauss a nodos.
            field_nodal_1(iele,ipg,1,itime) = N*field_gp_1(iele,:,1)';
            field_nodal_1(iele,ipg,2,itime) = N*field_gp_1(iele,:,2)';
            field_nodal_1(iele,ipg,3,itime) = N*field_gp_1(iele,:,3)';
            field_nodal_1(iele,ipg,4,itime) = N*field_gp_1(iele,:,4)';
            field_nodal_1(iele,ipg,5,itime) = N*field_gp_1(iele,:,5)';
            field_nodal_1(iele,ipg,6,itime) = N*field_gp_1(iele,:,6)';
            
            field_nodal_2(iele,ipg,1,itime) = N*field_gp_2(iele,:,1)';
            field_nodal_2(iele,ipg,2,itime) = N*field_gp_2(iele,:,2)';
            field_nodal_2(iele,ipg,3,itime) = N*field_gp_2(iele,:,3)';
            field_nodal_2(iele,ipg,4,itime) = N*field_gp_2(iele,:,4)';
            field_nodal_2(iele,ipg,5,itime) = N*field_gp_2(iele,:,5)';
            field_nodal_2(iele,ipg,6,itime) = N*field_gp_2(iele,:,6)';
        end
    end
end
end

