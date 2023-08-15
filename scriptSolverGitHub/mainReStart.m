
clear;clc;close all; format shortg;
vectorDeCasos = [ 1 2 3 4 5 6 15 20 ];
nCasos = length(vectorDeCasos);
improvePerm = 1; idCasos = 1;
for i = 8:nCasos
    clear improvePerm id
    improvePerm = vectorDeCasos(i); idCasos=num2str(i);
    mainDfitDFN_rev052022_0723ReStart
    clearvars -except vectorDeCasos nCasos
end