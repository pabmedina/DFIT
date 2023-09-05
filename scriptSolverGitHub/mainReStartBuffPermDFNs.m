clc 
clearvars
close

kappa = 100;
nKappa = size(kappa,1);
factorImprove = [ 1e3 1e4 1e5 1e6 2.5e6 5e6 ]';
nCase = size(factorImprove,1);

for iCase = 6
    for iKappa = 1:nKappa
        mainDfit_rev082023PMV2ReStartPerm
    end
end