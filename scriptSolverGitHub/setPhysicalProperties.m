function [ physicalProperties ] = setPhysicalProperties(key,varargin)
% setPhysicalProperties es una funcion que sirve para setear las
% propiedades fisicas del problemas.
% Se puede elegir establecer dichas propiedades (a mano), continuar 
% trabajando con las utlimas que se utilizaron, utilizar las propiedades de
% la corrida de verificacion o cargar las propeidades de un archivo ya 
% escrito. Para cambiar las propiedades fisicas del problema ingresar como 
% key.

% key: "change" "default" "test" "load"

% Las propiedades se guardan en la estrcutura "physicalProperties" con los
% siguientes campos:
% physicalProperties: 
%          constitutive: propiedades constitutivas del medio
%         poroelasticas: propiedades poroelasticas del medio
%           fluidoPoral: propiedades del fluido poral.
%     fluidoFracturante: propiedades del fluido fracturante.
%           storativity:
%      cargasTectonicas: valor de cargas tectonicas.
%%
% Se cargan las propiedades que fueron utilizadas por ultima vez. En caso
% de ser la primera vez que se utiliza el programa es obligatorio ingresar
% nuevos datos.

if strcmpi(key,'default')
    load('physicalProperties')    
    % Se le consulta al usuario las propiedades fisicas para re establecerlas.
elseif strcmpi(key,'change')
else
    if strcmpi(key,'load')
        if nargin<2
            fprintf('---------------------------------------------------------\n');
            archivo = input('Ingrese nombre del archivo a correr: ');
            clc
        else
            archivo = varargin{1};
        end
    elseif strcmpi(key,'test')
        archivo = 'corridaVerificacion.txt';
    end
    psi2Pa   = 6894.76;
    Mpsi2MPa = 1e6/145;
    propiedades = getProperties(archivo);
    
    %% PROPIEDADES CONSTITUTIVAS DEL MEDIO %%
    physicalProperties.constitutive.EvD    = str2num(propiedades{2})*Mpsi2MPa;
    physicalProperties.constitutive.EhD    = str2num(propiedades{3})*Mpsi2MPa;
    physicalProperties.constitutive.NUvD   = str2num(propiedades{4});
    physicalProperties.constitutive.NUhD   = str2num(propiedades{5});
    physicalProperties.constitutive.depthD = str2num(propiedades{6});
    
    physicalProperties.constitutive.EvL    = str2num(propiedades{7})*Mpsi2MPa;
    physicalProperties.constitutive.EhL    = str2num(propiedades{8})*Mpsi2MPa;
    physicalProperties.constitutive.NUvL   = str2num(propiedades{9});
    physicalProperties.constitutive.NUhL   = str2num(propiedades{10});
    physicalProperties.constitutive.depthL = str2num(propiedades{11});
    physicalProperties.constitutive.eL     = str2num(propiedades{12});
    physicalProperties.constitutive.eT     = str2num(propiedades{13});
    
    %% PROPIEDADES POROELASTICAS %%
    physicalProperties.poroelasticas.pPoral = str2num(propiedades{14})*psi2Pa/1e6;
    physicalProperties.poroelasticas.m      = str2num(propiedades{15})';
    physicalProperties.poroelasticas.poro   = str2num(propiedades{16});
    physicalProperties.poroelasticas.Ks     = str2num(propiedades{17})*psi2Pa/1e6;
    physicalProperties.poroelasticas.Kf     = str2num(propiedades{18})*psi2Pa/1e6;
    
    %% PROPIEDADES DEL FLUIDO PORAL %%
    mDarcy2M2 = 9.87e-16;
    m2mm      = 1000;
    physicalProperties.fluidoPoral.kappaIntShale       = str2num(propiedades{19}) * mDarcy2M2  * (m2mm)^2; 
    physicalProperties.fluidoPoral.kappaIntBarriersH   = str2num(propiedades{20}) * mDarcy2M2  * (m2mm)^2;
    physicalProperties.fluidoPoral.kappaIntBarriersV   = str2num(propiedades{21}) * mDarcy2M2  * (m2mm)^2;
    physicalProperties.fluidoPoral.kappaIntBarriersSRV = str2num(propiedades{22}) * mDarcy2M2  * (m2mm)^2;
    physicalProperties.fluidoPoral.mu_dinamico         = str2num(propiedades{23})/1e6;
    
    physicalProperties.fluidoPoral.kappaS            = physicalProperties.fluidoPoral.kappaIntShale/physicalProperties.fluidoPoral.mu_dinamico;
    physicalProperties.fluidoPoral.kappaLH           = physicalProperties.fluidoPoral.kappaIntBarriersH/physicalProperties.fluidoPoral.mu_dinamico;
    physicalProperties.fluidoPoral.kappaLV           = physicalProperties.fluidoPoral.kappaIntBarriersV/physicalProperties.fluidoPoral.mu_dinamico;
    physicalProperties.fluidoPoral.kappaSRV          = physicalProperties.fluidoPoral.kappaIntBarriersSRV/physicalProperties.fluidoPoral.mu_dinamico;
    
    %% PROPIEDADES DEL FLUIDO FRACTURANTE %%
    physicalProperties.fluidoFracturante.MU               = str2num(propiedades{24})/1e6;
    physicalProperties.fluidoFracturante.preCondCTFluidos = str2num(propiedades{25});

    %% STORATIVITY %%
    physicalProperties.storativity.Stora = (1 - physicalProperties.poroelasticas.poro) / physicalProperties.poroelasticas.Ks  + physicalProperties.poroelasticas.poro  /physicalProperties.poroelasticas.Kf  ; %- 1 / (9*Ks^2) * m'*C*m;   OJO CAMBIAR ACA SI SE TOCA KS PORO Y KF.
    physicalProperties.storativity.M     = 1/physicalProperties.storativity.Stora;
    
    %% CARGAS TECTONICAS %%
    physicalProperties.cargasTectonicas.ShX   = str2num(propiedades{26})* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.ShY   = str2num(propiedades{27})* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.SvZ   = str2num(propiedades{28})* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.TauXY = str2num(propiedades{29})* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.TauYZ = str2num(propiedades{30})* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.TauXZ = str2num(propiedades{31})* psi2Pa/1e6;
    
    physicalProperties.cargasTectonicas.ShXL   = str2num(propiedades{32})* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.ShYL   = str2num(propiedades{33})* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.SvZL   = str2num(propiedades{34})* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.TauXYL = str2num(propiedades{35})* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.TauYZL = str2num(propiedades{36})* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.TauXZL = str2num(propiedades{37})* psi2Pa/1e6;
    
    %%
    [physicalProperties.constitutive] = putBarriers( physicalProperties.constitutive); % Se ponen las barreras de diferentes materiales.
    
    save('physicalProperties','physicalProperties');
end
fprintf('---------------------------------------------------------\n');
fprintf('Las <strong>propiedades fisicas</strong> a utilizar son: \n');
fprintf('(Unidades en MPa, m, s) \n\n');
fprintf('-- Constitutivas\n');
disp(physicalProperties.constitutive);
fprintf('-- Poroelasticas\n');
disp(physicalProperties.poroelasticas);
fprintf('-- Fluido Poral\n');
disp(physicalProperties.fluidoPoral);
fprintf('-- Fluido Fracturante\n');
disp(physicalProperties.fluidoFracturante)
fprintf('-- Storativity\n');
disp(physicalProperties.storativity);
fprintf('-- Cargas Tectonicas\n');
disp(physicalProperties.cargasTectonicas);
end

