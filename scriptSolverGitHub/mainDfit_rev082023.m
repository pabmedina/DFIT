clc;close all; format shortg; set(0,'DefaultFigureWindowStyle','docked');

setBiot = 0.7; setPropante = true;
poroElasticity = true; checkPlots = false; isipKC = true; flagPreCierre =false; gapPreCierre = 1; flagCierre = false; gapCierre =3e-1; 
meshCase = 'DFN'; %'WI';% 'DFN';%
KeyInicioIsip=false;
wantBuffPermeability = false; % false: la permeabilidad no se altera con el campo de tensiones de la etapa de fractura.
permFactor=1e5; keyAgusCheck = false; factor =1;
keyCorteCohesivos= 'Y';
%-------------------------------------------------------------------------%
%% %%%%%%%%%%%%%%%%%%%       main DFIT/TShape       %%%%%%%%%%%%%%%%%%%% %%
%-------------------------------------------------------------------------%
%% Variables a modificar segun lo requerido en cada corrida:
% Variables de inicio de corrida.
guardarCorrida    = 'Y'; % Si se quiere guardar la corrida. "Y" o "N".
pathAdder
% direccionGuardado = 'D:\Geomec\paper DFN\ITBA\Piloto\DFIT\Resultados de corridas (.mat)\';   %Dejo ambos directorios, ir comentando segun quien la use 
direccionGuardado = 'D:\Geomec\paper DFN\ITBA\Piloto\DFIT\Resultados de corridas (.mat)\'; 
% Direccion donde se guarda la informacion.
nombreCorrida     = 'DFIT_DFN_trial'; % Nombre de la corrida. La corrida se guarda en la carpeta "Resultado de corridas" en una subcarpeta con este nombre.

cargaDatos     = 'load'; % Forma en la que se cargan las propiedades de entrada. "load" "test" "default" "change".
archivoLectura = 'trial082023.txt';%'DFIT_rev052022_WI062023CorridaCorta.txt';%'DFIT_rev052022_WI+DFN062023CorridaCorta.txt';%'Dfit_rev052022_DFIT_062023.txt'; %'Dfit_rev052022_DFIT_WItrial_062023.txt';% Nombre del archivo con las propiedades de entrada. 

tSaveParcial   = []; % Guardado de resultados parciales durante la corrida. Colocar los tiempos en los cuales se quiere guardar algun resultado parcial.

restart            = 'N'; % Si no queremos arrancar la simulacion desde el principio sino que desde algun punto de partida 'Y' en caso contrario 'N'.
direccionRestart   = '';
propiedadesRestart = '';

% Variables del post - procesado.
tiempoArea      = 0; % Tiempo en el que se quiere visualizar la forma del area de fractura.
tiempoTensiones = 0; % Tiempo en el que se quiere visualizar las tensiones. Tiempo 0 equivale al final de los drainTimes.
keyPlots        = true; % Para plotear graficos intermedios. Separacion normal entre caras, presion de fractura y errores de convergencia.
%%
%-------------------------------------------------------------------------%
%%                             PRE - PROCESO                             %%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%%%            LOAD MESH PROPERTIES Y PARAMETROS DE LA MALLA            %%%
%-------------------------------------------------------------------------%
marca
meshInfo = loadMeshEdit(cargaDatos,archivoLectura); % Carga la malla y genera una estructura con los datos de la misma.

if islogical(meshInfo.elementsFisu.ALL.nodes)
    disp('No hay error de tipado')
else
    meshInfo.elementsFisu.ALL.nodes = cast(meshInfo.elementsFisu.ALL.nodes,'logical');
end

if islogical(meshInfo.elementsFisu.ALL.minusNodes)
    disp('No hay error de tipado')
else
    meshInfo.elementsFisu.ALL.minusNodes = cast(meshInfo.elementsFisu.ALL.minusNodes,'logical');
end

% Verificacion de malla.
meshInfo = meshVerification(meshInfo);


if ~keyAgusCheck && strcmpi(meshCase,'DFN')
    % esta parte la tiene que arreglar Agus con el mallador
    % colocamos una keyAgusCheck = false; 

    xInput1 = 1e4; yInput1 = 3e4; zInput1 = 3.4e4; tolFind = 1e-4;
    nodTripleEncuentro = findTriple(meshInfo,xInput1,yInput1,zInput1,tolFind);
    c = ismember(meshInfo.cohesivos.elements,find(nodTripleEncuentro));
    elCohesiveGathering = find(sum(c,2)>0);
    
    
    xInput2 = 2e4; yInput2 = 3e4; zInput2 = 3.4e4;
    nodEncuentroYZ = findDoble(meshInfo,xInput2,yInput2,zInput2,tolFind);
    
    xInput3 = 1e4; yInput3 = 3e4; zInput1_3 = 2e4; zInput2_3 =5e4;
    nodEncuentroXY = findDobleBis(meshInfo,xInput3,yInput3,zInput1_3,zInput2_3,tolFind);
    
    nodosInterseccionID = [find(nodEncuentroXY) ; find(nodEncuentroYZ)];
    nodosInterseccionID = unique(nodosInterseccionID);
    aa = ismember(meshInfo.elementsFluidos.elements,nodosInterseccionID);
    elCohesiveElementID = find(sum(aa,2)>0);
end

if ~keyAgusCheck
    vec = testingMesh(meshInfo.elements,meshInfo.nodes); % isempty(find(vec)) = true -> esto esta de mas y ya esta arreglado en el mallador.
end

%-------------------------------------------------------------------------%
%%%                         INPUTS y PROPERTIES                         %%%
%-------------------------------------------------------------------------%
physicalProperties   = setPhysicalPropertiesLabel(cargaDatos,archivoLectura);             % Propiedades del medio y otras.          
temporalProperties   = setTemporalPropertiesLabel(cargaDatos,archivoLectura);             % Propiedades temporales. 
algorithmProperties  = setAlgorithmPropertiesLabel(cargaDatos,archivoLectura);            % Propiedades del algoritmo de convergencia.                             
bombaProperties      = setBombaPropertiesLabel(meshInfo,'off',cargaDatos,archivoLectura); % Propiedades de la bomba.
produccionProperties = setProduccionPropertiesLabel(cargaDatos,archivoLectura);

if strcmp(keyCorteCohesivos,'Y')
    [meshInfo,cohesivosProperties] = setCohesivosPropertiesLabelCorteModificado(meshInfo,physicalProperties,temporalProperties,bombaProperties,'off',cargaDatos,archivoLectura);  % Propiedades de los elementos cohesivos. 
else
    [meshInfo,cohesivosProperties] = setCohesivosPropertiesLabel(meshInfo,physicalProperties,temporalProperties,bombaProperties,'off',cargaDatos,archivoLectura);  % Propiedades de los elementos cohesivos. 
end

propanteProperties   = setPropantePropertiesLabel(cargaDatos,physicalProperties,meshInfo,setPropante,archivoLectura);
SRVProperties        = setSRVPropertiesLabel(cargaDatos,'N',meshInfo,archivoLectura);
SRVProperties.elementsIndex=meshInfo.elementsFisu.ALL.index;

if checkPlots
    plotMeshColo3D(meshInfo.nodes,meshInfo.elements,meshInfo.cohesivos.elements,'off','on','w','r','k',1) % Se plotea la malla
    hold on
    plotMeshColo3D(meshInfo.nodes,meshInfo.elements(SRVProperties.elementsIndex,:),meshInfo.cohesivos.elements,'off','off','r','r','k',1) % Se plotea la malla
    hold off
end
%%
%-------------------------------------------------------------------------%
%%%                             PARAMETROS                              %%%
%-------------------------------------------------------------------------%
% -- Discretizacion de elementos.
paramDiscEle = getParamDiscEle(meshInfo,'H8'); % Obtencion de parametros de discretizacion de la malla.
meshInfo     = elementsBarreras(physicalProperties,meshInfo); % Se identifican los elementos que conforman las barreras.
% meshInfo     = nodesBarreras(physicalProperties,meshInfo); % Se identifican los nodos que conforman las barreras.

% -- Puntos de Gauss.
pGaussParam = getPGaussParam(); % Obtencion de puntos de gauss y pesos.

% -- Nodos de caras.
[nodosCara,cara] = getNodosCaras(meshInfo,paramDiscEle);

if checkPlots
    plotCara(meshInfo,'on',cara.oeste)
end

%-------------------------------------------------------------------------%
%%%                        CONDICIONES DE BORDE                         %%%
%-------------------------------------------------------------------------%
% -- Desplazamientos.
bc = sparse(paramDiscEle.nNod,paramDiscEle.nDofNod);                       % Pre alocacion de condiciones de borde.                                                                   % Identificacion de nodos overconstrained:
filterOverContrainedBorde   = false(paramDiscEle.nNod,1);                  % Hay que remover los nodos que van a estar overconstrained por culpa de
filterOverContrainedBorde(meshInfo.constraintsRelations(:,[2 3])) = true;      % los contraints de borde en la fractura. Hay 2 sets de nodos de contraints que van a
nodesToRemove               = cara.oeste & filterOverContrainedBorde;      % quedar pegados a la fractura, entonces voy a estar pidiendo simetria y
cara.oeste(nodesToRemove)   = false;                                      % al mismo tiempo pidiendo contraints.

if ~keyAgusCheck % -> hardcodeo para parchar el mallador.
    switch meshCase
        case 'DFIT'
            meshInfo.constraintsRelations = normalConstraintsDFITHardCodeado(meshInfo.constraintsRelations,meshInfo.nodosBoundary);
        case 'WI'
            meshInfo.constraintsRelations = normalConstraintsWIHardCodeado(meshInfo.constraintsRelations,meshInfo.nodosBoundary);
        case 'DFN'
            meshInfo.constraintsRelations = meshInfo.constraintsRelations; % normalConstraintsDFN(meshInfo.constraintsRelations,meshInfo.nodosBoundary);
    end
end
if checkPlots
    plotOverCT(meshInfo,'on',nodesToRemove)
end
% Fijacion de las direcciones normales a cada cara.
bc(cara.este,1)     = true; 
bc(cara.oeste,1)    = true;  % La condicion de borde de simetria sigue siendo la misma.
bc(cara.norte,2)    = true; 
bc(cara.sur,2)      = true; 
bc(cara.superior,3) = true; 
bc(cara.inferior,3) = true; 


% % Todas las caras empotradas.
% bc(cara.este,:)     = true; 
% bc(cara.oeste,:)    = true;
% bc(cara.norte,:)    = true; 
% bc(cara.sur,:)      = true; 
% bc(cara.superior,:) = true; 
% bc(cara.inferior,:) = true; 
  

isFixed = logical(reshape(bc',[],1));                                      % Re orden de condiciones de borde y convercion a variable logica.

% -- Presiones.
bc_poral = logical(sparse(paramDiscEle.nDofTot_P,1));                      % Pre alocacion de variable.
                                                                                                    % Identificacion de nodos overconstrained:
nodosOverConstrained   = [nodosCara.este(ismember(nodosCara.este,meshInfo.CRFluidos(:,2:end)))      % Ahora debemos encontrar los nodos que han sido constraineados dos
                          nodosCara.superior(ismember(nodosCara.superior,meshInfo.CRFluidos(:,2)))  % veces, por un lado por los contraints de fluidos y por el otro por
                          nodosCara.inferior(ismember(nodosCara.inferior,meshInfo.CRFluidos(:,2)))  % fijarle la presion en el borde Este. Para encontrarlos, sabemos que
                          nodosCara.norte(ismember(nodosCara.norte,meshInfo.CRFluidos(:,2)))        % estan en la caraEste,caraSuperior,caraInferior y decimos que los slaves(segunda fila de
                          nodosCara.sur(ismember(nodosCara.sur,meshInfo.CRFluidos(:,2)))];          % MSNodes) que esten ahi, seran descontraineados.

% Condiciones de presion poral con plano de simetria en cara oeste.
bc_poral(cara.inferior | cara.superior | cara.este | cara.norte | cara.sur) = true;

% % % Todas las caras con presion poral definida.
% bc_poral(cara.inferior | cara.superior | cara.este | cara.oeste| cara.norte | cara.sur) = true;

bc_poral(nodosOverConstrained)  = false;                                    % nodosOverConstrained = unique(nodosOverConstrained); No hace falta esta linea pero la dejo por las dudas.

%-------------------------------------------------------------------------%
%%%                               CARGAS                                %%%
%-------------------------------------------------------------------------%
% -- Propiedades geomecanicas de la malla.
[constitutivas,Biot] = eleProps(physicalProperties,meshInfo.nodes,meshInfo.elements,pGaussParam.upg,'off','on',setBiot);

% Cargo directamente las externas, no las iniciales del solido.
initialSressExtS = [physicalProperties.cargasTectonicas.ShX
                    physicalProperties.cargasTectonicas.ShY
                    physicalProperties.cargasTectonicas.SvZ
                    physicalProperties.cargasTectonicas.TauXY
                    physicalProperties.cargasTectonicas.TauYZ
                    physicalProperties.cargasTectonicas.TauXZ]*0;   
                
initialStrainExtS = [-6e-4
                     -1.5e-4
                     -2e-3
                      0
                      0
                      0];
                  
initialSressExtL = [physicalProperties.cargasTectonicas.ShXL
                    physicalProperties.cargasTectonicas.ShYL
                    physicalProperties.cargasTectonicas.SvZL
                    physicalProperties.cargasTectonicas.TauXYL
                    physicalProperties.cargasTectonicas.TauYZL
                    physicalProperties.cargasTectonicas.TauXZL];              
                    
initialPPoral   =  physicalProperties.poroelasticas.pPoral;
% cargasRElementosBarreras
cargasRElementosBarrerasEdit
RP              = sparse(paramDiscEle.nDofTot_U,1); % Cargas del propante. Son las cargas que se aplican para mover el equilibrio y poder modelarlos como cohesivos rotos con rigidez a partir de un valor distinto de cero.

%%
%-------------------------------------------------------------------------%
%%%                         MATRICES Y TENSORES                         %%%
%-------------------------------------------------------------------------%

% -- Matriz de rigidez [K]. 
K = getStiffnessMatrix(paramDiscEle,pGaussParam,constitutivas,meshInfo);

% -- Tensor Poral [C].
C = getTensor(meshInfo,paramDiscEle,pGaussParam,1,Biot,1,'C');

% % -- Tensor de permeabilidad poral [KC].
Kperm = getMatrizPermeabilidad(physicalProperties,meshInfo,SRVProperties,'drain','N' );
KC    = getTensor(meshInfo,paramDiscEle,pGaussParam,1,1,Kperm,'KC');
KCP   = sparse(paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P); % Tensor de permeabilidad del propante.

% -- Tensor de storativity [S].
S = getTensor(meshInfo,paramDiscEle,pGaussParam,physicalProperties,1,1,'S');
SP = sparse(paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P); % Tensor de storativity del propante.

%-------------------------------------------------------------------------%
%%%                             CONSTRAINTS                             %%%
%-------------------------------------------------------------------------%
% -- Fluidos.
[CTFluidos,nCREqFluidos] = getCTFluidos(meshInfo.CRFluidos,physicalProperties.fluidoFracturante.preCondCTFluidos,paramDiscEle.nDofTot_P);

%-- Solidos. (Para borde de fractura con y sin interseccion). 
% [ CTFrac ,nCREqFrac ] = getCTFrac(paramDiscEle.nodeDofs,meshInfo.constraintsRelations,algorithmProperties.precondCT,paramDiscEle.nDofTot_U);
[ CTFrac ,nCREqFrac ] = getCTFracNormalPromedioHardCodeado(paramDiscEle.nodeDofs,meshInfo.constraintsRelations,algorithmProperties.precondCT,paramDiscEle.nDofTot_U,meshInfo); % esto hay que revisar algo para la DFN
%-- Juntado de Constraints.
zerosCTFluidosU = sparse(paramDiscEle.nDofTot_U,nCREqFluidos);
zerosCTFracP    = sparse(paramDiscEle.nDofTot_P,nCREqFrac);

allCT   = [zerosCTFluidosU' -temporalProperties.preCond*CTFluidos
           CTFrac           -temporalProperties.preCond*zerosCTFracP'
          ];

zerosCT = sparse(nCREqFluidos + nCREqFrac,nCREqFluidos + nCREqFrac);
nDofTotales = paramDiscEle.nDofTot_U + paramDiscEle.nDofTot_P + nCREqFluidos + nCREqFrac;

%-- Separacion de Dofs para resolucion de sistema de ecuaciones.
[dofsC,dofsX,dofsCU,dofsCP,dofsAT,dofsNoLineales,dofsXNoLineales] = getDofs(isFixed,bc_poral,nCREqFluidos,nCREqFrac,nDofTotales,paramDiscEle, meshInfo);

%%
%-------------------------------------------------------------------------%
%%%                         VECTORES AUXILIARES                         %%%
%-------------------------------------------------------------------------%
%-- Vectores de propagacion de fluido fracturante.
[intNodes,nodosMuertos,meshInfo,produccionDesplazamientosImpuestos,fracturing2ProductionFlag] = getPropagacionVecs(meshInfo,temporalProperties,cohesivosProperties);

%-- Vectores de converencia. (pre alocacion).
noConvergido = 1; convergido = 0; error = 1;

%%
%-------------------------------------------------------------------------%
%%%                         VARIABLES DE INTERES                        %%%
%-------------------------------------------------------------------------%
%Pre alocacion de variables.
dTimes  = zeros(nDofTotales,1);
QTimes  = zeros(paramDiscEle.nDofTot_P,1);
% hhTimes = zeros(size(meshInfo.nodosFluidos.EB_Asociados,1),1);
hhTimes = zeros(meshInfo.nElEB,1);
iTime = 0;

iSaveParcial = 1;
flagSaveFrac = 1;
flagSaveISIP = 1;
restartKC    = 1;
productionKC = 1;

iProp = 1;

contadorErrorConvergido = 0;
cantErrorConvergido     = 1;

if keyPlots == true
    han1 = figure('Name','Error');
    han2 = figure('Name','SeparacionPresion');
end
%-------------------------------------------------------------------------%
%%                                SOLVER                                 %%
%-------------------------------------------------------------------------%
% Como el problema tiene una componente no lineal que viene dado que la
% rigidez de los cohesivos depende de la deformacion de los mimsos para
% cada paso temporal se realizan una serie de iteraciones.


if strcmpi(restart,'Y') 
    variablesRestart = load([direccionRestart,propiedadesRestart],'iTime','algorithmProperties','temporalProperties','dTimes','QTimes','hhTimes','meshInfo');
    
    iTime = variablesRestart.iTime;
    dTimes = variablesRestart.dTimes;

    QTimes = variablesRestart.QTimes;
    hhTimes = variablesRestart.hhTimes;
    
    algorithmProperties.elapsedTime = variablesRestart.algorithmProperties.elapsedTime;
    
    temporalProperties.deltaTs = variablesRestart.temporalProperties.deltaTs;
   
    meshInfo.cohesivos.dS1Times = variablesRestart.meshInfo.cohesivos.dS1Times;
    meshInfo.cohesivos.dS2Times = variablesRestart.meshInfo.cohesivos.dS2Times;
    meshInfo.cohesivos.dNTimes = variablesRestart.meshInfo.cohesivos.dNTimes;
    meshInfo.cohesivos.KnTimes  = variablesRestart.meshInfo.cohesivos.KnTimes;
    meshInfo.cohesivos.Ks1Times = variablesRestart.meshInfo.cohesivos.Ks1Times;
    meshInfo.cohesivos.Ks2Times = variablesRestart.meshInfo.cohesivos.Ks2Times;
    meshInfo.cohesivos.KnPrevTime = variablesRestart.meshInfo.cohesivos.KnPrevTime;
    meshInfo.cohesivos.Ks1PrevTime = variablesRestart.meshInfo.cohesivos.Ks1PrevTime;
    meshInfo.cohesivos.Ks2PrevTime  = variablesRestart.meshInfo.cohesivos.Ks2PrevTime;
    meshInfo.cohesivos.biot = variablesRestart.meshInfo.cohesivos.biot;
    meshInfo.cohesivos.elementsFluidosActivos  = variablesRestart.meshInfo.cohesivos.elementsFluidosActivos;
    meshInfo.cohesivos.deadFlagTimes = variablesRestart.meshInfo.cohesivos.deadFlagTimes;
    
    meshInfo.cohesivos.positiveFlag     = variablesRestart.meshInfo.cohesivos.positiveFlag;
    meshInfo.cohesivos.dN1              = variablesRestart.meshInfo.cohesivos.dN1;
    meshInfo.cohesivos.damageFlagN      = variablesRestart.meshInfo.cohesivos.damageFlagN;
    meshInfo.cohesivos.deadFlag         = variablesRestart.meshInfo.cohesivos.deadFlag;
    meshInfo.cohesivos.KnIter           = variablesRestart.meshInfo.cohesivos.KnIter;
    meshInfo.cohesivos.lastPositiveKn   = variablesRestart.meshInfo.cohesivos.lastPositiveKn;
    meshInfo.cohesivos.dNMat            = variablesRestart.meshInfo.cohesivos.dNMat;
    meshInfo.cohesivos.firstDmgFlagN    = variablesRestart.meshInfo.cohesivos.firstDmgFlagN;
    
    
    meshInfo.cohesivos.dS1_1        = variablesRestart.meshInfo.cohesivos.dS1_1;
    meshInfo.cohesivos.damageFlagS1 = variablesRestart.meshInfo.cohesivos.damageFlagS1;
    meshInfo.cohesivos.Ks1Iter      = variablesRestart.meshInfo.cohesivos.Ks1Iter;
    meshInfo.cohesivos.dS1Mat       = variablesRestart.meshInfo.cohesivos.dS1Mat;
    
    meshInfo.cohesivos.dS1_2        = variablesRestart.meshInfo.cohesivos.dS1_2;
    meshInfo.cohesivos.damageFlagS2 = variablesRestart.meshInfo.cohesivos.damageFlagS2;
    meshInfo.cohesivos.Ks2Iter      = variablesRestart.meshInfo.cohesivos.Ks2Iter;
    meshInfo.cohesivos.dS2Mat       = variablesRestart.meshInfo.cohesivos.dS2Mat;
    
    meshInfo.elementsFisu.ALL.nodesInFisu = variablesRestart.meshInfo.elementsFisu.ALL.nodesInFisu;
    meshInfo.elementsFisu.fracturados = variablesRestart.meshInfo.elementsFisu.fracturados;
    meshInfo.elementsFluidos.activos = variablesRestart.meshInfo.elementsFluidos.activos; 
end

% clear
% close all
% clc
% 
% load('incorporacionPropante.mat')


while algorithmProperties.elapsedTime <= temporalProperties.tiempoTotalCorrida
    %% Activacion de propantes luego de la fractura.
    % Parte adaptada del codigo de multiples fracturas a este. Poreso
    % hay referencias a muchas fracturas y otros comentarios al
    % respecto.
        
    if algorithmProperties.elapsedTime >= temporalProperties.tInicioISIP && iProp == 1 && strcmpi(propanteProperties.Key,'Y')
        iProp = 0;        
        % Identificacion de cohesivos de fracturas que finalizaron.
        cohesivosVar                             = (1:size(meshInfo.cohesivos.elements,1))'; % Elementos a los cuales hay que cambiarles las propiedades.
        meshInfo.cohesivos.dN0(cohesivosVar,:)   = ones(numel(cohesivosVar),4); % Se cambia la separacion normal para que no se rompan mas cohesivos.
        meshInfo.cohesivos.dN1(cohesivosVar,:)   = ones(numel(cohesivosVar),4); % Se cambia la separacion normal para que no se rompan mas cohesivos.
        meshInfo.cohesivos.dS0_1(cohesivosVar,:) = ones(numel(cohesivosVar),4); % Se cambia la separacion normal para que no se rompan mas cohesivos.
        meshInfo.cohesivos.dS1_1(cohesivosVar,:) = ones(numel(cohesivosVar),4); % Se cambia la separacion normal para que no se rompan mas cohesivos.
        meshInfo.cohesivos.dS0_2(cohesivosVar,:) = ones(numel(cohesivosVar),4); % Se cambia la separacion normal para que no se rompan mas cohesivos.
        meshInfo.cohesivos.dS1_2(cohesivosVar,:) = ones(numel(cohesivosVar),4); % Se cambia la separacion normal para que no se rompan mas cohesivos.
        
        % Identificacion de cohesivos --> propantes.
        propantesVar    = cohesivosVar(all(meshInfo.cohesivos.deadFlag(cohesivosVar,:),2)); % Cohesivos que pasan a ser propantes.
        propantesH8Var  = meshInfo.cohesivos.related8Nodes(propantesVar,:);
        %         propantesH8Var  = propantesH8Var(:,[8 5 6 7 4 1 2 3]);
        propantesH8Var  = propantesH8Var(:,[8 4 1 5 7 3 2 6]); % Cambia aca y en la funcion getNodosDesplazados2
        nPropantesVar   = numel(propantesVar);
        
        %KCGap - KCPropante
        displacements                      = reshape(dTimes(1:paramDiscEle.nDofTot_U,iTime),3,[])';
        [nodosDesplazados,aperturasNormal] = getNodosDesplazados2(meshInfo.nodes,propantesVar,meshInfo.cohesivos,propanteProperties,meshInfo.cohesivos.dNCalculado); % No usar separacion promedio.

       
        nodesEle = zeros(paramDiscEle.nNodEl,paramDiscEle.nDofNod,nPropantesVar);
        col      = cell(nPropantesVar,1);
        row      = cell(nPropantesVar,1);
   
        for iEle = 1:nPropantesVar
            col{iEle}          = repmat(propantesH8Var(iEle,:)',1,paramDiscEle.nNodEl);
            row{iEle}          = col{iEle}';
            nodesEle(:,:,iEle) = nodosDesplazados{iEle}; 
        end
        
        KpermP = repmat(propanteProperties.kappaP*eye(3,3),1,1,8);
        KCeP   = cell(nPropantesVar,1);
        for iEle = 1:nPropantesVar
            KCeP{iEle}  =  gradiente_poral(pGaussParam.npg,pGaussParam.upg,pGaussParam.wpg,nodesEle(:,:,iEle),paramDiscEle.nNodEl,KpermP);
            if any(diag(KCeP{iEle}) < 0)
                warning(['Valor de la diagonal en el KCeP negativo del elemento: ',num2str(iEle)])
            end
        end
        KCPVar = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(KCeP{:}),paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P);       
        KCP    = KCP + KCPVar;
        
        SeP = cell(nPropantesVar,1);
        for iEle = 1:nPropantesVar
            SeP{iEle} = poral_temporal(pGaussParam.npg,pGaussParam.upg,pGaussParam.wpg,nodesEle(:,:,iEle),paramDiscEle.nNodEl,physicalProperties.storativity.M);
        end
        SPVar = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(SeP{:}),paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P);      
        SP = SP + SPVar;
        
        % Actualizacion de valores totales.
        propanteProperties.propantesActivosTotales = [propanteProperties.propantesActivosTotales; propantesVar];
        propanteProperties.nPropantes              = numel(propanteProperties.propantesActivosTotales);
        
        propanteProperties.elements.Q4(propantesVar,:)   = meshInfo.cohesivos.elements(propantesVar,:);
        propanteProperties.elements.H8(propantesVar,:)   = meshInfo.cohesivos.related8Nodes(propantesVar,:);
        propanteProperties.aperturaFinal(propantesVar,:) = propanteProperties.hP*meshInfo.cohesivos.dNCalculado(propantesVar,:);
        propanteProperties.aperturaFinal(propanteProperties.aperturaFinal<0) = 0;
        deltaPropante = getDeltaForRPropante(propanteProperties,meshInfo,paramDiscEle,meshInfo.cohesivos);
    end   
    
    
    %% ACTUALIZO VARIABLES DEL TIEMPO ANTERIOR %
    iTime = iTime+1;
    if iTime == 1                                                                                                           
        % Si es el inicio de la operacion. Variable de iniciacion de iteraciones de vector solucion.                      % d0
        dPrev   = [ sparse(paramDiscEle.nDofTot_U,1)                                                                      % desplazamientos
                    physicalProperties.poroelasticas.pPoral / temporalProperties.preCond * ones(paramDiscEle.nDofTot_P,1) % presiones
                    sparse(nCREqFluidos,1)                                                                                % lambdaCT: contraints desplazamiento 
                    sparse(nCREqFrac,1)                                                                                   % lambdaCTFrac: constraints presiones
                    ];                                                                             % lambdaCTWinkler: constraints winklers
        
        hhPrev  = zeros(meshInfo.nElEB,1); % hh0
        dNPrev  = zeros(meshInfo.nElEB,1); % gap0. Desplazamiento normal.
        dS1Prev = zeros(meshInfo.nElEB,1); % gap0. Desplazamiento tangencial.
        dS2Prev = zeros(meshInfo.nElEB,1); % gap0. Desplazamiento tangencial 2.
    else
        dPrev   = dTimes(:,iTime-1);
        hhPrev  = hhTimes(:,iTime - 1);
        dNPrev  = zeros(meshInfo.nElEB,1);
        dS1Prev = zeros(meshInfo.nElEB,1);
        dS2Prev = zeros(meshInfo.nElEB,1);
    end
    
    %% CONDICIONES QUE CAMBIAN CON EL TIEMPO %%
    % Cambian con el tiempo pero permanecen constantes con las iteraciones.
    if iTime > temporalProperties.drainTimes
        deltaT = temporalProperties.deltaTs(iTime);
    else
        deltaT = temporalProperties.deltaTdrainTimes;
    end
    display(iTime);
 
    %% Cambio de KC. 
    
    
    
    if restartKC == 1 && iTime>temporalProperties.drainTimes % Durante los drain times la permeabilidad esta alta para acelerar el estado estacionario. Aca se establecen los valores correctos para shale y barreras.
        Kperm     = getMatrizPermeabilidad(physicalProperties,meshInfo,SRVProperties,'frac','Y' );
        KC        = getTensor(meshInfo,paramDiscEle,pGaussParam,1,1,Kperm,'KC');
        restartKC = 0;
    elseif isipKC && algorithmProperties.elapsedTime >= temporalProperties.tInicioISIP % Se establece el valor de permeabilidad mas elevado para el SRV que se activa durante la produccion. 

        if KeyInicioIsip
            
            KeyInicioIsip=false; %% Aca vamos a generar la Curva y desp usamos esa
            calcTensionesenInicioISIP 
            calcTensionesenDrainTimes
            DeltaPHidro=abs(abs(tensionHidroDrainTimes(Elem))-abs(tensionHidroInicioIsip(Elem))); %% diferencia de tensionesH entre el itime 2 y donde arranca el Isip
            %%Elem es el elemento Bomba
        end
            calcTensionesenISIP
            
            if wantBuffPermeability
                ImproveFactor=permFactor+(1-permFactor/DeltaPHidro)*(tensionHidroDrainTimes-tensionHidroIsip').*((tensionHidroDrainTimes-tensionHidroIsip')>0);
                ImproveFactor=(ImproveFactor>1).*ImproveFactor+(ImproveFactor<1).*1;
            else
                ImproveFactor = ones(paramDiscEle.nel,1);
            end
%            improvePerm=physicalProperties.fluidoPoral.kappaIntShale;
           
            Kperm        = getMatrizPermeabilidadPorElemISIP(physicalProperties,meshInfo,SRVProperties,ImproveFactor,'ISIP','N' );
            KC           = getTensor(meshInfo,paramDiscEle,pGaussParam,1,1,Kperm,'KC'); %improvePerm.*factor o solo factor arriba??
            productionKC = 0;
        
    end

    %% ITERACIONES DE FRACUTRA %%
    % Variables que cambian con cada iteracion. Se definen las variables de
    % la iteracion anterior.
    dPrevITER       = dPrev;
    hhIter          = hhPrev;
    dN              = dNPrev;
    dS1             = dS1Prev;
    dS2             = dS2Prev;
    error           = noConvergido;
    nIter           = 0;
    %% FLUSH d %%
    dITER = zeros(nDofTotales,1);
    dR_dofsTotales = sparse(nDofTotales,1);
    
    %% CONDICIONES DE BORDE  %%
    %%% Qbomba %%%
    if iTime <= temporalProperties.drainTimes
        Q = sparse(paramDiscEle.nDofTot_P,1); 
    else
        if algorithmProperties.elapsedTime <= temporalProperties.tInicioISIP % Estamos fracturando y antes del ISIP general.
            Qbomba = getInterpValue(bombaProperties.tbombas,bombaProperties.Qbombas,algorithmProperties.elapsedTime);
            Q      = sparse(bombaProperties.nodoBomba,1,Qbomba,paramDiscEle.nDofTot_P,1); % Solo caudal en la fractura actual.

        elseif algorithmProperties.elapsedTime <= temporalProperties.tInicioProduccion % Terminamos de fracturar y estamos en el ISIP general antes de la produccion.
            Q      = sparse(paramDiscEle.nDofTot_P,1); % Durante el ISIP valor cero en los caudales.
            
        else % Empezamos la produccion.
            if strcmpi(produccionProperties.modoProduc,'p') % Si fijamos una contrapresion para producir.
                Q       = sparse(paramDiscEle.nDofTot_P,1); % Solo se pre aloca el vector porque no se conoce. El solver lo determina en funcion a la contrapresion de produccion.
            
            elseif strcmpi(produccionProperties.modoProduc,'q') % Si fijamos un caudal cte de produccion.
                tProduc = algorithmProperties.elapsedTime - temporalProperties.tFinalISIP;
                QProduc = getInterpValue(produccionProperties.tColumna,produccionProperties.QProduc,tProduc);
                Q       = sparse(bombaProperties.nodoBomba,1,QProduc,paramDiscEle.nDofTot_P,1); % Cuidado que solo le fijamos el caudal a aquellas fracturas que fueron activadas en un principio.
            end
        end
    end
    
    %% GRADOS DE LIBERTAD CONOCIDOS %%
    if iTime <= temporalProperties.drainTimes
        dITER(dofsCP) = physicalProperties.poroelasticas.pPoral/temporalProperties.preCond;
    else
        if strcmpi(produccionProperties.frontImperm ,'Y') % Pasados los drain times se vuelve impermeable la frontera.
            dofsCP(:) = false;
            dofsC     = dofsCP | dofsCU;
            dofsX     = ~dofsC;
        end
        
        if algorithmProperties.elapsedTime >= temporalProperties.tInicioProduccion && strcmpi(produccionProperties.modoProduc,'p') % Si estamos en produccion y conocemos la contrapresion en los nodos bomba hay que fijarlos a dicha contra presion.
            
            dofsCP(paramDiscEle.nDofTot_U+bombaProperties.nodoBomba) = true;   % Se modifica el vector logico para indicar que se conoce la presion en el nodo bomba.
            dITER(dofsCP) = physicalProperties.poroelasticas.pPoral/temporalProperties.preCond; % A todos los dofs conocidos de presion le ponemos la poral inicial. Esa es la condicion de borde en los extremos. Para los nodos bomba lo reescribimos despues.
            
            tProduc = algorithmProperties.elapsedTime - temporalProperties.tFinalISIP;
            pCol    = getInterpValue(produccionProperties.tColumna,produccionProperties.pColumna,tProduc);
            dITER(paramDiscEle.nDofTot_U+bombaProperties.nodoBomba) = pCol;
            
            minP = min(dPrev(paramDiscEle.nDofTot_U+bombaProperties.nodoBomba));  % Cuidado que solo nos fijamos en aquellas fracturas que fueron activadas en un principio.
            if minP < pCol
                warning 'Contrapresion mas elevada que presion en el reservorio. Achicar valor de contrapresion inicial';
                assert(minP >= pCol);
            end
            
            dofsC = dofsCP | dofsCU;
            dofsX = ~dofsC;
            
        else
            dITER(dofsCP) = physicalProperties.poroelasticas.pPoral/temporalProperties.preCond;
        end
    end
    dITER(dofsCU) = 0; % Siempre cero al menos que impongamos desplazamientos como condiciones de borde.
    
    %% SOLVE FOR d CONVERGENCE (ITERACIONES DE PICARD) %%
    tic
    while error == noConvergido  
        %% CALCULO [KCohesivos] DEPENDIENTE DE d %% (Razon de la alinealidad del problema)
        [row, col,~] = getMapping(paramDiscEle.nDofElCohesivos,meshInfo.nCohesivos,8,3,paramDiscEle.nodeDofs,meshInfo.cohesivos.related8Nodes,meshInfo.nodes,'Kch');
        rowAux       = cell(meshInfo.nCohesivos,1); colAux = cell(meshInfo.nCohesivos,1);
        
        KCohesivosE         = cell(meshInfo.nCohesivos,1);
        KCohesivosEPropante = cell(meshInfo.nCohesivos,1);
        KTanCohesivosE      = cell(meshInfo.nCohesivos,1);
        Cce                 = cell(meshInfo.nCohesivos,1);
        
        for iEle = 1:meshInfo.nCohesivos % Aca se cambia la forma de calcular la rigidez de los cohesivos ya rotos. Tengo que decirle que solo se fije en la fractura pertinente.
            if any(iEle == propanteProperties.propantesActivosTotales)
                [KCohesivosE{iEle}, KTanCohesivosE{iEle},KnIter, Ks1Iter,Ks2Iter,dD,meshInfo.cohesivos,Cce{iEle},propanteProperties ] = interfaceElementsPropantes( iEle,meshInfo.nodes , paramDiscEle.nDofEl ,meshInfo.cohesivos,iTime,dPrevITER,dPrev,propanteProperties);
                KCohesivosEPropante{iEle} = KCohesivosE{iEle};
            else
                [KCohesivosE{iEle}, KTanCohesivosE{iEle},KnIter, Ks1Iter,Ks2Iter,dD,meshInfo.cohesivos,Cce{iEle} ] = interfaceElements3D( iEle,meshInfo.nodes , paramDiscEle.nDofEl ,meshInfo.cohesivos,iTime,dPrevITER,dPrev);
                KCohesivosEPropante{iEle} = sparse(24,24);
            end
            poralDofs = meshInfo.cohesivos.related8Nodes(iEle,1:4);
            rowAux{iEle} = repmat(poralDofs,paramDiscEle.nDofEl,1);
            colAux{iEle} = col{iEle}(:,1:4);
        end
        
        KCohesivos    = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(KCohesivosE{:}),paramDiscEle.nDofTot_U,paramDiscEle.nDofTot_U);
        KTanCohesivos = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(KTanCohesivosE{:}),paramDiscEle.nDofTot_U,paramDiscEle.nDofTot_U);
        Cc = sparse(vertcat(colAux{:}),vertcat(rowAux{:}),vertcat(Cce{:}),paramDiscEle.nDofTot_U,paramDiscEle.nDofTot_P);
        RPresiones    = (C'+Cc')*dPrev(1:paramDiscEle.nDofTot_U) + (S+SP)*dPrev(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P)*temporalProperties.preCond;
            
        if any(propanteProperties.propantesActivosTotales)
            KCohesivosPropante = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(KCohesivosEPropante{:}),paramDiscEle.nDofTot_U,paramDiscEle.nDofTot_U);
            RP                 = KCohesivosPropante*deltaPropante;
        end     
                
        %% MATRIZ CONDUCTIVIDAD FLUIDOS FRACTURA [H] %%%
        % ACOPLE  H A KPORAL
        masterDofs = meshInfo.elementsFluidos.elements(meshInfo.elementsFluidos.activos',:)';
        [row, col] = getMap(masterDofs);
        
        He = cell(sum(meshInfo.elementsFluidos.activos),1);
        aux = 1:meshInfo.nFluidos; aux2 = 1;
        
        for iEle = aux(meshInfo.elementsFluidos.activos)
            if any(iEle == propanteProperties.propantesActivosTotales)
                He{aux2} = zeros(4,4);
                aux2     = aux2+1;
            else
                He{aux2} = HFluidos2DV2(meshInfo.elementsFluidos,iEle,hhIter(meshInfo.nodosFluidos.EB_Asociados,1),physicalProperties.fluidoFracturante.MU,meshInfo.cohesivos,meshInfo.nodes,cohesivosProperties.angDilatancy,factor);
                aux2     = aux2+1;
            end
        end
        H = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(He{:}),paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P);
        
        if poroElasticity
            
            %% ARMO LA [KGLOBAL] %%
            mainSYSTEM = [ (K + KCohesivos)                             -temporalProperties.preCond*(C+Cc)
                -temporalProperties.preCond*(C'+Cc')         -(temporalProperties.preCond^2)*(S+ SP + (temporalProperties.tita*deltaT*(KC+KCP+H)))];
            
            KGLOBAL    = [mainSYSTEM    allCT'
                allCT         zerosCT];
            
            %% ARMO LA MATRIZ TANGENTE G %%
            mainSYSTEMG       = [(K + KTanCohesivos)                      -temporalProperties.preCond*(C+Cc)
                -temporalProperties.preCond*(C'+Cc')    -(temporalProperties.preCond^2)*(S+ SP + (temporalProperties.tita*deltaT*(KC+KCP+H)))];
            
            G  = [ mainSYSTEMG    allCT'
                   allCT          zerosCT];
            
            %% SOLVE FOR dITER %%
            % Se resuelve todas las variables (desplazamientos, presiones y
            % constraints) en un mismo vector d.
            
            FITER = [  R + RP
                      -(deltaT*Q  + RPresiones)*temporalProperties.preCond
                      -sparse(nCREqFluidos,1)
                       sparse(nCREqFrac,1)   ];
            
            
            dR_X = ((KGLOBAL(dofsX,dofsX) *dPrevITER(dofsX)) + (KGLOBAL(dofsX,dofsC) *dPrevITER(dofsC))  - FITER(dofsX));
            %             A = G(dofsX,dofsX);
            %             b =find(all(A == 0,2));
            deltaClassic = G(dofsX,dofsX)\ dR_X;
            
            
            dITER(dofsX) = dPrevITER(dofsX) - deltaClassic;
            fITER        = KGLOBAL*dITER;
            QITER        = ((fITER(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P)*-1)-RPresiones)/deltaT/0.00264979 / (1000)^3;
        else
            mainSYSTEM = (K + KCohesivos);
            CTonlyFrac = CTFrac;
            CTzeros = sparse(nCREqFrac,nCREqFrac);
            
            KGLOBAL    = [mainSYSTEM    CTonlyFrac'
                CTonlyFrac    CTzeros    ];

            G       = [(K + KTanCohesivos) CTonlyFrac'
                CTonlyFrac         CTzeros    ];
            
            FITER = [  R + RP
                      sparse(nCREqFrac,1)];
                  
            dofsOnlyU = [isFixed;
                         false(nCREqFrac,1)];
            isFreeU = ~dofsOnlyU;
                  
            dR_X = ((KGLOBAL(isFreeU,isFreeU) *dPrevITER(isFreeU)) + (KGLOBAL(isFreeU,dofsOnlyU) *dPrevITER(dofsOnlyU))  - FITER(isFreeU));
            deltaClassic = G(isFreeU,isFreeU)\ dR_X;
            
        end
     
        %% ACTUALIZACION PARA LA SIGUIENTE ITERACION %%
        %%% MODIFICACION DE LA RELAJACION %%%
        nIter = nIter + 1;
        auxRemake = reshape(meshInfo.cohesivos.relatedEB,[],1);
        dN(auxRemake) = reshape(meshInfo.cohesivos.dNCalculado, [],1);
        
        dPrevITER_Error         = dPrevITER;                    % Esta linea guarda el valor de la iteracion previa para usarla en el error.
        dPrevITER               = dITER;
        dNPrevITER_Error        = dN;
        
        for iCohesivos = 1:meshInfo.nCohesivos
            [ meshInfo.cohesivos ] = gapCalculator(iCohesivos,meshInfo.nodes ,meshInfo.cohesivos, dPrevITER, dPrev);
        end
        dN(auxRemake)           = reshape(meshInfo.cohesivos.dNCalculado, [],1);
        dS1(auxRemake)          = reshape(meshInfo.cohesivos.dS1Calculado, [],1);
        dS2(auxRemake)          = reshape(meshInfo.cohesivos.dS2Calculado, [],1);
        hhIter                  = dN;
        hhIter(hhIter<0)        = 0;
        
        %% COMPUTACION DEL ERROR %%
        if strcmp(algorithmProperties.criterio,'VARIABLES')
            uITER = dPrevITER(1:paramDiscEle.nDofTot_U);
            pITER = dPrevITER(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P)*temporalProperties.preCond;
            
            uPrevITER = dPrevITER_Error(1:paramDiscEle.nDofTot_U);
            pPrevITER = dPrevITER_Error(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P)*temporalProperties.preCond;
            
            errorRelU{iTime}(1,nIter) = norm(uITER - uPrevITER ) / norm(uITER); % Antes del 12/4/2022 se normalizaba segun variables dPrevITER. 
            errorRelP{iTime}(1,nIter) = norm(pITER - pPrevITER ) / norm(pITER);
            errorRelCohesivos{iTime}(1,nIter) = norm(dN - dNPrevITER_Error) / norm(dN);

            if keyPlots == true
                figure(han1)
%                 set(han1,'Position',[1 41 768 748.8]);
                plotError
                figure(han2)
                
            end
            if errorRelU{iTime}(1,nIter) <= algorithmProperties.toleranciaU && errorRelP{iTime}(1,nIter) <= algorithmProperties.toleranciaP && errorRelCohesivos{iTime}(1,nIter) <= algorithmProperties.toleranciaCohesivos
                contadorErrorConvergido = contadorErrorConvergido + 1;
                if contadorErrorConvergido >= cantErrorConvergido
                    error = convergido;
                    contadorErrorConvergido = 0;
                end
            end
        end
        if nIter > algorithmProperties.nIterDiv
            if iTime == 1
                dPrev   = [ sparse(paramDiscEle.nDofTot_U,1)                                                                    
                            physicalProperties.poroelasticas.pPoral / temporalProperties.preCond * ones(paramDiscEle.nDofTot_P,1) 
                            sparse(nCREqFluidos,1)                                                                                
                            sparse(nCREqFrac,1)];  
                                                                                                   
                hhPrev  = zeros(meshInfo.nElEB,1); % hh0
            else
                hhPrev      = hhTimes(:,iTime - 1);
                dPrev       = dTimes(:,iTime-1);
            end
            
            dPrevITER       = dPrev;
            hhIter          = hhPrev;
            dN              = dNPrev;
            dS1             = dS1Prev;
            dS2             = dS2Prev;
            error           = noConvergido;
            nIter           = 0;
            disp(['Paso las ',num2str(algorithmProperties.nIterDiv),' iteraciones, divirgió, se reduce el timestep 10 veces y se comienza nuevamente'])
            deltaT          = deltaT/10;
            if deltaT <= 1e-9
                warning 'Error: deltaT <= 1e-9. Posible divergencia eterna. Revisar parametros.';
                assert(deltaT > 1e-9)
            end
            temporalProperties.deltaTs(iTime) = deltaT;
            display(deltaT);
            algorithmProperties.flagDiv  = 1;
            
            errorRelU{iTime} = [];
            errorRelP{iTime} = [];
            errorRelCohesivos{iTime} = [];
            
        end
    end
    disp('Tiempo de iteraciones')
    toc;  
    %% ALGORITMO DE TIMESTEPS %%
    auxx = sprintf('Convirgio en %d iteraciones',nIter);
    disp(auxx)
    
    if algorithmProperties.elapsedTime <= temporalProperties.tInicioISIP
        fprintf(['Fractura N: ',num2str(1),'\n'])
        auxx = sprintf('Tiempo de fractura: %d s de %d s',algorithmProperties.elapsedTime,temporalProperties.tInicioISIP);
        disp(auxx)
    elseif algorithmProperties.elapsedTime <= temporalProperties.tFinalISIP
        fprintf('ISIP\n')
        auxx = sprintf('Tiempo de ISIP: %d s de %d s',algorithmProperties.elapsedTime - temporalProperties.tInicioISIP, temporalProperties.tiempoISIP);
        disp(auxx)
    else
        fprintf(['Produccion a ','p',' cte\n'])
        auxx = sprintf('Tiempo de Produccion: %d s de %d s',algorithmProperties.elapsedTime - temporalProperties.tFinalISIP,temporalProperties.tiempoProduccion);
        disp(auxx)
    end
    fprintf(['Tiempo total de corrida: ',num2str(algorithmProperties.elapsedTime ),' de ',num2str(temporalProperties.tiempoTotalCorrida),'\n'])
    
    
    if iTime > temporalProperties.drainTimes
        algorithmProperties.elapsedTime = algorithmProperties.elapsedTime + deltaT;
    end
    
    if iTime > (temporalProperties.drainTimes + temporalProperties.initTimes)
        if algorithmProperties.elapsedTime >= temporalProperties.tInicioISIP && algorithmProperties.elapsedTime < temporalProperties.tFinalISIP
            temporalProperties.deltaTs(iTime + 1) = temporalProperties.deltaTISIP;
        else
            if algorithmProperties.elapsedTime > temporalProperties.tFinalISIP
                temporalProperties.deltaTMax = temporalProperties.deltaTProduccionMax; % Actualiza el maximo del timestep para la produccion.
            end
                if nIter< algorithmProperties.nIterFast && algorithmProperties.flagDiv == 0
                    disp('Convergencia rapida, deltaT = deltaT*2')
                    temporalProperties.deltaTs(iTime + 1) = deltaT*2;
                else
                    if nIter>= algorithmProperties.nIterSlow
                        disp('Convergencia lenta, deltaT = deltaT/2')
                        temporalProperties.deltaTs(iTime + 1) = deltaT/2;
                    else
                        disp('Convergencia regular deltaT se mantiene')
                        temporalProperties.deltaTs(iTime + 1) = deltaT;
                    end
                end
                if deltaT*2 > temporalProperties.deltaTMax
                    temporalProperties.deltaTs(iTime + 1) = deltaT; % Si converge rapido pero el proximo deltaT es mayor a 1s se deja como estaba.
                    disp('deltaT del proximo timestep mayor a deltaTMax, se deja fijo el anterior')
                end
        end
        if algorithmProperties.elapsedTime + temporalProperties.deltaTs(iTime + 1) > temporalProperties.tInicioISIP && algorithmProperties.elapsedTime < temporalProperties.tInicioISIP
            temporalProperties.deltaTs(iTime + 1) = temporalProperties.tInicioISIP - algorithmProperties.elapsedTime;
        end
    end
       
    algorithmProperties.flagDiv = 0;
    disp('siguiente deltaT = ')
    disp(temporalProperties.deltaTs(iTime+1))
    %% ACTUALIZO CON LOS VALORES CONVERGIDOS %%
    dTimes(:,iTime)                 = dITER;
    QTimes(:,iTime)                 = QITER;
    hhTimes(:,iTime)                = hhIter;
    meshInfo.cohesivos.dS1Times(:,:,iTime)   = meshInfo.cohesivos.dS1Calculado;
    meshInfo.cohesivos.dS2Times(:,:,iTime)   = meshInfo.cohesivos.dS2Calculado;
    meshInfo.cohesivos.dNTimes(:,:,iTime)    = meshInfo.cohesivos.dNCalculado;
    
    %% ACTUALIZACION DE LOS FLAGS DE LOS COHESIVOS Y SUS VARIABLES %%
    for iCohesivos = 1:meshInfo.nCohesivos
        for iPg = 1:4
            [meshInfo.cohesivos] = updateCohesivoNorm(meshInfo.cohesivos,meshInfo.cohesivos.dNCalculado(iCohesivos,iPg),meshInfo.cohesivos.dNCalculadoPrev(iCohesivos,iPg),iCohesivos,iTime,iPg);
            [meshInfo.cohesivos] = updateCohesivoShearKsi(meshInfo.cohesivos,meshInfo.cohesivos.dS1Calculado(iCohesivos,iPg),meshInfo.cohesivos.dS1CalculadoPrev(iCohesivos,iPg),iCohesivos,iTime,iPg);
            [meshInfo.cohesivos] = updateCohesivoShearEta(meshInfo.cohesivos,meshInfo.cohesivos.dS2Calculado(iCohesivos,iPg),meshInfo.cohesivos.dS2CalculadoPrev(iCohesivos,iPg),iCohesivos,iTime,iPg);
        end
    end
    
    meshInfo.cohesivos.KnTimes(:,:,iTime)  = meshInfo.cohesivos.KnIter;
    meshInfo.cohesivos.Ks1Times(:,:,iTime) = meshInfo.cohesivos.Ks1Iter;
    meshInfo.cohesivos.Ks2Times(:,:,iTime) = meshInfo.cohesivos.Ks2Iter;
    
    meshInfo.cohesivos.KnPrevTime          = meshInfo.cohesivos.KnIter;
    meshInfo.cohesivos.Ks1PrevTime         = meshInfo.cohesivos.Ks1Iter;
    meshInfo.cohesivos.Ks2PrevTime         = meshInfo.cohesivos.Ks2Iter;
    
    %% ACTUALIZACION DE VECTORES DE PROPAGACIÓN %%
    
    nodosMuertos             = reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlag))),:),[],1);
    % aca tengo que fijarme si de los nodos muertos alguno es un nodo de la
    % interseccion y adicionarle que mate a todos los nodos cohesivos de
    % los elementos que contengan este nodo interseccion
    if any(ismember(find(nodTripleEncuentro),nodosMuertos)) && ~keyAgusCheck
        disp('LCDTMAllBoys')
        % hay que sacarlo -> pero es un beta para ver la propagacion en el
        % encuentro. Va a entrar a este "if" si se rompe un nodo de la
        % triple interseccion. Aca no hay que sacar el keyAgus. Pero
        % arreglando lo del mallador deberian cambiar de nombre alguna
        % estructura. 
    end
    [nodosMuertos, meshInfo.cohesivos] = fcnDeadGathering(meshInfo.cohesivos,nodosMuertos,nodTripleEncuentro);
    
    deadIntNodes             = ismember(intNodes,nodosMuertos);
    
    if any(deadIntNodes)
        deadIntNodesIndex    = intNodes(deadIntNodes);
        nodesToAdd           = nonzeros(unique(reshape(meshInfo.CRFluidos(sum(ismember(meshInfo.CRFluidos,deadIntNodesIndex),2)>0,:),[],1)));
        nodosMuertos         = unique([nodosMuertos
                                       nodesToAdd ]);
    end
    
    meshInfo.elementsFisu.ALL.nodesInFisu = zeros(size(meshInfo.elementsFisu.ALL.nodes));
    auxElements                           = meshInfo.elements(meshInfo.elementsFisu.ALL.index,:);
    meshInfo.elementsFisu.ALL.nodesInFisu(meshInfo.elementsFisu.ALL.nodes) = auxElements(meshInfo.elementsFisu.ALL.nodes);
    
    meshInfo.elementsFisu.fracturados                           = sum(ismember(meshInfo.elementsFisu.ALL.nodesInFisu,nodosMuertos),2) > 0;    % Este vector indica, segun como esten ordenados los elementsFisu, quienes de ellos
    % se comportan como parte de la fractura.
    meshInfo.elementsFluidos.activos                            = sum(ismember(meshInfo.elementsFluidos.elements,nodosMuertos),2) > 0;        % Este vector indica, segun como esten ordenados los elementsFluidos, quienes estan activos.
    meshInfo.cohesivos.biot(meshInfo.elementsFluidos.activos,:) = 1;
    meshInfo.cohesivos.elementsFluidosActivos                   = meshInfo.elementsFluidos.activos;
    meshInfo.cohesivos.deadFlagTimes(:,:,iTime+1)               = meshInfo.cohesivos.deadFlag;    
%     assert(~any(ismember(meshInfo.cohesivos.elements(meshInfo.cohesivos.deadFlag),meshInfo.nodosGendarmes)),['Fractura excede limites. Tiempo de corrida = ',num2str(algorithmProperties.elapsedTime),'s'])
    
    if keyPlots == true
        figure(han2)
%         set(han2,'Position',[769.8 41.8 766.4 740.8]);
        clf
        subplot(1,2,1)
        bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dNTimes(:,:,iTime))
        axis square
        view(-45,20)
        daspect([1 1 1])
        hold on
        %         scatter3(meshInfo.nodes(reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1),1),meshInfo.nodes(reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1),2),meshInfo.nodes(reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1),3),'r')
        scatter3(meshInfo.nodes(nodosMuertos,1),meshInfo.nodes(nodosMuertos,2),meshInfo.nodes(nodosMuertos,3),'r')
        title(['iTime: ',num2str(iTime)])

        subplot(1,2,2)
        presion = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
        plotColo(meshInfo.nodes,meshInfo.elementsFluidos.elements,presion)
        axis square
        view(-45,20)
        daspect([1 1 1])
        title(['iTime: ',num2str(iTime)])
        drawnow
  
        
    end
    % Indica el final de la operacion.
    if algorithmProperties.elapsedTime >= temporalProperties.tiempoTotalCorrida
        display(algorithmProperties.elapsedTime)
        disp('FIN DE LA CORRIDA, SE LLEGO AL TIEMPO TOTAL')
        temporalProperties.nTimes = iTime;
    end
    
    %% Guardados parciales.
    if ~isempty(tSaveParcial) && iSaveParcial <= numel(tSaveParcial) && strcmpi(guardarCorrida,'Y')
        if algorithmProperties.elapsedTime >= tSaveParcial(iSaveParcial)
            iSaveParcial = iSaveParcial + 1;
            temporalProperties.nTimes = iTime;
            save(['resultadosPARCIALESCorrida_',nombreCorrida,'_numero_',num2str(iSaveParcial),'.mat']);    % Se guarda la informacion obtenida.
        end
    end
    if algorithmProperties.elapsedTime >= temporalProperties.tInicioISIP && flagSaveFrac == 1
        if strcmpi(guardarCorrida,'Y')
            flagSaveFrac =0;
            save(['resultadosFinFractura_',nombreCorrida]); % Se guardan los resultados parciales al final de proceso de fractura.
        end
    elseif algorithmProperties.elapsedTime >= temporalProperties.tFinalISIP && flagSaveISIP == 1 &&  strcmpi(guardarCorrida,'Y')
        flagSaveISIP = 0;
        save(['resultadosFinISIP_',nombreCorrida]); % Se guardan los resultados parciales al final del ISIP.
    end
end
%%
%-------------------------------------------------------------------------%
%%                       GUARDADO DE INFORMACION                         %%
%-------------------------------------------------------------------------%
if strcmpi(guardarCorrida,'Y')
    clear han1 han2
    cd('D:\Geomec\paper DFN\ITBA\Piloto\DFIT\Resultados de corridas (.mat)\')
    mkdir(nombreCorrida) % Crea una subcarpeta en Resultado de corridas donde se guardara la informacion obtenida.
    cd([direccionGuardado,nombreCorrida])
    save(['resultadosCorrida_',nombreCorrida,'.mat']);    % Se guarda la informacion obtenida.
    guardarPropiedades(archivoLectura,nombreCorrida)
    guardarTXT
    fclose('all');

%     movefile(['propiedades_',nombreCorrida,'.txt'],[direccionGuardado,nombreCorrida]);
%     movefile(['tiempo_',nombreCorrida,'.txt'],[direccionGuardado,nombreCorrida]);
%     movefile(['presion_',nombreCorrida,'.txt'],[direccionGuardado,nombreCorrida]);
%     movefile(['Q_',nombreCorrida,'.txt'],[direccionGuardado,nombreCorrida]);
    
    if exist(['resultadosFinISIP_',nombreCorrida,'.mat'],'file') == 2
        cd([DirectorioMadre 'scripSolverGitHub\'])
        movefile(['resultadosFinISIP_',nombreCorrida,'.mat'],[direccionGuardado,nombreCorrida]);
    end
    if exist(['resultadosFinFractura_',nombreCorrida,'.mat'],'file') == 2
        cd([DirectorioMadre 'scripSolverGitHub\'])
        movefile(['resultadosFinFractura_',nombreCorrida,'.mat'],[direccionGuardado,nombreCorrida]);
    end
    
    if ~isempty(tSaveParcial)
        for i = 1:numel(tSaveParcial)
            cd([DirectorioMadre 'scripSolverGitHub\'])
            movefile(['resultadosPARCIALESCorrida_',nombreCorrida,'_numero_',num2str(i),'.mat'],[direccionGuardado,nombreCorrida]);
        end
    end
end


%-------------------------------------------------------------------------%
%%                            POST - PROCESO                             %%
%-------------------------------------------------------------------------%
% Presion nodo bomba vs tiempo:
% plotPresionCaudal

% Area de fractura vs tiempo:
% setear "tiempoArea" para ver la fractura en el t necesario.
% plotAreaVolTripleT  

% Tensiones para un iTime en particular:
% setear "tiempoTensiones" para ver las tensiones en el t necesario.
% plotTensionesSinPromediar

%% Alarma de finalizacion.
%- Alarma sonora de fin de corrida.
% load gong
% sound(y,Fs)  


