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

DirActual=pwd;


str3=[DirActual '\plots\'];
addpath(str3);


L=find(pwd=='\');
pos=L(end);

DirectorioMadre=DirActual(1:pos);
%% Agregamos primero los directorios que estan dentro de solver
cd(DirectorioMadre);

str2=[pwd '\inputs (.txt)\'];
str3=[DirActual '\plots\'];
str5=[pwd '\Resultados de corridas (.mat)\'];
str7=[pwd '\posPro resultados\'];
%% Directorios que estan por afuera
Largo=length(DirActual);

str6=[pwd '\Mallas read data (.mat)\'];

addpath(str2);

addpath(str5);
addpath(str6);
addpath(DirActual)
cd(DirActual)