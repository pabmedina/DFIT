
nCasos=7;

strain0=zeros(6,nCasos);

strain0(3,:) =-2e-3;

strain0(1:2,:)=[-6   -4.5 -3   -1.5 -6 -3 -6;
                -1.5 -1.5 -1.5 -1.5 -3 -3 -6].*10^-4;
            
for i=1:nCasos
     initialStrainExtS=strain0(:,i);
     nombreCorrida=['DFN_Angle_github_new_' num2str(i)];
     mainDfit_rev082023_variosInitialStrain
end