function [ physicalProperties ] = setPhysicalPropertiesLabel2(key,varargin)
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
    physicalProperties.constitutive.EvD    = varName('Ev', propiedades)*Mpsi2MPa;
    physicalProperties.constitutive.EhD    = varName('Eh',propiedades)*Mpsi2MPa;
    physicalProperties.constitutive.NUvD   = varName('NUv', propiedades);
    physicalProperties.constitutive.NUhD   = varName('NUh', propiedades);
    physicalProperties.constitutive.depthD = varName('depth', propiedades);
    
    physicalProperties.constitutive.EvL    = varName('EvL', propiedades)*Mpsi2MPa;
    physicalProperties.constitutive.EhL    = varName('EhL', propiedades)*Mpsi2MPa;
    physicalProperties.constitutive.NUvL   = varName('NUvL', propiedades);
    physicalProperties.constitutive.NUhL   = varName('NUhL', propiedades);
    physicalProperties.constitutive.depthL = varName('depthL', propiedades);
    physicalProperties.constitutive.eL     = varName('eL', propiedades);
    physicalProperties.constitutive.eT     = varName('eT', propiedades);
    
    %% PROPIEDADES POROELASTICAS %%
    physicalProperties.poroelasticas.pPoral = varName('pPoral', propiedades)*psi2Pa/1e6; %en MPa
    physicalProperties.poroelasticas.m      = varName('m', propiedades)'; %vale [1 1 1 0 0 0]'
    physicalProperties.poroelasticas.poro   = varName('poro', propiedades); % porcentaje del shale que es poro (11%-->0.11)
    physicalProperties.poroelasticas.Ks     = varName('Ks', propiedades)*psi2Pa/1e6; %en MPa
    physicalProperties.poroelasticas.Kf     = varName('Kf', propiedades)*psi2Pa/1e6; %en MPa
    
    %% PROPIEDADES DEL FLUIDO PORAL %%
    mDarcy2M2 = 9.87e-16;
    m2mm      = 1000;
    physicalProperties.fluidoPoral.kappaIntShaleH       = varName('permShaleHorizontal', propiedades)             * mDarcy2M2  * (m2mm)^2; %en mm^2
    physicalProperties.fluidoPoral.kappaIntShaleV       = varName('permShaleVertical', propiedades)             * mDarcy2M2  * (m2mm)^2; %en mm^2
    physicalProperties.fluidoPoral.kappaIntBarriersH   = varName('permBarrerasHorizontal', propiedades)* mDarcy2M2  * (m2mm)^2;
    physicalProperties.fluidoPoral.kappaIntBarriersV   = varName('permBarrerasVertical', propiedades)  * mDarcy2M2  * (m2mm)^2;
    physicalProperties.fluidoPoral.kappaIntBarriersSRVH = varName('permSRVHorizontal', propiedades)               * mDarcy2M2  * (m2mm)^2;
    physicalProperties.fluidoPoral.kappaIntBarriersSRVV = varName('permSRVVertical', propiedades)               * mDarcy2M2  * (m2mm)^2;
    physicalProperties.fluidoPoral.mu_dinamico         = varName('mu_dinamico', propiedades)/1e6; %en MPa*s = 1e6*kg/(m s)
    
    physicalProperties.fluidoPoral.kappaSH    = physicalProperties.fluidoPoral.kappaIntShaleH/physicalProperties.fluidoPoral.mu_dinamico; %en [mm^2/(MPa s)] = [mm2 m s/(1e6 kg)] = [m3 s/kg]
    physicalProperties.fluidoPoral.kappaSV    = physicalProperties.fluidoPoral.kappaIntShaleV/physicalProperties.fluidoPoral.mu_dinamico; %en [mm^2/(MPa s)] = [mm2 m s/(1e6 kg)] = [m3 s/kg]
    physicalProperties.fluidoPoral.kappaLH   = physicalProperties.fluidoPoral.kappaIntBarriersH/physicalProperties.fluidoPoral.mu_dinamico;
    physicalProperties.fluidoPoral.kappaLV   = physicalProperties.fluidoPoral.kappaIntBarriersV/physicalProperties.fluidoPoral.mu_dinamico;
    physicalProperties.fluidoPoral.kappaSRVH  = physicalProperties.fluidoPoral.kappaIntBarriersSRVH/physicalProperties.fluidoPoral.mu_dinamico;
    physicalProperties.fluidoPoral.kappaSRVV  = physicalProperties.fluidoPoral.kappaIntBarriersSRVV/physicalProperties.fluidoPoral.mu_dinamico;
    
    %% PROPIEDADES DEL FLUIDO FRACTURANTE %%
    physicalProperties.fluidoFracturante.MU               = varName('MU', propiedades)/1e6; %en MPa*s
    physicalProperties.fluidoFracturante.preCondCTFluidos = varName('preCondCTFluidos', propiedades);

    %% STORATIVITY %%
    physicalProperties.storativity.Stora = (1 - physicalProperties.poroelasticas.poro) / physicalProperties.poroelasticas.Ks  + physicalProperties.poroelasticas.poro  /physicalProperties.poroelasticas.Kf  ; %- 1 / (9*Ks^2) * m'*C*m;   OJO CAMBIAR ACA SI SE TOCA KS PORO Y KF. %en 1/MPa
    physicalProperties.storativity.M     = 1/physicalProperties.storativity.Stora; %en MPa
    
    %% CARGAS TECTONICAS %%
    physicalProperties.cargasTectonicas.ShX   = varName('ShX', propiedades)* psi2Pa/1e6; %en MPa
    physicalProperties.cargasTectonicas.ShY   = varName('ShY', propiedades)* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.SvZ   = varName('SvZ', propiedades)* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.TauXY = varName('TauXY', propiedades)* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.TauYZ = varName('TauYZ', propiedades)* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.TauXZ = varName('TauXZ', propiedades)* psi2Pa/1e6;
    
    physicalProperties.cargasTectonicas.ShXL   = varName('ShXL', propiedades)* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.ShYL   = varName('ShYL', propiedades)* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.SvZL   = varName('SvZL', propiedades)* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.TauXYL = varName('TauXYL', propiedades)* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.TauYZL = varName('TauYZL', propiedades)* psi2Pa/1e6;
    physicalProperties.cargasTectonicas.TauXZL = varName('TauXZL', propiedades)* psi2Pa/1e6;
    
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

