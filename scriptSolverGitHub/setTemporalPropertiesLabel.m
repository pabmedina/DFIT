function [ temporalProperties] = setTemporalPropertiesLabel( key,varargin )
% setTemporalProperties es una funcion que sirve para setear las
% propiedades temporales para la resolucion del problema (solver).
% Se puede elegir establecer dichas propiedades (a mano), continuar 
% trabajando con las utlimas que se utilizaron, utilizar las propiedades de
% la corrida de verificacion o cargar las propeidades de un archivo ya 
% escrito. Para cambiar las propiedades fisicas del problema ingresar como 
% key.

% key: "change" "default" "test" "load"

% Las propiedades se guardan en la estrcutura "TemporalProperties" con los
% siguientes campos:
% temporalProperties: 
%             drainTimes: numero de tiempos para el equilibrio establecer
%             el equilibrio inicial.
%              initTimes: numero de tiempos para que actue el algoritmo de
%              time step.
%       deltaTdrainTimes: delta temporal entre cada drainTime
%                 deltaT: delta temporal inicial para los tiempos fuera de
%                 drainTimes + initTimes.
%     tiempoTotalCorrida: tiempo total de todo el proceso.
%            propanteGap: 
%                preCond: pre condicionador para mejorar calculo numerico.
%                   tita: 
%                deltaTs: delta temporal en cada Time.
%         produccionFlag: pre alocacion de variable.
%           condensacion: pre alocacion de variable. Sirve para saber el
%           tipo de resolucion de sistema de ecuaciones.
%           choleskyFlag: pre alocacion de variable.
%                 qrFlag: pre alocacion de variable.
%%
if strcmpi(key,'default')
    load('temporalProperties')
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
    propiedades = getProperties(archivo);
    
    temporalProperties.drainTimes       = varName('drainTimes', propiedades);
    temporalProperties.initTimes        = varName('initTimes', propiedades);
    temporalProperties.deltaTdrainTimes = varName('deltaTdrainTimes', propiedades);
    temporalProperties.deltaT           = varName('deltaT', propiedades);
    temporalProperties.deltaTMax        = varName('deltaTMax', propiedades);
    
    temporalProperties.tiempoISIP          = varName('tiempoISIP', propiedades);
    temporalProperties.deltaTISIP          = varName('deltaTISIP', propiedades);
    temporalProperties.tiempoProduccion    = varName('tiempoProduccion', propiedades);
    temporalProperties.deltaTProduccionMax = varName('deltaTProduccionMax', propiedades);
    
    tbombas = varName('tQ', propiedades);
        
    temporalProperties.tInicioISIP       = tbombas(end);
    temporalProperties.tFinalISIP        = temporalProperties.tInicioISIP + temporalProperties.tiempoISIP;
    temporalProperties.tInicioProduccion = temporalProperties.tFinalISIP;
    temporalProperties.tFinalProduccion  = temporalProperties.tInicioProduccion + temporalProperties.tiempoProduccion;
    
    temporalProperties.tiempoTotalCorrida = tbombas(end) + temporalProperties.tiempoISIP + temporalProperties.tiempoProduccion;
    
    
    % temporalProperties.flagResetDeltaT1 = 0;
    % temporalProperties.flagResetDeltaT2 = 0;
    temporalProperties.preCond        = 1;
    temporalProperties.tita           = 1;   % Factor de Crank Nicolson
    temporalProperties.deltaTs        = [ones(1,temporalProperties.drainTimes)*temporalProperties.deltaTdrainTimes, ones(1,temporalProperties.initTimes+1)*temporalProperties.deltaT];
    temporalProperties.produccionFlag = false;
    temporalProperties.condensacion   = false;
    temporalProperties.choleskyFlag   = flag;
    temporalProperties.qrFlag         = false;
    save('temporalProperties','temporalProperties')
end

fprintf('---------------------------------------------------------\n');
fprintf('Las <strong>propiedades temporales</strong> a utilizar son: \n');
disp(temporalProperties);
end

