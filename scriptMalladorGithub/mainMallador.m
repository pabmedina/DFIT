%% START %%
clc; clear; close all;
nameData = 'testComun'; % Nombre del archivo de salida.

saveData = false;
debugPlots = 1;
barrerasFlag = 0;
DFN_flag = 0;

mainFolder = 'D:\Geomec\paper DFN\ITBA\Piloto\DFIT\'; % el mainFolder cambia segun usuario
pathDir

%% MESH PARAMETERS %%
gap = 1e-4;
nX = 3; nY = 1; nZ = 5; %Cantidad de fracturas en cada direccion
DFN_ang  = 15;

X0 = 1e4; %Ubicacion inicial fractura normal X
dX = 4e3; %Distancia entre fracturas X

Z0  = 24e3; %Ubicacion inicial fractura normal Z
dZ0 = [4e3 4e3 4e3 6e3 4e3];%Distancia entre fracturas Z
%% MESH LOADING %%
% LOAD NODES FROM ADINA %%
nodes                   = load('nodesV3.txt');
%nodesV2 tiene refinamiento a 1m, nodesV3 a 2m
mapeoNodos              = nodes(:,1);
nNod                    = size(nodes,1);
nodes(:,[1 5])          = [];
elements                = load('elementsV3.txt'); %idem
elements(:,[1 10:end])  = [];
nel                     = size(elements,1);
disp('gap')
disp(gap)
tol = 1;

% MUEVO EL SISTEMA DE COORDENADAS A LA ESQUINA MAS AUSTRAL %%%%
moverEjes               = [-min(nodes(:,1))*ones(nNod,1) -min(nodes(:,2))*ones(nNod,1) -min(nodes(:,3))*ones(nNod,1)];
nodes                   = nodes + moverEjes;

% Arreglo para que la numeracion de nodos arranque en 1%%
for iNod = 1:size(nodes,1)
    nodoAMapear = mapeoNodos(iNod);
    elements(ismember(elements,nodoAMapear)) = iNod;
end

%grafico de la malla
figure('Name','Malla inicial','NumberTitle','off')
plotMeshColo3D(nodes,elements,'w');
xlabel('x')
ylabel('y')
zlabel('z')
hold off
%% ELEMENTS Y NODES SIN MODIFICAR %%
elementsVanilla = elements;
nodesVanilla    = nodes;
nodes           = round(nodes, 3);
nodes           = nodes*1e3;

%% DIMENSIONES DOMINIO %%
anchoX = max(nodes(:,1));
anchoY = max(nodes(:,2));
anchoZ = max(nodes(:,3));

xPositions = unique(nodes(:,1));

%% BARRERAS %%

if barrerasFlag == 1
    barreras.posicion{1} = 36e3;
    barreras.posicion{2} = 48e3;
    
    barreras.tol         = 2e-5;
    barreras.espesor     = 2e3;
    barreras.n           = length(barreras.posicion);
    
    for i = barreras.n:-1:1
        [nodes,elements] = generadorDeBarreras(barreras.posicion{i},barreras.espesor,nodes,elements,tol,0);
    end
    figure('Name','Malla con barreras','NumberTitle','off')
    plotMeshColo3D(nodes,elements,'w')
    xlabel 'x'
    ylabel 'y'
    zlabel 'z'
else
    barreras.n=0;
    barreras.espesor =0;
end
%% ACTUALIZACIÓN DOMINIO %%
anchoX = max(nodes(:,1));
anchoY = max(nodes(:,2));
anchoZ = max(nodes(:,3));

xPositions = unique(nodes(:,1));

%% FRACTURAS
% CANTIDADES
% Ingresar manualmente la cantidad de fracturas de cada normal
% Ingresar valor angular en grados
DFN_matrix = [cosd(DFN_ang), sind(DFN_ang),0;-sind(DFN_ang), cosd(DFN_ang), 0;0 0 1];
% ANCHO
% Ingresar manualmente el ancho de cada fractura en cada direccion
for i = 1:nX
    fractura.anchoY{1,i} = 20e3;
    fractura.anchoZ{1,i} = 30e3;
end
fractura.anchoX{2,1} = 20e3;
fractura.anchoZ{2,1} = 30e3;
for i = 1:nZ
    fractura.anchoX{3,i} = 20e3;
    fractura.anchoY{3,i} = 20e3;
end


% POSICION
% Ingresar manualmente la posicion de cada fractura en cada direccion

for i = 1:nX
    fractura.posicionX{1,i} = X0+dX*(i-1);
    fractura.posicionY{1,i} = [20e3 20e3+fractura.anchoY{1,i}];
    fractura.posicionZ{1,i} = [20e3 20e3+fractura.anchoZ{1,i}+barreras.n*barreras.espesor];
end
fractura.posicionX{2,1} = [0 fractura.anchoX{2,1}];
fractura.posicionY{2,1} = anchoY/2;
fractura.posicionZ{2,1} = [20e3 20e3+fractura.anchoZ{2,1}+barreras.n*barreras.espesor];
for i = 1:nZ
    fractura.posicionX{3,i} = [0 fractura.anchoX{3,i}];
    fractura.posicionY{3,i} = [(anchoY-fractura.anchoY{3,i})/2 (anchoY+fractura.anchoY{3,i})/2];
    if i == 1
        fractura.posicionZ{3,i} = Z0;
    else
        fractura.posicionZ{3,i} = fractura.posicionZ{3,i-1} +dZ0(i-1);
    end
end
fractura = verifyFrac(nodes, fractura,nX,nY,nZ);
%% NODOS FRACTURAS %%
% Cada bucle identifica los nodos de las fracturas en cada una de las tres
% dimensiones

for i = 1:nX
    [nodesFisu.coords{1,i}, nodesFisu.index{1,i}]  = nodosFracturasX(fractura.posicionX{1,i},fractura.posicionY{1,i},fractura.posicionZ{1,i},nodes,tol);
end
for i = 1:nY
    [nodesFisu.coords{2,i}, nodesFisu.index{2,i}]  = nodosFracturasY(fractura.posicionX{2,i},fractura.posicionY{2,i},fractura.posicionZ{2,i},nodes,tol);
end
for i = 1:nZ
    [nodesFisu.coords{3,i}, nodesFisu.index{3,i}]  = nodosFracturasZ(fractura.posicionX{3,i},fractura.posicionY{3,i},fractura.posicionZ{3,i},nodes,tol);
end
if debugPlots == 1
    figure('Name','Nodos de fracturas','NumberTitle','off'); hold on
    for i = 1:nX
        scatter3(nodesFisu.coords{1,i}(:,1),nodesFisu.coords{1,i}(:,2),nodesFisu.coords{1,i}(:,3));
    end
    for i = 1:nY
        scatter3(nodesFisu.coords{2,i}(:,1),nodesFisu.coords{2,i}(:,2),nodesFisu.coords{2,i}(:,3));
    end
    for i = 1:nZ
        scatter3(nodesFisu.coords{3,i}(:,1),nodesFisu.coords{3,i}(:,2),nodesFisu.coords{3,i}(:,3));
    end
end

%% INTERSECCION %%
%encuentra los nodos que estan en mas de una fractura
% nodesInt.dobles{I,J,K}: - Para fracturas XY: I = 1
%                                              J = orden de X
%                                              K = orden de Y
%                         - Para fracturas YZ: I = 2
%                                              J = orden de Y
%                                              K = orden de Z
%                         - Para fracturas XZ: I = 3
%                                              J = orden de X
%                                              K = orden de Z
%
% nodesInt.triples{IJK}: I = orden X; J = orden Y; K = orden Z
nodesInt.all = [];
nodesInt.triplesAll =[];
for i = 1:nX
    for j = 1:nY
        nodesInt.dobles{1,i,j} = nodesFisu.index{1,i}(ismember(nodesFisu.index{1,i}, nodesFisu.index{2,j}));
        nodesInt.all = [nodesInt.all;nodesInt.dobles{1,i,j}];
    end
end
for i = 1:nY
    for j = 1:nZ
        nodesInt.dobles{2,i,j} = nodesFisu.index{2,i}(ismember(nodesFisu.index{2,i}, nodesFisu.index{3,j}));
        nodesInt.all = [nodesInt.all;nodesInt.dobles{2,i,j}];
    end
end
for i = 1:nX
    for j = 1:nZ
        nodesInt.dobles{3,i,j} = nodesFisu.index{1,i}(ismember(nodesFisu.index{1,i}, nodesFisu.index{3,j}));
        nodesInt.all = [nodesInt.all;nodesInt.dobles{3,i,j}];
    end
end
for i = 1:nX
    for j = 1:nY
        for k = 1:nZ
            nodesInt.triples{i,j,k} = nodesFisu.index{1,i}(ismember(nodesFisu.index{1,i}, nodesFisu.index{2,j}));
            nodesInt.triples{i,j,k} = nodesInt.triples{i,j,k}(ismember(nodesInt.triples{i,j,k}, nodesFisu.index{3,k}));
            nodesInt.triplesAll = [nodesInt.triplesAll;nodesInt.triples{i,j,k}];
            try
                elementsTripleInt{i,j,k} = find(sum(elements==nodesInt.triples{i,j,k},2));
            end
        end
    end
end
%% NODOS FRACTURAS SIN INTERSECCIONES %%
%encuentra los nodos que estan en una unica fractura

for i = 1:nX
    nodesFisu.sinInt{1,i} = removeIntNodes(nodesFisu.index{1,i},nodesInt.all);
end
for i = 1:nY
    nodesFisu.sinInt{2,i} = removeIntNodes(nodesFisu.index{2,i},nodesInt.all);
end
for i = 1:nZ
    nodesFisu.sinInt{3,i} = removeIntNodes(nodesFisu.index{3,i},nodesInt.all);
end
if debugPlots == 1
    figure('Name','Nodos de fracturas sin intersecciones','NumberTitle','off'); hold on
    for i = 1:nX
        scatter3(nodes(nodesFisu.sinInt{1,i},1),nodes(nodesFisu.sinInt{1,i},2),nodes(nodesFisu.sinInt{1,i},3));
    end
    for i = 1:nY
        scatter3(nodes(nodesFisu.sinInt{2,i},1),nodes(nodesFisu.sinInt{2,i},2),nodes(nodesFisu.sinInt{2,i},3));
    end
    for i = 1:nZ
        scatter3(nodes(nodesFisu.sinInt{3,i},1),nodes(nodesFisu.sinInt{3,i},2),nodes(nodesFisu.sinInt{3,i},3));
    end
end
% Verifico que la matriz de conectividades tenga nodos existentes
nodesID = (1:size(nodes,1))';
vecInMatrix(nodesID, elements);
elements = conectivityCheck(elements, nodes);
%% ELEMENTOS FRACTURAS %%
%encuentra los elementos que conforman los planos de fractura
elementsFisu.all.index =[];
elementsFisu.all.nodes =false(1,8);
for i = 1:nX
    [elementsFisu.index{1,i},  elementsFisu.nodes{1,i}]  = elementsFracturas(elements,nodesFisu.index{1,i});
    elementsFisu.all.index = [elementsFisu.all.index; elementsFisu.index{1,i}];
    elementsFisu.all.nodes = [elementsFisu.all.nodes; elementsFisu.nodes{1,i}];
end
for i = 1:nY
    [elementsFisu.index{2,i},  elementsFisu.nodes{2,i}]  = elementsFracturas(elements,nodesFisu.index{2,i});
    elementsFisu.all.index = [elementsFisu.all.index; elementsFisu.index{2,i}];
    elementsFisu.all.nodes = [elementsFisu.all.nodes; elementsFisu.nodes{2,i}];
end
for i = 1:nZ
    [elementsFisu.index{3,i},  elementsFisu.nodes{3,i}]  = elementsFracturas(elements,nodesFisu.index{3,i});
    elementsFisu.all.index = [elementsFisu.all.index; elementsFisu.index{3,i}];
    elementsFisu.all.nodes = [elementsFisu.all.nodes; elementsFisu.nodes{3,i}];
end
elementsFisu.all.nodes(1,:)=[];
if debugPlots == 1
    figure('Name','Elementos de fracturas','NumberTitle','off'); hold on
    plotMeshColo3D(nodes,elements,'k',0.05)
    plotMeshColo3D(nodes,elements(elementsFisu.all.index,:,:),'r',1)
    
end


%% ELEMENTOS MINUS PLUS %%
%divide a los elementos de una fractura en parte de abajo y parte de arriba

for i = 1:nX
    [elementsFisu.minus{1,i},elementsFisu.plus{1,i}] = elementsPlusMinusX(nodesFisu.index{1,i},nodes,elements,elementsFisu.index{1,i});
end
for i = 1:nY
    [elementsFisu.minus{2,i},elementsFisu.plus{2,i}] = elementsPlusMinusY(nodesFisu.index{2,i},nodes,elements,elementsFisu.index{2,i});
end
for i = 1:nZ
    [elementsFisu.minus{3,i},elementsFisu.plus{3,i}] = elementsPlusMinusZ(nodesFisu.index{3,i},nodes,elements,elementsFisu.index{3,i});
end
if debugPlots == 1
    figure('Name','Elementos Minus-Plus','NumberTitle','off'); hold on; plotMeshColo3D(nodes,elements,'k',0.05);
    for i = 1:nX
        plotMeshColo3D(nodes,elements(elementsFisu.minus{1,i},:),'r',1)
        plotMeshColo3D(nodes,elements(elementsFisu.plus{1,i},:),'y',1)
    end
    for i = 1:nY
        plotMeshColo3D(nodes,elements(elementsFisu.minus{2,i},:),'r',1)
        plotMeshColo3D(nodes,elements(elementsFisu.plus{2,i},:),'y',1)
    end
    for i = 1:nZ
        plotMeshColo3D(nodes,elements(elementsFisu.minus{3,i},:),'r',1)
        plotMeshColo3D(nodes,elements(elementsFisu.plus{3,i},:),'y',1)
    end
end

%% A PARTIR DE AHORA COMIENZA LA SEPARACIÓN (LOS PLUS),GENERACION DE GAP,NODOS DE FLUIDOS Y ELEMENTS BARRA %%
%%% Primero se separan todos los elementos y nodos que no son parte
%%% de alguna interseccion.

nNod = size(nodes,1);
nodesNew = nodes;
elementsBarra.ALL         = [];
nodosFluidos.coords       = [];
nodosFluidos.index        = [];
nodosFluidos.EB_Asociados = [];
nElementsBarra            = 0;
%% FISURAS X %%
for i = 1:nX
    nodesNew_LastPosition = size(nodesNew,1);
    nodesNew = nodesGenerator(nodesFisu.sinInt{1,i},nodes,nodesNew,gap,1);
    
    % ELEMENTS BARRA Y NODOS FLUIDOS
    elementsBarra.X{i}          = [nodesFisu.sinInt{1,i} (nodesNew_LastPosition+1:size(nodesNew,1))'];
    nodosFluidos.coords         = [nodosFluidos.coords
        nodes(nodesFisu.sinInt{1,i},:)];
    nodosFluidos.index          = [nodosFluidos.index
        nodesFisu.sinInt{1,i}];
    nodosFluidos.EB_Asociados   = [nodosFluidos.EB_Asociados
        (nElementsBarra+1:1:size(nodosFluidos.coords,1))'];
    lastEB                      = size(elementsBarra.ALL,1);
    nNewEBs                     = size(elementsBarra.X{i},1);
    EBindex.X{i}                = [(lastEB+1:1:lastEB+nNewEBs)'];
    elementsBarra.ALL           = [elementsBarra.ALL; elementsBarra.X{i}];
    nElementsBarra              = size(elementsBarra.ALL,1);
    
    %%% Se arreglan las conexiones elementales
    
    nelPlus = size(elementsFisu.plus{1,i},1);
    
    for iEle = 1:nelPlus
        element                = elementsFisu.plus{1,i}(iEle);
        nodesInElement         = elements(element,:);
        [indexA]               = ismember(nodesInElement,nodesFisu.sinInt{1,i});
        [~, indexB]            = ismember(nodesInElement(indexA),nodesFisu.sinInt{1,i});
        replacementNodes       = indexB + ones(size(indexB))*nodesNew_LastPosition;
        nodesInElement(indexA) = replacementNodes;
        elements(element,:)    = nodesInElement;
    end
end
% Verifico que la matriz de conectividades tenga nodos existentes
nodesID = (1:size(nodesNew,1))';
vecInMatrix(nodesID, elements);
elements = conectivityCheck(elements, nodesNew);
nodes = nodesNew;

%% FISURAS Y %%
for i = 1:nY
    nodesNew_LastPosition = size(nodesNew,1);
    nodesNew = nodesGenerator(nodesFisu.sinInt{2,i},nodes,nodesNew,gap,2);
    
    % ELEMENTS BARRA Y NODOS FLUIDOS
    elementsBarra.Y{i}          = [nodesFisu.sinInt{2,i} (nodesNew_LastPosition+1:size(nodesNew,1))'];
    nodosFluidos.coords         = [nodosFluidos.coords
        nodes(nodesFisu.sinInt{2,i},:)];
    nodosFluidos.index          = [nodosFluidos.index
        nodesFisu.sinInt{2,i}];
    nodosFluidos.EB_Asociados   = [nodosFluidos.EB_Asociados
        (nElementsBarra+1:1:size(nodosFluidos.coords,1))'];
    lastEB                      = size(elementsBarra.ALL,1);
    nNewEBs                     = size(elementsBarra.Y{i},1);
    EBindex.Y{i}                = [(lastEB+1:1:lastEB+nNewEBs)'];
    elementsBarra.ALL           = [elementsBarra.ALL; elementsBarra.Y{i}];
    nElementsBarra              = size(elementsBarra.ALL,1);
    
    
    %%% Se arreglan las conexiones elementales
    
    nelPlus = size(elementsFisu.plus{2,i},1);
    
    for iEle = 1:nelPlus
        element                = elementsFisu.plus{2,i}(iEle);
        nodesInElement         = elements(element,:);
        [indexA]               = ismember(nodesInElement,nodesFisu.sinInt{2,i});
        [~, indexB]            = ismember(nodesInElement(indexA),nodesFisu.sinInt{2,i});
        replacementNodes       = indexB + ones(size(indexB))*nodesNew_LastPosition;
        nodesInElement(indexA) = replacementNodes;
        elements(element,:)    = nodesInElement;
    end
end
% Verifico que la matriz de conectividades tenga nodos existentes
nodesID = (1:size(nodesNew,1))';
vecInMatrix(nodesID, elements);
elements = conectivityCheck(elements, nodesNew);
nodes= nodesNew;
%% FISURAS Z %%
for i = 1:nZ
    nodesNew_LastPosition = size(nodesNew,1);
    nodesNew = nodesGenerator(nodesFisu.sinInt{3,i},nodes,nodesNew,gap,3);
    
    % ELEMENTS BARRA Y NODOS FLUIDOS
    elementsBarra.Z{i}          = [nodesFisu.sinInt{3,i} (nodesNew_LastPosition+1:size(nodesNew,1))'];
    nodosFluidos.coords         = [nodosFluidos.coords
        nodes(nodesFisu.sinInt{3,i},:)];
    nodosFluidos.index          = [nodosFluidos.index
        nodesFisu.sinInt{3,i}];
    nodosFluidos.EB_Asociados   = [nodosFluidos.EB_Asociados
        (nElementsBarra+1:1:size(nodosFluidos.coords,1))'];
    lastEB                      = size(elementsBarra.ALL,1);
    nNewEBs                     = size(elementsBarra.Z{i},1);
    EBindex.Z{i}                = [(lastEB+1:1:lastEB+nNewEBs)'];
    elementsBarra.ALL           = [elementsBarra.ALL
        elementsBarra.Z{i}];
    nElementsBarra              = size(elementsBarra.ALL,1);
    
    % Se arreglan las conexiones elementales
    nelPlus = size(elementsFisu.plus{3,i},1);
    
    for iEle = 1:nelPlus
        element                = elementsFisu.plus{3,i}(iEle);
        nodesInElement         = elements(element,:);
        [indexA]               = ismember(nodesInElement,nodesFisu.sinInt{3,i});
        [~, indexB]            = ismember(nodesInElement(indexA),nodesFisu.sinInt{3,i});
        replacementNodes       = indexB + ones(size(indexB))*nodesNew_LastPosition;
        nodesInElement(indexA) = replacementNodes;
        elements(element,:)    = nodesInElement;
    end
end
% Verifico que la matriz de conectividades tenga nodos existentes
nodesID  = (1:size(nodesNew,1))';
vecInMatrix(nodesID, elements);
elements = conectivityCheck(elements, nodesNew);
nodes    = nodesNew;
if debugPlots == 1
    figure('Name','Separacion Fisuras','NumberTitle','off');hold on
    Draw_Barra(elementsBarra.ALL,nodesNew,'k')
    for i = 1:nX
        PlotMesh(nodesNew,elements(elementsFisu.index{1,i},:,:))
    end
    for i = 1:nY
        PlotMesh(nodesNew,elements(elementsFisu.index{2,i},:,:))
    end
    for i = 1:nZ
        PlotMesh(nodesNew,elements(elementsFisu.index{3,i},:,:))
    end
end
%% Elementos que NO estan en elementsFisu para FRACTURA Y %%
elementsMedium    = (1:1:size(elements,1))';
elementsMedium    = setdiff(elementsMedium, elementsFisu.index{2,1});
nelElementsMedium = size(elementsMedium,1);
plusSelector      = false(nelElementsMedium,1);

%%% Busco los que estan del lado plus de la fractura!
for iEle = 1:nelElementsMedium
    
    element        = elementsMedium(iEle);
    nodesInElement = elements(element,:);
    nodeCoordsY    = nodesNew(nodesInElement,2);
    if sum(nodeCoordsY>(fractura.posicionY{2,1}))>=4
        plusSelector(iEle) = true;
    end
end
elementsMediumPlus = elementsMedium(plusSelector);

if debugPlots == 1
    
    figure('Name', 'Mitad de malla 1','NumberTitle','off');
    hold on
    plotMeshColo3D(nodesNew,elements(elementsMedium,:),'k',0.05)
    plotMeshColo3D(nodesNew,elements(elementsMediumPlus,:),'r',1)
    figure('Name', 'Mitad de malla 2','NumberTitle','off');
    plotMeshColo3D(nodesNew,elements(elementsMediumPlus,:))
    
    figure('Name', 'Mitad de malla 3','NumberTitle','off');
    hold on
    plotMeshColo3D(nodesNew,elements(elementsMediumPlus,:),'r',1)
    plotMeshColo3D(nodesNew,elements(elementsFisu.plus{2,1},:),'y',1)
    hold on
    Draw_Barra(elementsBarra.ALL,nodesNew,'k')
    figure('Name', 'Mitad de malla 4','NumberTitle','off');
    hold on
    plotMeshColo3D(nodesNew,elements(elementsMediumPlus,:),'r',1)
    plotMeshColo3D(nodesNew,elements(elementsFisu.plus{2,1},:),'y',1)
end

%% CONSTRAINTS FLUIDOS %%
CRFluidos = [elementsBarra.ALL zeros(size(elementsBarra.ALL,1),3)];

%% INTERSECCIONES %%
%%% intRelations tiene todos los grupos de 4 nodos que se encuentran en la
%%% interseccion, servira para CR y para los CTFluidos.

elementsBarra.INT = [];
intNodesAll       = [];
%% INTERSECCIONES DOBLES
for i = 1:nX
    for j = 1:nY
        nodesInt.dobles{1,i,j} = nodesInt.dobles{1,i,j}(~ismember(nodesInt.dobles{1,i,j},nodesInt.triplesAll));
        [elements,nodesNew,nodosFluidos,elementsBarra,EBindex,intRelations] = gapInterseccionesEBYX(nodesInt.dobles{1,i,j},nodesNew,gap,...
            elementsFisu.plus{1,i},elementsFisu.plus{2,j},elements,nodosFluidos,elementsBarra,EBindex,i,j);
        CRFluidos = [ CRFluidos
            [intRelations zeros(size(intRelations,1),1)] ];
        intRelatedNodes{1,i,j} = intRelations;
        
        if debugPlots == 1
            nombre = ['Separacion interseccion X' num2str(i) ' Y' num2str(j)];
            figure('Name', nombre,'NumberTitle','off');
            plotMeshColo3D(nodesNew,elements(elementsFisu.all.index,:,:))
            hold on
            Draw_Barra(elementsBarra.ALL(EBindex.X{i},:),nodesNew,'k')
            hold off
        end
        intNodesAll = [intNodesAll; intRelations];
    end
end

for i = 1:nY
    for j = 1:nZ
        nodesInt.dobles{2,i,j} = nodesInt.dobles{2,i,j}(~ismember(nodesInt.dobles{2,i,j},nodesInt.triplesAll));
        [elements,nodesNew,nodosFluidos,elementsBarra,EBindex,intRelations] = gapInterseccionesEBYZ(nodesInt.dobles{2,i,j},nodesNew,gap,...
            elementsFisu.plus{2,i},elementsFisu.plus{3,j},elements,nodosFluidos,elementsBarra,EBindex,i,j);
        CRFluidos = [ CRFluidos
            [intRelations zeros(size(intRelations,1),1)] ];
        intRelatedNodes{2,i,j} = intRelations;
        
        if debugPlots == 1
            nombre = ['Separacion interseccion Y' num2str(i) ' Z' num2str(j)];
            figure('Name', nombre,'NumberTitle','off');
            plotMeshColo3D(nodesNew,elements(elementsFisu.all.index,:,:))
            hold on
            Draw_Barra(elementsBarra.ALL,nodesNew,'k')
            hold off
        end
        intNodesAll = [intNodesAll; intRelations];
    end
end

for i = 1:nX
    for j = 1:nZ
        nodesInt.dobles{3,i,j} = nodesInt.dobles{3,i,j}(~ismember(nodesInt.dobles{3,i,j},nodesInt.triplesAll));
        [elements,nodesNew,nodosFluidos,elementsBarra,EBindex,intRelations] = gapInterseccionesEBXZ(nodesInt.dobles{3,i,j},nodesNew,gap,...
            elementsFisu.plus{1,i},elementsFisu.plus{3,j},elements,nodosFluidos,elementsBarra,EBindex,i,j);
        CRFluidos = [ CRFluidos
            [intRelations zeros(size(intRelations,1),1)] ];
        intRelatedNodes{3,i,j} = intRelations;
        
        if debugPlots == 1
            nombre = ['Separacion interseccion X' num2str(i) ' Z' num2str(j)];
            figure('Name', nombre,'NumberTitle','off');
            plotMeshColo3D(nodesNew,elements(elementsFisu.all.index,:,:))
            hold on
            Draw_Barra(elementsBarra.ALL,nodesNew,'k')
            hold off
        end
        intNodesAll = [intNodesAll; intRelations];
    end
end
for i = 1:nX
    for j = 1:nY
        for k = 1:nZ
            [nodesNew, elements, elementsBarra, nodosFluidos,EBindex] = gapInterseccionesEBXYZ(nodesInt, nodesNew, elements, elementsTripleInt{i,j,k},elementsFisu, elementsBarra,gap,EBindex,i,j,k, nodosFluidos, debugPlots);
        end
    end
end
if debugPlots==1
    figure('Name', 'Elementos Fluidos', 'NumberTitle', 'off');hold on;
    scatter3(nodosFluidos.coords(:,1),nodosFluidos.coords(:,2),nodosFluidos.coords(:,3),'k.')
    Draw_Barra(elementsBarra.ALL(nodosFluidos.EB_Asociados,:),nodesNew,'r')
end
nodes=nodesNew;
%% NODOS BOUNDARY %%
%%% Primero se generan todos aquellos que no esten en la interseccion por
%%% otro lado, los nodosBoundary, es decir aquellos nodos que se encuentran
%%% en el borde de las fisuras y todavia estan unidos a los elementos del
%%% medio son los nodosFisu iniciales, ya que son nos nodos generados los
%%% que cambiaron de posicion y conectividad.
Boundary=[];
for i = 1:nX
    nodesFisu.sinIntCoords{1,i}  = nodesNew(nodesFisu.sinInt{1,i},:);
    
    startingPoint           = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(2) fractura.posicionZ{1,i}(1)];
    endingPoint             = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(2) fractura.posicionZ{1,i}(2)];
    indexVector             = pointsIn3DLine(nodesFisu.sinIntCoords{1,i},startingPoint,endingPoint);
    nodosBoundary.sinInt{1,i}= nodesFisu.sinInt{1,i}(indexVector);
    startingPoint           = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(1) fractura.posicionZ{1,i}(2)];
    endingPoint             = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(2) fractura.posicionZ{1,i}(2)];
    indexVector             = pointsIn3DLine(nodesFisu.sinIntCoords{1,i},startingPoint,endingPoint);
    nodosBoundary.sinInt{1,i}= [nodosBoundary.sinInt{1,i}
        nodesFisu.sinInt{1,i}(indexVector)];
    startingPoint           = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(1) fractura.posicionZ{1,i}(1)];
    endingPoint             = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(2) fractura.posicionZ{1,i}(1)];
    indexVector             = pointsIn3DLine(nodesFisu.sinIntCoords{1,i},startingPoint,endingPoint);
    nodosBoundary.sinInt{1,i}= [nodosBoundary.sinInt{1,i}
        nodesFisu.sinInt{1,i}(indexVector)];
    startingPoint           = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(1) fractura.posicionZ{1,i}(2)];
    endingPoint             = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(1) fractura.posicionZ{1,i}(1)];
    indexVector             = pointsIn3DLine(nodesFisu.sinIntCoords{1,i},startingPoint,endingPoint);
    nodosBoundary.sinInt{1,i}= [nodosBoundary.sinInt{1,i}
        nodesFisu.sinInt{1,i}(indexVector)];
    
    nodosBoundary.sinInt{1,i}  = unique(nodosBoundary.sinInt{1,i});
    
    startingPoint           = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(2) fractura.posicionZ{1,i}(1)];
    endingPoint             = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(2) fractura.posicionZ{1,i}(2)];
    indexVector             = pointsIn3DLine(nodesFisu.coords{1,i},startingPoint,endingPoint);
    nodosBoundary.all{1,i}  = nodesFisu.index{1,i}(indexVector);
    startingPoint           = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(1) fractura.posicionZ{1,i}(2)];
    endingPoint             = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(2) fractura.posicionZ{1,i}(2)];
    indexVector             = pointsIn3DLine(nodesFisu.coords{1,i},startingPoint,endingPoint);
    nodosBoundary.all{1,i}  = [nodosBoundary.all{1,i}
        nodesFisu.index{1,i}(indexVector)];
    startingPoint           = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(1) fractura.posicionZ{1,i}(1)];
    endingPoint             = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(2) fractura.posicionZ{1,i}(1)];
    indexVector             = pointsIn3DLine(nodesFisu.coords{1,i},startingPoint,endingPoint);
    nodosBoundary.all{1,i}  = [nodosBoundary.all{1,i}
        nodesFisu.index{1,i}(indexVector)];
    startingPoint           = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(1) fractura.posicionZ{1,i}(2)];
    endingPoint             = [fractura.posicionX{1,i}    fractura.posicionY{1,i}(1) fractura.posicionZ{1,i}(1)];
    indexVector             = pointsIn3DLine(nodesFisu.coords{1,i},startingPoint,endingPoint);
    nodosBoundary.all{1,i}  = [nodosBoundary.all{1,i}
        nodesFisu.index{1,i}(indexVector)];
    
    nodosBoundary.all{1,i}  = unique(nodosBoundary.all{1,i});
    Boundary = [Boundary;nodosBoundary.all{1,i}];
    if debugPlots == 1
        figure
        scatter3(nodesFisu.coords{1,i}(:,1),nodesFisu.coords{1,i}(:,2),nodesFisu.coords{1,i}(:,3))
        hold on
        scatter3(nodesNew(nodosBoundary.sinInt{1,i} ,1),nodesNew(nodosBoundary.sinInt{1,i},2),nodesNew(nodosBoundary.sinInt{1,i},3),'r')
    end
    
end
for i = 1:nY
    nodesFisu.sinIntCoords{2,i}  = nodesNew(nodesFisu.sinInt{2,i},:);
    
    startingPoint           = [fractura.posicionX{2,i}(2) fractura.posicionY{2,i} fractura.posicionZ{2,i}(1)];
    endingPoint             = [fractura.posicionX{2,i}(2) fractura.posicionY{2,i} fractura.posicionZ{2,i}(2)];
    indexVector             = pointsIn3DLine(nodesFisu.sinIntCoords{2,i},startingPoint,endingPoint);
    nodosBoundary.sinInt{2,i}= nodesFisu.sinInt{2,i}(indexVector);
    startingPoint           = [fractura.posicionX{2,i}(1) fractura.posicionY{2,i} fractura.posicionZ{2,i}(2)];
    endingPoint             = [fractura.posicionX{2,i}(2) fractura.posicionY{2,i} fractura.posicionZ{2,i}(2)];
    indexVector             = pointsIn3DLine(nodesFisu.sinIntCoords{2,i},startingPoint,endingPoint);
    nodosBoundary.sinInt{2,i}= [nodosBoundary.sinInt{2,i}
        nodesFisu.sinInt{2,i}(indexVector)];
    startingPoint           = [fractura.posicionX{2,i}(1) fractura.posicionY{2,i} fractura.posicionZ{2,i}(1)];
    endingPoint             = [fractura.posicionX{2,i}(2) fractura.posicionY{2,i} fractura.posicionZ{2,i}(1)];
    indexVector             = pointsIn3DLine(nodesFisu.sinIntCoords{2,i},startingPoint,endingPoint);
    nodosBoundary.sinInt{2,i}  = [nodosBoundary.sinInt{2,i}
        nodesFisu.sinInt{2,i}(indexVector)];
    nodosBoundary.sinInt{2,i}  = unique(nodosBoundary.sinInt{2,i});
    
    startingPoint           = [fractura.posicionX{2,i}(2) fractura.posicionY{2,i} fractura.posicionZ{2,i}(1)];
    endingPoint             = [fractura.posicionX{2,i}(2) fractura.posicionY{2,i} fractura.posicionZ{2,i}(2)];
    indexVector             = pointsIn3DLine(nodesFisu.coords{2,i},startingPoint,endingPoint);
    nodosBoundary.all{2,i}  = nodesFisu.index{2,i}(indexVector);
    startingPoint           = [fractura.posicionX{2,i}(1) fractura.posicionY{2,i} fractura.posicionZ{2,i}(2)];
    endingPoint             = [fractura.posicionX{2,i}(2) fractura.posicionY{2,i} fractura.posicionZ{2,i}(2)];
    indexVector             = pointsIn3DLine(nodesFisu.coords{2,i},startingPoint,endingPoint);
    nodosBoundary.all{2,i}  = [nodosBoundary.all{2,i}
        nodesFisu.index{2,i}(indexVector)];
    startingPoint           = [fractura.posicionX{2,i}(1) fractura.posicionY{2,i} fractura.posicionZ{2,i}(1)];
    endingPoint             = [fractura.posicionX{2,i}(2) fractura.posicionY{2,i} fractura.posicionZ{2,i}(1)];
    indexVector             = pointsIn3DLine(nodesFisu.coords{2,i},startingPoint,endingPoint);
    nodosBoundary.all{2,i}     = [nodosBoundary.all{2,i}
        nodesFisu.index{2,i}(indexVector)];
    nodosBoundary.all{2,i}     = unique(nodosBoundary.all{2,i});
    Boundary = [Boundary;nodosBoundary.all{2,i}];
    if debugPlots == 1
        figure
        scatter3(nodesFisu.coords{2,i}(:,1),nodesFisu.coords{2,i}(:,2),nodesFisu.coords{2,i}(:,3))
        hold on
        scatter3(nodesNew(nodosBoundary.sinInt{2,i},1),nodesNew(nodosBoundary.sinInt{2,i},2),nodesNew(nodosBoundary.sinInt{2,i},3),'r')
    end
    
end
for i = 1:nZ
    nodesFisu.sinIntCoords{3,i}= nodesNew(nodesFisu.sinInt{3,i},:);
    
    startingPoint             = [fractura.posicionX{3,i}(2) fractura.posicionY{3,i}(1) fractura.posicionZ{3,i}];
    endingPoint               = [fractura.posicionX{3,i}(2) fractura.posicionY{3,i}(2) fractura.posicionZ{3,i}];
    indexVector               = pointsIn3DLine(nodesFisu.sinIntCoords{3,i},startingPoint,endingPoint);
    nodosBoundary.sinInt{3,i} = nodesFisu.sinInt{3,i}(indexVector);
    startingPoint             = [fractura.posicionX{3,i}(1) fractura.posicionY{3,i}(1) fractura.posicionZ{3,i}];
    endingPoint               = [fractura.posicionX{3,i}(2) fractura.posicionY{3,i}(1) fractura.posicionZ{3,i}];
    indexVector               = pointsIn3DLine(nodesFisu.sinIntCoords{3,i},startingPoint,endingPoint);
    nodosBoundary.sinInt{3,i} = [nodosBoundary.sinInt{3,i}
        nodesFisu.sinInt{3,i}(indexVector)];
    startingPoint             = [fractura.posicionX{3,i}(1) fractura.posicionY{3,i}(2) fractura.posicionZ{3,i}];
    endingPoint               = [fractura.posicionX{3,i}(2) fractura.posicionY{3,i}(2) fractura.posicionZ{3,i}];
    indexVector               = pointsIn3DLine(nodesFisu.sinIntCoords{3,i},startingPoint,endingPoint);
    nodosBoundary.sinInt{3,i} = [nodosBoundary.sinInt{3,i}
        nodesFisu.sinInt{3,i}(indexVector)];
    nodosBoundary.sinInt{3,i} = unique(nodosBoundary.sinInt{3,i});
    
    startingPoint             = [fractura.posicionX{3,i}(2) fractura.posicionY{3,i}(1) fractura.posicionZ{3,i}];
    endingPoint               = [fractura.posicionX{3,i}(2) fractura.posicionY{3,i}(2) fractura.posicionZ{3,i}];
    indexVector               = pointsIn3DLine(nodesFisu.coords{3,i},startingPoint,endingPoint);
    nodosBoundary.all{3,i}    = nodesFisu.index{3,i}(indexVector);
    startingPoint             = [fractura.posicionX{3,i}(1) fractura.posicionY{3,i}(1) fractura.posicionZ{3,i}];
    endingPoint               = [fractura.posicionX{3,i}(2) fractura.posicionY{3,i}(1) fractura.posicionZ{3,i}];
    indexVector               = pointsIn3DLine(nodesFisu.coords{3,i},startingPoint,endingPoint);
    nodosBoundary.all{3,i}    = [nodosBoundary.all{3,i}
        nodesFisu.index{3,i}(indexVector)];
    startingPoint             = [fractura.posicionX{3,i}(1) fractura.posicionY{3,i}(2) fractura.posicionZ{3,i}];
    endingPoint               = [fractura.posicionX{3,i}(2) fractura.posicionY{3,i}(2) fractura.posicionZ{3,i}];
    indexVector               = pointsIn3DLine(nodesFisu.coords{3,i},startingPoint,endingPoint);
    nodosBoundary.all{3,i}    = [nodosBoundary.all{3,i}
        nodesFisu.index{3,i}(indexVector)];
    nodosBoundary.all{3,i}    = unique(nodosBoundary.all{3,i});
    Boundary = [Boundary;nodosBoundary.all{3,i}];
    if debugPlots == 1
        figure
        scatter3(nodesFisu.coords{3,i}(:,1),nodesFisu.coords{3,i}(:,2),nodesFisu.coords{3,i}(:,3))
        hold on
        scatter3(nodesNew(nodosBoundary.sinInt{3,i},1),nodesNew(nodosBoundary.sinInt{3,i},2),nodesNew(nodosBoundary.sinInt{3,i},3),'r')
    end
    
end

%% BUSCO EL NODO DE INTERSECCION %%%
%%% Las siguientes lineas basicamente se fijan que nodo esta en
%%% nodosBoundary.all pero no esta en el sinInt.
% nodoInterseccion{I,J,K}:- Para fracturas XY: I = 1
%                                              J = orden de X
%                                              K = orden de Y
%                         - Para fracturas YZ: I = 2
%                                              J = orden de Y
%                                              K = orden de Z
%                         - Para fracturas XZ: I = 3
%                                              J = orden de X
%                                              K = orden de Z
for i = 1:nX
    for j=1:nY
        nodoInterseccion{1,i,j} = nodosBoundary.all{2,j}(ismember(nodosBoundary.all{2,j},nodosBoundary.all{1,i}(~(ismember(nodosBoundary.all{1,i},nodosBoundary.sinInt{1,i})))));
    end
end
for i = 1:nY
    for j=1:nZ
        nodoInterseccion{2,i,j} = nodosBoundary.all{3,j}(ismember(nodosBoundary.all{3,j},nodosBoundary.all{2,i}(~(ismember(nodosBoundary.all{2,i},nodosBoundary.sinInt{2,i})))));
    end
end
for i = 1:nX
    for j=1:nZ
        nodoInterseccion{3,i,j} = nodosBoundary.all{3,j}(ismember(nodosBoundary.all{3,j},nodosBoundary.all{1,i}(~(ismember(nodosBoundary.all{1,i},nodosBoundary.sinInt{1,i})))));
    end
end
%% SE AGREGAN LOS NUEVOS NODOS EN LOS BORDES (LOS TERCEROS EN DISCORDIA) %%
for i = 1:nX
    nodesNew_LastPosition   = size(nodesNew,1);
    nodesNew                = nodesGenerator(nodosBoundary.sinInt{1,i},nodesNew,nodesNew,gap/2,1);
    nodosBordesNewIndex{1,i}= (nodesNew_LastPosition+1:1:size(nodesNew,1))';
end

for i = 1:nY
    nodesNew_LastPosition   = size(nodesNew,1);
    nodesNew                = nodesGenerator(nodosBoundary.sinInt{2,i},nodesNew,nodesNew,gap/2,2);
    nodosBordesNewIndex{2,i}= (nodesNew_LastPosition+1:1:size(nodesNew,1))';
end

for i = 1:nZ
    nodesNew_LastPosition     = size(nodesNew,1);
    nodesNew                  = nodesGenerator(nodosBoundary.sinInt{3,i},nodesNew,nodesNew,gap/2,3);
    nodosBordesNewIndex{3,i}  = (nodesNew_LastPosition+1:1:size(nodesNew,1))';
end
%% GENERACION DE CONSTRAINTS RELATIONS %%
% Indica que elementsBarra le corresponde a cada nodoBoundaryfor t = 1"
for i = 1:nX
    [~,relatedEB{1,i}]  = ismember(nodosBoundary.sinInt{1,i},elementsBarra.X{i});
end

for i = 1:nY
    [~,relatedEB{2,i}]  = ismember(nodosBoundary.sinInt{2,i},elementsBarra.Y{i});
end

for i = 1:nZ
    [~,relatedEB{3,i}]  = ismember(nodosBoundary.sinInt{3,i},elementsBarra.Z{i});
end


constraintsRelations    = zeros(size(nodosBoundary.sinInt{1,1},1),6);
counter                 = 1;

%%% FRACTURAS X %%%
for i = 1:nX
    for iNod = 1:size(nodosBoundary.sinInt{1,i},1)
        relationNodes                   = elementsBarra.X{i}(relatedEB{1,i}(iNod),:);
        constraintsRelations(counter,:) = [nodosBordesNewIndex{1,i}(iNod) relationNodes 0 0 1];
        counter                         = counter + 1;
    end
end
%%% FRACTURAS Y %%%
for i = 1:nY
    for iNod = 1:size(nodosBoundary.sinInt{2,i},1)
        relationNodes                   = elementsBarra.Y{i}(relatedEB{2,i}(iNod),:);
        constraintsRelations(counter,:) = [nodosBordesNewIndex{2,i}(iNod) relationNodes 0 0 2];
        counter                         = counter + 1;
    end
end
%%% FRACTURAS Z %%%
for i = 1:nZ
    if ~isempty(nodosBordesNewIndex{3,i})
        for iNod = 1:size(nodosBoundary.sinInt{3,i},1)
            relationNodes                   = elementsBarra.Z{i}(relatedEB{3,i}(iNod),:);
            constraintsRelations(counter,:) = [ nodosBordesNewIndex{3,i}(iNod) relationNodes 0 0 3];
            counter                         = counter + 1;
        end
    end
end
%% SEPARACION DE LAS CONECTIVIDADES EN LOS BORDES %%
%%% FISURAS X %%%
for i = 1:nX
    elementsMedium = (1:1:size(elements,1))';
    elementsMedium = setdiff(elementsMedium, elementsFisu.index{1,i});
    nelElementsMedium = size(elementsMedium,1);
    
    for iEle = 1:nelElementsMedium
        element = elementsMedium(iEle);
        nodesInElement = elements(element,:);
        [indexA] = ismember(nodesInElement,nodosBoundary.sinInt{1,i});
        
        [~, indexB] = ismember(nodesInElement(indexA),nodosBoundary.sinInt{1,i});
        
        nodesInElement(indexA) = nodosBordesNewIndex{1,i}(indexB);
        
        elements(element,:) = nodesInElement;
    end
end

%%% FISURAS Y %%%
for i = 1:nY
    elementsMedium = (1:1:size(elements,1))';
    elementsMedium = setdiff(elementsMedium, elementsFisu.index{2,i});
    nelElementsMedium = size(elementsMedium,1);
    
    for iEle = 1:nelElementsMedium
        element = elementsMedium(iEle);
        nodesInElement = elements(element,:);
        [indexA] = ismember(nodesInElement,nodosBoundary.sinInt{2,i});
        
        [~, indexB] = ismember(nodesInElement(indexA),nodosBoundary.sinInt{2,i});
        
        nodesInElement(indexA) = nodosBordesNewIndex{2,i}(indexB);
        
        elements(element,:) = nodesInElement;
    end
end

%%% FISURAS Z %%%
for i = 1:nZ
    elementsMedium = (1:1:size(elements,1))';
    elementsMedium = setdiff(elementsMedium, elementsFisu.index{3,i});
    nelElementsMedium = size(elementsMedium,1);
    
    for iEle = 1:nelElementsMedium
        element = elementsMedium(iEle);
        nodesInElement = elements(element,:);
        [indexA] = ismember(nodesInElement,nodosBoundary.sinInt{3,i});
        
        [~, indexB] = ismember(nodesInElement(indexA),nodosBoundary.sinInt{3,i});
        
        nodesInElement(indexA) = nodosBordesNewIndex{3,i}(indexB);
        
        elements(element,:) = nodesInElement;
    end
end
% Verifico que la matriz de conectividades tenga nodos existentes
nodesID = (1:size(nodesNew,1))';
vecInMatrix(nodesID, elements);
elements = conectivityCheck(elements, nodesNew);
if debugPlots == 1
    figure
    plotMeshColo3D(nodesNew,elements)
end

%% ULTIMOS CONSTRAINT RELATION ASOCIADOS A LA INTERSECCIONES Y SU SEPARACION %%
%% INT XY %%
for j = 1:nX  % Lo analizo por tipo de interseccion, para cada interseccion
    for k = 1:nY  % de cada tipo y para cada nodo de cada interseccion de cada tipo
        for t = 1:length(nodoInterseccion{1,j,k})
            nodesNew_LastPosition   = size(nodesNew,1);
            auxVec                  = [nodesNew(nodoInterseccion{1,j,k}(t),1)+gap/2 nodesNew(nodoInterseccion{1,j,k}(t),2)+gap/2 nodesNew(nodoInterseccion{1,j,k}(t),3)];
            nodesNew                = [nodesNew
                auxVec];
            nodosBordesNewIndexINT{1,j,k}(t) = (nodesNew_LastPosition+1:1:size(nodesNew,1))';
            if isempty(nodosBordesNewIndexINT{1,j,k}(t)) %% NO HAY INTERSECCIONES
                %%% AGREGO LAS CONSTRAINTS RELATIONS A LAS DE FLUIDOS %%%
                [aux1,aux2] = ismember(CRFluidos(:,[1 2]),constraintsRelations(:,[2 3]),'rows');
                %%% HAY QUE AGREGAR AQUELLOS CONTRAINTS DONDE 3 NODOS TIENEN LA MISMA P %%%
                CRFluidos(aux1,:) = constraintsRelations(nonzeros(aux2),1:end-1);
            else
                
                %%% CONSTRAINTS RELATIONS %%%
                relationNodes            = intRelatedNodes{1,j,k}(ismember(intRelatedNodes{1,j,k}(:,1),nodoInterseccion{1,j,k}(t)),:);
                constraintsRelations(counter,:) = [nodosBordesNewIndexINT{1,j,k}(t) relationNodes 0];
                counter = counter + 1;
                
                %%% AGREGO LAS CONSTRAINTS RELATIONS A LAS DE FLUIDOS %%%
                [aux1,aux2] = ismember(CRFluidos(:,[1 2]),constraintsRelations(:,[2 3]),'rows');
                %%% HAY QUE AGREGAR AQUELLOS CONTRAINTS DONDE 3 NODOS TIENEN LA MISMA P %%%
                CRFluidos(aux1,:) = constraintsRelations(nonzeros(aux2),1:end-1);
                
            end
            % Hago un arreglo geometrico ahora para que no traiga problemas despues
            elementsFondo =  find(sum(elements==nodoInterseccion{1,j,k}(t),2)==1);
            % Son los que estan pasando la fractura y que quedan conectados al nodo
            % original. Saco el primero del vector porque ese es parte de la fractura
            elementsFondo = selectFondoEle(nodesNew, elements, elementsFondo,3);
            for l = 1:length(elementsFondo)
                pos = find(elements(elementsFondo(l),:)==nodoInterseccion{1,j,k}(t));
                elements(elementsFondo(l),pos) = nodosBordesNewIndexINT{1,j,k}(t);
            end
        end
    end
end
if debugPlots == 1
    plotMeshColo3D(nodesNew,elements,'w')
end


%% INT YZ %%

for j = 1:nY
    for k = 1:nZ
        for t = 1:length(nodoInterseccion{2,j,k})
            nodesNew_LastPosition   = size(nodesNew,1);
            auxVec                  = [nodesNew(nodoInterseccion{2,j,k}(t),1) nodesNew(nodoInterseccion{2,j,k}(t),2)+gap/2 nodesNew(nodoInterseccion{2,j,k}(t),3)+gap/2 ];
            nodesNew                = [nodesNew
                auxVec];
            nodosBordesNewIndexINT{2,j,k}(t) = (nodesNew_LastPosition+1:1:size(nodesNew,1))';
            if isempty(nodosBordesNewIndexINT{2,j,k}(t)) %% NO HAY INTERSECCIONES
                %%% AGREGO LAS CONSTRAINTS RELATIONS A LAS DE FLUIDOS %%%
                [aux1,aux2] = ismember(CRFluidos(:,[1 2]),constraintsRelations(:,[2 3]),'rows');
                %%% HAY QUE AGREGAR AQUELLOS CONTRAINTS DONDE 3 NODOS TIENEN LA MISMA P %%%
                CRFluidos(aux1,:) = constraintsRelations(nonzeros(aux2),1:end-1);
            else
                
                %%% CONSTRAINTS RELATIONS %%%
                relationNodes            = intRelatedNodes{2,j,k}(ismember(intRelatedNodes{2,j,k}(:,1),nodoInterseccion{2,j,k}(t)),:);
                constraintsRelations(counter,:) = [nodosBordesNewIndexINT{2,j,k}(t) relationNodes 0];
                counter = counter + 1;
                
                %%% AGREGO LAS CONSTRAINTS RELATIONS A LAS DE FLUIDOS %%%
                [aux1,aux2] = ismember(CRFluidos(:,[1 2]),constraintsRelations(:,[2 3]),'rows');
                %%% HAY QUE AGREGAR AQUELLOS CONTRAINTS DONDE 3 NODOS TIENEN LA MISMA P %%%
                CRFluidos(aux1,:) = constraintsRelations(nonzeros(aux2),1:end-1);
                
            end
            % Hago un arreglo geometrico ahora para que no traiga problemas despues
            elementsFondo =  find(sum(elements==nodoInterseccion{2,j,k}(t),2)==1);
            % Son los que estan pasando la fractura y que quedan conectados al nodo
            % original. Saco el primero del vector porque ese es parte de la fractura
            elementsFondo = selectFondoEle(nodesNew, elements, elementsFondo,1);
            for l = 1:length(elementsFondo)
                pos = find(elements(elementsFondo(l),:)==nodoInterseccion{2,j,k}(t));
                elements(elementsFondo(l),pos) = nodosBordesNewIndexINT{2,j,k}(t);
            end
        end
    end
end
if debugPlots == 1
    plotMeshColo3D(nodesNew,elements,'w')
end
%% INT XZ %%
for j = 1:nX
    for k = 1:nZ
        for t = 1:length(nodoInterseccion{3,j,k})
            nodesNew_LastPosition   = size(nodesNew,1);
            auxVec                  = [nodesNew(nodoInterseccion{3,j,k}(t),1)+gap/2 nodesNew(nodoInterseccion{3,j,k}(t),2) nodesNew(nodoInterseccion{3,j,k}(t),3)+gap/2 ];
            nodesNew                = [nodesNew
                auxVec];
            nodosBordesNewIndexINT{3,j,k}(t) = (nodesNew_LastPosition+1:1:size(nodesNew,1))';
            if isempty(nodosBordesNewIndexINT{3,j,k}(t)) %% NO HAY INTERSECCIONES
                %%% AGREGO LAS CONSTRAINTS RELATIONS A LAS DE FLUIDOS %%%
                [aux1,aux2] = ismember(CRFluidos(:,[1 2]),constraintsRelations(:,[2 3]),'rows');
                %%% HAY QUE AGREGAR AQUELLOS CONTRAINTS DONDE 3 NODOS TIENEN LA MISMA P %%%
                CRFluidos(aux1,:) = constraintsRelations(nonzeros(aux2),1:end-1);
            else
                
                %%% CONSTRAINTS RELATIONS %%%
                relationNodes            = intRelatedNodes{3,j,k}(ismember(intRelatedNodes{3,j,k}(:,1),nodoInterseccion{3,j,k}(t)),:);
                constraintsRelations(counter,:) = [nodosBordesNewIndexINT{3,j,k}(t) relationNodes 0];
                counter = counter + 1;
                
                %%% AGREGO LAS CONSTRAINTS RELATIONS A LAS DE FLUIDOS %%%
                [aux1,aux2] = ismember(CRFluidos(:,[1 2]),constraintsRelations(:,[2 3]),'rows');
                %%% HAY QUE AGREGAR AQUELLOS CONTRAINTS DONDE 3 NODOS TIENEN LA MISMA P %%%
                CRFluidos(aux1,:) = constraintsRelations(nonzeros(aux2),1:end-1);
                
            end
            % Hago un arreglo geometrico ahora para que no traiga problemas despues
            elementsFondo =  find(sum(elements==nodoInterseccion{3,j,k}(t),2)==1);
            % Son los que estan pasando la fractura y que quedan conectados al nodo
            % original. Saco el primero del vector porque ese es parte de la fractura
            elementsFondo = selectFondoEle(nodesNew, elements, elementsFondo,2);
            for l = 1:length(elementsFondo)
                pos = find(elements(elementsFondo(l),:)==nodoInterseccion{3,j,k}(t));
                elements(elementsFondo(l),pos) = nodosBordesNewIndexINT{3,j,k}(t);
            end
        end
    end
end
if debugPlots == 1
    plotMeshColo3D(nodesNew,elements,'w')
end
if debugPlots == 1
    
    figure
    hold on
    plotMeshColo3D(nodesNew,elements(elementsMedium,:),'k',0.05)
    plotMeshColo3D(nodesNew,elements(elementsMediumPlus,:),'r',1)
    figure
    plotMeshColo3D(nodesNew,elements(elementsMediumPlus,:))
    
    figure
    plotMeshColo3D(nodesNew,elements(elementsMediumPlus,:),'r',1)
    plotMeshColo3D(nodesNew,elements(elementsFisu.plus{2,1},:),'y',1)
    hold on
    Draw_Barra(elementsBarra.ALL,nodesNew,'k')
    figure
    plotMeshColo3D(nodesNew,elements(elementsMediumPlus,:),'r',1)
    plotMeshColo3D(nodesNew,elements(elementsFisu.plus{2,1},:),'y',1)
end

nodes = nodesNew;


%% MALLA FLUIDOS Y ELEMENTS COHESIVOS%%
%%% Utilizo las caras de los elementsFisu MINUS para generar los grupos de 4
%%% nodos, que luego seran ordenados.

counter = 1;
elementsFisu.all.minus      = [];
elementsFisu.all.minusNodes = false(1,8);
for i = 1:nX
    elementsFisu.all.minus      = [elementsFisu.all.minus; elementsFisu.minus{1,i}];
    [~,indexAuxX]               = ismember(elementsFisu.minus{1,i},elementsFisu.index{1,i});
    elementsFisu.all.minusNodes = [elementsFisu.all.minusNodes; elementsFisu.nodes{1,i}(indexAuxX,:)];
    elementsFisu.minusNodes{1,i}= elementsFisu.nodes{1,i}(indexAuxX,:);
end
for i = 1:nY
    elementsFisu.all.minus      = [elementsFisu.all.minus; elementsFisu.minus{2,i}];
    [~,indexAuxY]               = ismember(elementsFisu.minus{2,i},elementsFisu.index{2,i});
    elementsFisu.all.minusNodes = [elementsFisu.all.minusNodes; elementsFisu.nodes{2,i}(indexAuxY,:)];
    elementsFisu.minusNodes{2,i}= elementsFisu.nodes{2,i}(indexAuxY,:);
end
for i = 1:nZ
    elementsFisu.all.minus      = [elementsFisu.all.minus; elementsFisu.minus{3,i}];
    [~,indexAuxZ]               = ismember(elementsFisu.minus{3,i},elementsFisu.index{3,i});
    elementsFisu.all.minusNodes = [elementsFisu.all.minusNodes; elementsFisu.nodes{3,i}(indexAuxZ,:)];
    elementsFisu.minusNodes{3,i}= elementsFisu.nodes{3,i}(indexAuxZ,:);
end

nelEleFisu                  = size(elementsFisu.all.minus,1);
fourNodesEles               = zeros(nelEleFisu,4);
elementsFluidos.elements    = zeros(nelEleFisu,4);
elementsFluidos.int         = [];
cohesivos.elements          = zeros(nelEleFisu,4);
cohesivos.related8Nodes     = zeros(nelEleFisu,8);
% cohesivos.type              = zeros(nelEleFisu,1); %% Este indica si es fractura, Z, Y, O X
cohesivos.name              = strings(nelEleFisu,1);
cohesivos.boundary          = [];
counter                     = 0;
infoPlot.nodesCohesivos     = nodes;
nodesCohesivos              = [];

elementsFisu.all.minusNodes(1,:)=[];
%%% RELATED NODES TO THE INTERFACE ELEMENTS (8 FOR Q4) %%%

%%% X %%%
for i = 1:nX
    for iEle = 1:size(elementsFisu.minus{1,i})
        nodesInEle    = elements(elementsFisu.minus{1,i}(iEle),:);
        nodesInFisu   = nodesInEle(elementsFisu.minusNodes{1,i}(iEle,:));
%         nodesInFisu   = nodesInEle(ismember(nodesInEle, nodesFisu.index{1,i}));
        [~,relatedEB] = ismember(nodesInFisu,elementsBarra.ALL(EBindex.X{i}));
        auxEB         = elementsBarra.ALL(EBindex.X{i},:);
        
        relatedEBNodes = auxEB(relatedEB,:);
        relatedEB      = EBindex.X{i}(relatedEB);
        
        nodesEle = nodesNew(nodesInFisu,:);
        
        nodesEleNew = nodesEle - repmat(nodesEle(1,:),4,1);
       
        versori  =  nodes(relatedEBNodes(1,2),:)' - nodes(relatedEBNodes(1,1),:)';
        versori  =  versori / norm(versori);
        auxVec   = nodesEle(2,:)' -  nodesEle(1,:)';

        versorj  = cross(auxVec,versori);
        versorj  = versorj / norm(versorj);

        versork  = cross(versori,versorj);
        versork  = versork / norm(versork);

        %%% VOY A HACER QUE EL x LOCAL SEA LA NORMAL AL PLANO (versork) %%%
        %     T           = [versori/norm(versori) versorj/norm(versorj) versork/norm(versork)];
        T           = [versori versorj versork];

        nodesEleRot = (T' * (nodesEleNew'))';
        if DFN_flag==1
        nodesEleNew = DFN_matrix'*nodesEle'; 
        nodesEleRot = nodesEleNew';
        
        end
        %%% Obtengo el centroide
        centroid    = [sum(nodesEleRot(:,2))/4 sum(nodesEleRot(:,3))/4];
        rays        = nodesEleRot(:,[2 3]) -  repmat(centroid,4,1);
        angles      = atan2(rays(:,2),rays(:,1));
        angles      = angles + (angles<0)*2*pi;
        %%% Con los angulos obtengo asi finalmente el orden correcto
        [~, correctOrder] = sort(angles);
        counter = counter+1;
        %%% VUELVO A CALCULAR OTRA VEZ LA MATRIZ DE ROTACION PARA ASEGURARME
        %%% QUE NINGUN EJE ESTE ALINEADO CON UNA DIAGONAL
        
        nodesEleReOrder = nodesEle(correctOrder,:);
        
        auxVec   = nodesEleReOrder(1,:)' -  nodesEleReOrder(4,:)';
        
        versorj  = cross(auxVec,versori);
        versorj  = versorj / norm(versorj);
        
        versork  = cross(versori,versorj);
        versork  = versork / norm(versork);
        
        T           = [versori versorj versork];
        
        if DFN_flag==1
        T           = DFN_matrix;
        else
        nodesEleRot = (T' * (nodesEleNew'))';
            
        end
        
        elementsFluidos.elements(counter,:)    = nodesInFisu(correctOrder);
        elementsFluidos.relatedEB(counter,:)   = relatedEB(correctOrder);
        elementsFluidos.nodesEle(:,:,counter)  = [nodesEleRot(correctOrder,2) nodesEleRot(correctOrder,3)];
        elementsFluidos.T(:,:,counter)         = T;
        if sum(ismember(nodesInFisu,intNodesAll))~=0
            elementsFluidos.int                = [elementsFluidos.int; counter];
        end
        cohesivos.elements(counter,:)          = nodesInFisu(correctOrder);
        cohesivos.relatedEB(counter,:)         = relatedEB(correctOrder);
        cohesivos.type(counter)                = 'X';
        cohesivos.name(counter,:)              = ['X',num2str(i)];
        cohesivos.nodesEle(:,:,counter)        = [nodesEleRot(correctOrder,2) nodesEleRot(correctOrder,3)];
        
        cohesivos.T(:,:,counter)               = T;
        
        relatedEB                       = relatedEB(correctOrder);
        relatedEBNodes                  = relatedEBNodes(correctOrder,:);
        
        cohesivos.related8Nodes(counter,:) = [relatedEBNodes(:,1)' relatedEBNodes(:,2)'];
        %Cohesivos Boundary
        if sum(ismember(nodesInFisu, nodosBoundary.all{1,i}))>0
            cohesivos.boundary=[cohesivos.boundary; counter];
        end
    end
end
%%% Y %%%
for i = 1:nY
    for iEle = 1:size(elementsFisu.minus{2,i})
        nodesInEle    = elements(elementsFisu.minus{2,i}(iEle),:);
        nodesInFisu = nodesInEle(elementsFisu.minusNodes{2,i}(iEle,:));
%         nodesInFisu   = nodesInEle(ismember(nodesInEle, nodesFisu.index{2,i}));

        [~,relatedEB] = ismember(nodesInFisu,elementsBarra.ALL(EBindex.Y{i}));
        relatedEB     = relatedEB(find(relatedEB));
        auxEB         = elementsBarra.ALL(EBindex.Y{i},:);
        
        relatedEBNodes = auxEB(relatedEB,:);
        relatedEB      = EBindex.Y{i}(relatedEB);
        
        nodesEle = nodesNew(nodesInFisu,:);
        
        nodesEleNew = nodesEle - repmat(nodesEle(1,:),4,1);
        
        versori  =  nodes(relatedEBNodes(1,2),:)' - nodes(relatedEBNodes(1,1),:)';
        versori  =  versori / norm(versori);
        
        auxVec   = nodesEle(2,:)' -  nodesEle(1,:)';
        
        versorj  = cross(auxVec,versori);
        versorj  = versorj / norm(versorj);
        
        versork  = cross(versori,versorj);
        versork  = versork / norm(versork);
        
        %%% VOY A HACER QUE EL x LOCAL SEA LA NORMAL AL PLANO (versork) %%%
        %     T           = [versori/norm(versori) versorj/norm(versorj) versork/norm(versork)];
        T           = [versori versorj versork];
        
        nodesEleRot = (T' * (nodesEleNew'))';
        %%% Obtengo el centroide
        centroid    = [sum(nodesEleRot(:,2))/4 sum(nodesEleRot(:,3))/4];
        rays        = nodesEleRot(:,[2 3]) -  repmat(centroid,4,1);
        angles      = atan2(rays(:,2),rays(:,1));
        angles      = angles + (angles<0)*2*pi;
        %%% Con los angulos obtengo asi finalmente el orden correcto
        [~, correctOrder] = sort(angles);
        counter = counter+1;
        %%% VUELVO A CALCULAR OTRA VEZ LA MATRIZ DE ROTACION PARA ASEGURARME
        %%% QUE NINGUN EJE ESTE ALINEADO CON UNA DIAGONAL
        
        nodesEleReOrder = nodesEle(correctOrder,:);
        
        auxVec   = nodesEleReOrder(1,:)' -  nodesEleReOrder(4,:)';
        
        versorj  = cross(auxVec,versori);
        versorj  = versorj / norm(versorj);
        
        versork  = cross(versori,versorj);
        versork  = versork / norm(versork);
        
        T           = [versori versorj versork];
        
        nodesEleRot = (T' * (nodesEleNew'))';
        
        
        elementsFluidos.elements(counter,:)    = nodesInFisu(correctOrder);
        elementsFluidos.relatedEB(counter,:)   = relatedEB(correctOrder);
        elementsFluidos.nodesEle(:,:,counter)  = [nodesEleRot(correctOrder,2) nodesEleRot(correctOrder,3)];
        elementsFluidos.T(:,:,counter)         = T;
        if sum(ismember(nodesInFisu,intNodesAll))~=0
            elementsFluidos.int                = [elementsFluidos.int; counter];
        end
        
        cohesivos.elements(counter,:)      = nodesInFisu(correctOrder);
        cohesivos.relatedEB(counter,:)     = relatedEB(correctOrder);
        cohesivos.type(counter)            = 'Y';
        cohesivos.name(counter,:)          = ['Y',num2str(i)];
        cohesivos.nodesEle(:,:,counter)    = [nodesEleRot(correctOrder,2) nodesEleRot(correctOrder,3)];
        cohesivos.T(:,:,counter)           = T;

        relatedEB                       = relatedEB(correctOrder);
        relatedEBNodes                  = relatedEBNodes(correctOrder,:);
        
        cohesivos.related8Nodes(counter,:) = [relatedEBNodes(:,1)' relatedEBNodes(:,2)'];
        %Cohesivos Boundary
        if sum(ismember(nodesInFisu, nodosBoundary.all{1,i}))>0
            cohesivos.boundary=[cohesivos.boundary; counter];
        end
    end
end
%%% Z %%%
for i = 1:nZ
    for iEle = 1:size(elementsFisu.minus{3,i})
        nodesInEle    = elements(elementsFisu.minus{3,i}(iEle),:);
        nodesInFisu = nodesInEle(elementsFisu.minusNodes{3,i}(iEle,:));
%         nodesInFisu   = nodesInEle(ismember(nodesInEle, nodesFisu.index{3,i}));
        [~,relatedEB] = ismember(nodesInEle,elementsBarra.ALL(EBindex.Z{i}));
        relatedEB     = relatedEB(find(relatedEB));
        auxEB         = elementsBarra.ALL(EBindex.Z{i},:);
        
        relatedEBNodes = auxEB(relatedEB,:);
        relatedEB      = EBindex.Z{i}(relatedEB);
        
        nodesEle = nodesNew(nodesInFisu,:);
        
        nodesEleNew = nodesEle - repmat(nodesEle(1,:),4,1);
        
        versori  =  nodes(relatedEBNodes(1,2),:)' - nodes(relatedEBNodes(1,1),:)';
        versori  =  versori / norm(versori);
        
        auxVec   = nodesEle(2,:)' -  nodesEle(1,:)';
        
        versorj  = cross(auxVec,versori);
        versorj  = versorj / norm(versorj);
        
        versork  = cross(versori,versorj);
        versork  = versork / norm(versork);
        
        %%% VOY A HACER QUE EL x LOCAL SEA LA NORMAL AL PLANO (versork) %%%
        %     T           = [versori/norm(versori) versorj/norm(versorj) versork/norm(versork)];
        T           = [versori versorj versork];
        
        nodesEleRot = (T' * (nodesEleNew'))';
        %%% Obtengo el centroide
        centroid    = [sum(nodesEleRot(:,2))/4 sum(nodesEleRot(:,3))/4];
        rays        = nodesEleRot(:,[2 3]) -  repmat(centroid,4,1);
        angles      = atan2(rays(:,2),rays(:,1));
        angles      = angles + (angles<0)*2*pi;
        %%% Con los angulos obtengo asi finalmente el orden correcto
        [~, correctOrder] = sort(angles);
        counter = counter+1;
        %%% VUELVO A CALCULAR OTRA VEZ LA MATRIZ DE ROTACION PARA ASEGURARME
        %%% QUE NINGUN EJE ESTE ALINEADO CON UNA DIAGONAL
        
        nodesEleReOrder = nodesEle(correctOrder,:);
        
        auxVec   = nodesEleReOrder(1,:)' -  nodesEleReOrder(4,:)';
        
        versorj  = cross(auxVec,versori);
        versorj  = versorj / norm(versorj);
        
        versork  = cross(versori,versorj);
        versork  = versork / norm(versork);
        
        T           = [versori versorj versork];
        
        nodesEleRot = (T' * (nodesEleNew'))';
        
        elementsFluidos.elements(counter,:)    = nodesInFisu(correctOrder);
        elementsFluidos.relatedEB(counter,:)   = relatedEB(correctOrder);
        elementsFluidos.nodesEle(:,:,counter)  = [nodesEleRot(correctOrder,2) nodesEleRot(correctOrder,3)];
        elementsFluidos.T(:,:,counter)         = T;
        if sum(ismember(nodesInFisu,intNodesAll))~=0
            elementsFluidos.int                = [elementsFluidos.int; counter];
        end
        
        cohesivos.elements(counter,:)      = nodesInFisu(correctOrder);
        cohesivos.relatedEB(counter,:)     = relatedEB(correctOrder);
        cohesivos.type(counter)            = 'Z';
        cohesivos.name(counter,:)          = ['Z',num2str(i)];
        cohesivos.nodesEle(:,:,counter)    = [nodesEleRot(correctOrder,2) nodesEleRot(correctOrder,3)];
        cohesivos.T(:,:,counter)           =T;

        relatedEB                       = relatedEB(correctOrder);
        relatedEBNodes                  = relatedEBNodes(correctOrder,:);
        
        cohesivos.related8Nodes(counter,:) = [relatedEBNodes(:,1)' relatedEBNodes(:,2)'];
        %Cohesivos Boundary
        if sum(ismember(nodesInFisu, nodosBoundary.all{1,i}))>0
            cohesivos.boundary=[cohesivos.boundary; counter];
        end
    end
end

%% Ordenamiento geometrico
%Hay que mover todas las fracturas en -gap/2 en la direccion de la normal
%de cada fractura pero primero hay que separar los extremos de las
%intersecciones. Hay que generar nodos nuevos en las intersecciones de los
%nodos boundary con los nodesFisu perpendiculares, separar los elementos
%que contienen esas intersecciones de los de la fractura.
%% Fracturas X
for i = 1:nX
    nodesMove{1,i} = find(nodesNew(:,1)== fractura.posicionX{1,i}+gap);
    nodesMove{1,i} = [nodesMove{1,i};find(nodesNew(:,1)== fractura.posicionX{1,i}+gap/2)];
    nodesMove{1,i} = [nodesMove{1,i};find(nodesNew(:,1)== fractura.posicionX{1,i})];
    
    %Filtros
    filtroY = nodesMove{1,i}(fractura.posicionY{1,i}(1)<=nodesNew(nodesMove{1,i},2));
    filtroY = filtroY(find(nodesNew(filtroY,2)<=fractura.posicionY{1,i}(2)));
    filtroZ = filtroY(find(fractura.posicionZ{1,i}(1)<=nodesNew(filtroY,3)));
    nodesMove{1,i} = filtroZ(find(nodesNew(filtroZ,3)<=fractura.posicionZ{1,i}(2)));
   
    nodesNew(nodesMove{1,i},1)=nodesNew(nodesMove{1,i},1)-gap/2;
end
%% Fracturas Y
for i = 1:nY
    nodesMove{2,i} = find(nodesNew(:,2)== fractura.posicionY{2,i}+gap);
    nodesMove{2,i} = [nodesMove{2,i};find(nodesNew(:,2)== fractura.posicionY{2,i}+gap/2)];
    nodesMove{2,i} = [nodesMove{2,i};find(nodesNew(:,2)== fractura.posicionY{2,i})];
    
    %Filtros
    filtroX = nodesMove{2,i}(find(fractura.posicionX{2,i}(1)<=nodesNew(nodesMove{2,i},1)));
    filtroX = filtroX(find(nodesNew(filtroX,1)<=fractura.posicionX{2,i}(2)));
    filtroZ = filtroX(find(fractura.posicionZ{2,i}(1)<=nodesNew(filtroX,3)));
    filtroZ = filtroZ(find(nodesNew(filtroZ,3)<=fractura.posicionZ{2,i}(2)));
    nodesMove{2,i} = filtroZ;
    nodesNew(nodesMove{2,i},2)=nodesNew(nodesMove{2,i},2)-gap/2;
end
%% Fracturas Z
for i = 1:nZ
    nodesMove{3,i} = find(nodesNew(:,3)== fractura.posicionZ{3,i}+gap);
    nodesMove{3,i} = [nodesMove{3,i};find(nodesNew(:,3)== fractura.posicionZ{3,i}+gap/2)];
    nodesMove{3,i} = [nodesMove{3,i};find(nodesNew(:,3)== fractura.posicionZ{3,i})];
    
    %Filtros
    filtroX = nodesMove{3,i}(find(fractura.posicionX{3,i}(1)<=nodesNew(nodesMove{3,i},1)));
    filtroX = filtroX(find(nodesNew(filtroX,1)<=fractura.posicionX{3,i}(2)));
    filtroY = filtroX(find(fractura.posicionY{3,i}(1)<=nodesNew(filtroX,2)));
    filtroY = filtroY(find(nodesNew(filtroY,2)<=fractura.posicionY{3,i}(2)));
    nodesMove{3,i}=filtroY;
    nodesNew(nodesMove{3,i},3)=nodesNew(nodesMove{3,i},3)-gap/2;
end
% Verifico que la matriz de conectividades tenga nodos existentes
nodesID = (1:size(nodesNew,1))';
vecInMatrix(nodesID, elements);
elements = conectivityCheck(elements, nodesNew);
nodes = nodesNew;
%% INCLINACION DE PLANOS %%
% Funcion de rotacion nueva
infoPlot.nodesSinRotar = nodes;
if DFN_flag==1
    nodes = RotPlanos3Frac(nodes, fractura, DFN_ang);
    infoPlot.nodesCohesivos = RotPlanos3Frac(infoPlot.nodesCohesivos, fractura, DFN_ang);
    
    if debugPlots == 1
        figure
        scatter3(nodes(:,1),nodes(:,2),nodes(:,3),'.b')

        figure
        plotMeshColo3D(nodes,elements,'w')
        hold off
    end
    
    %corrijo las facturas, ahora van a ser oblicuas
    nodesFisu.coords{1,1} = nodes(nodesFisu.index{1,1},:);
    nodesFisu.coords{2,1} = nodes(nodesFisu.index{2,1},:);
    if debugPlots == 1
        figure
        scatter3(nodes(:,1),nodes(:,2),nodes(:,3),'k.')
    end
    anchoX = max(nodes(:,1));
    anchoY = max(nodes(:,2));
    anchoZ = max(nodes(:,3));
    
    
end
handle = figure('Name', 'Plot Cohesivos','NumberTitle','off', 'Position',[175, 75, 1000, 500]);
subplot(1,2,1);
PlotMesh(nodes,elementsFluidos.elements);hold on
scatter3(nodes(nodesInt.all,1),nodes(nodesInt.all,2),nodes(nodesInt.all,3),'bo')
subplot(2,2,2); PlotMesh(nodes, elementsFluidos.elements);view(0,90);
subplot(2,2,4); PlotMesh(nodes, elementsFluidos.elements);view(90,0);
[elementsFisu, elementsBarra, nodosBoundary,nodesInt] = datos_celda2estruct(elementsFisu,elementsBarra,nodosBoundary,nX,nY,nZ, Boundary,nodesInt);
% Armo una estructura que voy a necesitar para el plot de intersecciones
infoPlot.nodes           = nodes;
infoPlot.elements        = elements;
infoPlot.elementsFluidos = elementsFluidos;
infoPlot.elementsFisu    = elementsFisu;
if nX~=0 && nY~=0 && nZ~=0 && debugPlots == 1
    plotInterseccion(elementsTripleInt{1,1,1},infoPlot);
end
%% OUTPUTS
plotMeshSlider(nodes, elements)
if saveData
    save(nameData,'nodes','elements','cohesivos','elementsFisu','elementsBarra','nodosFluidos','elementsFluidos','anchoX','anchoY','anchoZ','CRFluidos','elementsMediumPlus','constraintsRelations','nodosBoundary','nodesInt');
    movefile([nameData,'.mat'],direccionGuardado)
end
    
