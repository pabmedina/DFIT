function [ bombaProperties ] = setBombaPropertiesLabel(meshInfo,key,key2,varargin )
% setBombaProperties es una funcion que sirve para setear las
% propiedades de la bomba.
% Se puede elegir establecer dichas propiedades (a mano), continuar 
% trabajando con las utlimas que se utilizaron, utilizar las propiedades de
% la corrida de verificacion o cargar las propeidades de un archivo ya 
% escrito. Para cambiar las propiedades fisicas del problema ingresar como 
% key.

% key: "change" "default" "test" "load"

% Para plotear la curva del caudal de bomba ingresada y observar el caudal
% de bomba suavizado ingresar como key2.

% key2: "on" "off"

% Las propiedades se guardan en la estrcutura "bombaProperties" con los
% siguientes campos:
% bombaProperties: 
%       Qbombas: vector con caudal de bobma.
%       tbombas: tiempo para caudal de bomba.
%     nodoBomba: nodo para la inyeccion del caudal de bomba.
%%
if strcmpi(key2,'default')
    load('bombaProperties')   
elseif strcmpi(key2,'change')
else
    if strcmpi(key2,'load')
        if nargin<4
            fprintf('---------------------------------------------------------\n');
            archivo = input('Ingrese nombre del archivo a correr: ');
            clc
        else
            archivo = varargin{1};
        end
    elseif strcmpi(key2,'test')
        archivo = 'corridaVerificacion.txt';
    end
    BPM2mm3s    = 0.00264979 * (1000)^3;
    propiedades = getProperties(archivo);
    
    bombaProperties.QbombasOG   = varName('Q', propiedades);
    bombaProperties.tbombasOG   = varName('tQ', propiedades);
    posNodoBomba1                = varName('posNodoBomba1', propiedades);
    posNodoBomba2                = varName('posNodoBomba2', propiedades);
    posNodoBomba3                = varName('posNodoBomba3', propiedades);
%     posNodoBomba4                = varName('posNodoBomba4', propiedades);
%     posNodoBomba5                = varName('posNodoBomba5', propiedades);
%     posNodoBomba6                = varName('posNodoBomba6', propiedades);
    bombaProperties.QProduccion = 0;
    
    tiempoISIP                  = varName('tiempoISIP', propiedades);
    tiempoProduccion            = varName('tiempoProduccion', propiedades);
    
    nodoBomba1                    = getNodesInPos(0.001,meshInfo,posNodoBomba1);
    nodoBomba2                    = getNodesInPos(0.001,meshInfo,posNodoBomba2);
    nodoBomba3                    = getNodesInPos(0.001,meshInfo,posNodoBomba3);
%     nodoBomba4                    = getNodesInPos(0.001,meshInfo,posNodoBomba4);
%     nodoBomba5                    = getNodesInPos(0.001,meshInfo,posNodoBomba5);
%     nodoBomba6                    = getNodesInPos(0.001,meshInfo,posNodoBomba6);
    bombaProperties.nodoBomba    = [nodoBomba1(1) ;nodoBomba2(1);nodoBomba3(1)];%;nodoBomba4(1);nodoBomba5(1);nodoBomba6(1)] ;
    save('bombaProperties','bombaProperties')
end

if strcmpi(key,'On')
    BPM2mm3s      = 0.00264979 * (1000)^3;
    figure
    plot(bombaProperties.tbombasOG,bombaProperties.QbombasOG);
    hold on
    [tbombas ,Qbombas ] = suavizado( bombaProperties.tbombasOG ,bombaProperties.QbombasOG ,1,40,5);
    plot(tbombas,Qbombas,'o-');
    xlabel('Tiempo[s]')
    ylabel('Caudal [BPM]')
    title('Caudal vs tiempo')
    legend('Curva original','Curva suavizada')
    grid
    axis([0 max(bombaProperties.tbombasOG)*1.1 min(bombaProperties.QbombasOG)-0.1 max(bombaProperties.QbombasOG)*1.1]) 
end
fprintf('---------------------------------------------------------\n');
fprintf('Las <strong>propiedades de la bomba</strong> a utilizar son: \n');
fprintf('(Unidades en mm3/s, mm y s) \n\n');
disp(bombaProperties);

%% Suavizado y arreglo del caudal de entrada.
% Se suaviza el caudal de bomba para eliminar saltos discretos que pueda llegar a tener la funcion. 
[bombaProperties.tbombas ,bombaProperties.Qbombas ] = suavizado( bombaProperties.tbombasOG ,bombaProperties.QbombasOG ,1,40,5);

% Al vector caudal de bomba se le incorpora el ISIP y la produccion (por
% ahora con un caudal negativo).
tInicioISIP = bombaProperties.tbombas(end);
tFinalISIP = tInicioISIP + tiempoISIP;
tInicioProduccion = tFinalISIP;
tFinalProduccion = tInicioProduccion + tiempoProduccion;

bombaProperties.Qbombas = [bombaProperties.Qbombas,           0                          0                    0       bombaProperties.QProduccion      bombaProperties.QProduccion];
bombaProperties.tbombas = [bombaProperties.tbombas, tInicioISIP   tInicioISIP+tiempoISIP/4           tFinalISIP                 tInicioProduccion                 tFinalProduccion];

% Se vuelve a suavizar con distintos parametros. 
% [bombaProperties.tbombas ,bombaProperties.Qbombas ] = suavizado( bombaProperties.tbombas ,bombaProperties.Qbombas ,0.1,100,50);
bombaProperties.Qbombas = bombaProperties.Qbombas*0.00264979 * (1000)^3;
end

