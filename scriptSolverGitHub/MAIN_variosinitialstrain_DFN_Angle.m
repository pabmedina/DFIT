
nCasos=1;

strain0=zeros(6,nCasos);

strain0(3,:) =-2e-3;

strain0(1:2,:)=[-3;-3].*10^-4;
% 
% strain0(1:2,:)=[-4   -5 -4   -5 -5;
%                 -1.5 -2 -2.5 -3 -1].*10^-4;
   
            
for i=1:nCasos
     initialStrainExtS=strain0(:,i);
     nombreCorrida=['DFIT_DFN_github_paraview' ];
     Copy_mainDfit_rev082023PM_SOv2_variassPerm
end