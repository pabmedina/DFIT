function [ propanteProperties ] = setPropantePropertiesLabel(key,physicalProperties,meshInfo,key2,varargin)
% setPropanteProperties es una funcion que sirve para setear las
% propiedades FISICAS del propante.
% Se puede elegir establecer dichas propiedades (a mano), continuar
% trabajando con las utlimas que se utilizaron, utilizar las propiedades de
% la corrida de verificacion o cargar las propeidades de un archivo ya
% escrito. Para cambiar las propiedades como key.

% key: "change" "default" "test" "load"
%%

if key2
    if strcmpi(key,'default')
        load('propanteProperties')
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
        Mpsi2MPa = 1e6/145;
        mDarcy2M2 = 9.87e-16;
        m2mm      = 1000;
        propiedades                    = getProperties(archivo);
        
        propanteProperties.Key         = varName('propanteKey', propiedades);
        propanteProperties.EP          = varName('EPropante', propiedades)*Mpsi2MPa; %en MPa
        propanteProperties.NuP         = varName('NuPropante', propiedades);
        propanteProperties.kappa_int_P = varName('kappaPropante', propiedades)*mDarcy2M2*(m2mm)^2; %en mm^2
        propanteProperties.hP          = varName('hPropantePorcentaje', propiedades)/100; %si el txt decia 50(%), ahora vale 0.5
        
        propanteProperties.MP     = physicalProperties.storativity.M; %en MPa
        propanteProperties.kappaP = propanteProperties.kappa_int_P/physicalProperties.fluidoPoral.mu_dinamico; %en mm2/(Mpa*s) = m3 s/kg
        propanteProperties.KnP    = propanteProperties.EP/(3*(1-2*propanteProperties.NuP)); %en MPa
        propanteProperties.Ks0_1P = 0; % Sin rigidez transversal.
        propanteProperties.Ks0_2P = 0; % Sin rigidez transversal.
        
        %hasta no conocer (Kf,) Ks del propante (no confundir con KnP), se toma su biot igual al del shale
        C    = constitutiveMatrix(physicalProperties.constitutive.Ev(1),physicalProperties.constitutive.Eh(1),physicalProperties.constitutive.NUv(1),physicalProperties.constitutive.NUh(1));
        biot = (physicalProperties.poroelasticas.m - C*physicalProperties.poroelasticas.m/3/physicalProperties.poroelasticas.Ks );
        propanteProperties.biotP = biot(1);
        
        propanteProperties.propantesActivosTotales = [];
        propanteProperties.cierreFlag              = zeros(meshInfo.nCohesivos,4); %Pre alocacion de variable que luego sirve para la produccion.
        
        save('propanteProperties','propanteProperties')
    end
    
    fprintf('---------------------------------------------------------\n');
    fprintf('Las <strong>propiedades del propante</strong> a utilizar son: \n');
    disp(propanteProperties);
else
    propanteProperties = [];
    disp('Corrida sin datos de propante.')
end
end
