function [nodesNew, elements, elementsBarra, nodosFluidos,EBindex] = gapInterseccionesEBXYZ(nodesInt, nodesNew, elements, elementsTripleInt,elementsFisu, elementsBarra,gap,EBindex,i,j,k, nodosFluidos, debugPlots)
%%Funcion que verifica que los elementos ingresados sean un prisma
if debugPlots ==1
figure; hold on;subplot(1,2,1);
plotMeshColo3D(nodesNew, elements(elementsTripleInt,:));
end
for a = 1:length(elementsTripleInt)
    %% Identifico el nodo que esta fuera de lugar nodeInicial
    nodesInElement = elements(elementsTripleInt(a),:);
    nodesX = nodesNew(nodesInElement,1);
    nodesY = nodesNew(nodesInElement,2);
    nodesZ = nodesNew(nodesInElement,3);
    valoresX = unique(nodesX);
    valoresY = unique(nodesY);
    valoresZ = unique(nodesZ);
    cant = [];
    % Si el elemento es prismatico deberian haber solo dos valores de x,
    % dos de Y y dos de Z, busco cuantos valores distintos de cada
    % coordenada hay en el elemento
    for b = 1:length(valoresX)
        cant = [cant;sum(nodesX==valoresX(b))];
        if cant(b) ==1
            Xinicial = valoresX(b);
        elseif cant(b)==3
            Xfinal = valoresX(b);
        end
    end 
    cant = [];
    for b = 1:length(valoresY)
        cant = [cant;sum(nodesY==valoresY(b))];
        if cant(b) ==1
            Yinicial = valoresY(b);
        elseif cant(b)==3
            Yfinal = valoresY(b);
        end
    end
    cant = [];
    for b = 1:length(valoresZ)
        cant = [cant;sum(nodesZ==valoresZ(b))];
        if cant(b) ==1
            Zinicial = valoresZ(b);
        elseif cant(b)==3
            Zfinal = valoresZ(b);
        end
    end
    try 
        nodeInicial(a) = nodesInElement(find(nodesX==Xinicial));
    catch
        try
            nodeInicial(a) = nodesInElement(find(nodesY==Yinicial));
        catch
            try
            nodeInicial(a) = nodesInElement(find(nodesZ==Zinicial));
            catch %Si llega hasta aca es porque el elemento ya es prismatico 
            nodeInicial(a) = nodeInicial(a-1);
            end
        end
    end
    %Ya encontre el nodo que esta mal, busco el nodo final y si no existe
    %lo creo
    coordsFinal(a,:) = nodesNew(nodeInicial(a),:);
    try
        coordsFinal(a,1)=Xfinal;
    end
    try 
        coordsFinal(a,2)=Yfinal;
    end
    try
        coordsFinal(a,3)=Zfinal;
    end
    
    try %Busco si hay un nodo en las coordenadas finales
        nodeFinal(a)=find(sum(nodesNew==coordsFinal(a,:),2)==3);
    catch %Si no lo hay, lo armo 
        lastNode = size(nodesNew,1);
        nodesNew(lastNode+1,:)=coordsFinal(a,:);
        nodeFinal(a)=lastNode+1;
    end
    elements(elementsTripleInt(a),find(nodesInElement==nodeInicial(a)))=nodeFinal(a);
    %Borro las variables que use para identificar el nodo inicial para que
    %no hagan problemas despues
    Xinicial=[];Xfinal=[];Yinicial=[];Yfinal=[];Zinicial=[];Zfinal=[];
end
%% Trabajo con los nodos finales para armar las conexiones
%Direccion X
for u = 1:3 %Selector de direccion
    nodesMinus = nodeFinal(find(nodesNew(nodeFinal,u)==min(nodesNew(nodeFinal,u))));
for t = 1:length(nodesMinus)
    X = nodesNew(nodesMinus(t),1);
    Y = nodesNew(nodesMinus(t),2);
    Z = nodesNew(nodesMinus(t),3);
    if u == 1
    nodePlus = nodeFinal(find(sum(nodesNew(nodeFinal,:)==[X+gap,Y,Z],2)==3));
    elseif u == 2
    nodePlus = nodeFinal(find(sum(nodesNew(nodeFinal,:)==[X,Y+gap,Z],2)==3));
    elseif u == 3
    nodePlus = nodeFinal(find(sum(nodesNew(nodeFinal,:)==[X,Y,Z+gap],2)==3));
    end
    %Armo la conexion
    elementsBarra.INT   = [elementsBarra.INT; nodesMinus(t),nodePlus];
    nodosFluidos.coords = [nodosFluidos.coords; X,Y,Z];
    nodosFluidos.index  = [nodosFluidos.index; nodesMinus(t)];
    
    nElementsBarra              = size(nodosFluidos.coords,1);
    nodosFluidos.EB_Asociados   = [nodosFluidos.EB_Asociados;(nElementsBarra+1:1:size(nodosFluidos.coords,1))'];
    lastEB                      = size(elementsBarra.ALL,1);
    newEB                       = [nodesMinus(t),nodePlus];
    if u == 1
        EBindex.X{i} = [EBindex.X{i}; lastEB+1];
    elseif u == 2
        EBindex.Y{j} = [EBindex.Y{j}; lastEB+1];
    elseif u == 3
        EBindex.Z{k} = [EBindex.Z{k}; lastEB+1];
    end
    elementsBarra.ALL = [elementsBarra.ALL; newEB];
end
if debugPlots==1
subplot(1,2,2);
plotMeshColo3D(nodesNew, elements(elementsTripleInt,:));
end
end 
end
