% %% Current path
% 
% DirActual=pwd;
% 
% %% Agregamos primero los directorios que estan dentro de solver
% cd('D:\Geomec\paper DFN\ITBA\Piloto\DFIT');
% 
% str2=[pwd '\inputs (.txt)\'];
% str3=[DirActual '\plots\'];
% str5=[pwd '\Resultados de corridas (.mat)\'];
% 
% %% Directorios que estan por afuera
% Largo=length(DirActual);
% 
% str6=[pwd '\Mallas read data (.mat)\'];
% 
% addpath(str2);
% addpath(str3);
% 
% addpath(str5);
% addpath(str6);
% addpath(DirActual)
% cd('D:\Geomec\paper DFN\ITBA\Piloto\DFIT\scriptSolverGitHub')


%%
%% Current path

DirActual=mainFolder;


str1=[DirActual '\scriptSolverGitHub\plots\'];
addpath(str1);

%% Agregamos primero los directorios que estan dentro de solver
% cd(DirectorioMadre);

str2=[DirActual 'inputs (.txt)\'];
str3=[DirActual 'Mallas read data (.mat)\'];
str4=[DirActual 'posPro resultados\'];
str5=[DirActual 'Resultados de corridas (.mat)\'];
str6=[DirActual 'scriptMalladorGithub\'];
str7=[DirActual 'scriptSolverGitHub\'];

%% Directorios que estan por afuera

addpath(str1);
addpath(str2); addpath(str3);
addpath(str4); addpath(str5);
addpath(str6); addpath(str7);
