clc 
clearvars
close

kappa = [0.1 1 10 100]';
nCase = size(kappa,1);

for iCase = 1:nCase
    mainDfit_rev082023PMV2ReStartPerm
end