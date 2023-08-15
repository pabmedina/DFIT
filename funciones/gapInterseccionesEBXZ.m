function [elements,nodesNew,nodosFluidos,elementsBarra,EBindex,intRelations] = gapInterseccionesEBXZ(nodesINTindex,nodesNew,gap,elementsPlusX,elementsPlusZ,elements,nodosFluidos,elementsBarra,EBindex,i,j)

nodesNew_LastPosition = size(nodesNew,1);

nodesNew = nodesGenerator(nodesINTindex,nodesNew,nodesNew,gap,1);  

% ELEMENTS BARRA Y NODOS FLUIDOS X
nElementsBarra = size(nodosFluidos.coords,1);

elementsBarra.INT           = [elementsBarra.INT
                               nodesINTindex (nodesNew_LastPosition+1:size(nodesNew,1))'];
nodosFluidos.coords         = [nodosFluidos.coords
                               nodesNew(nodesINTindex,:)];
nodosFluidos.index          = [nodosFluidos.index
                               nodesINTindex];
nodosFluidos.EB_Asociados   = [nodosFluidos.EB_Asociados
                               (nElementsBarra+1:1:size(nodosFluidos.coords,1))'];
lastEB                      = size(elementsBarra.ALL,1);
newEBs                      = [nodesINTindex (nodesNew_LastPosition+1:size(nodesNew,1))'];
nNewEBs                     = size(newEBs,1);
EBindex.X{i}                = [EBindex.X{i} 
                               (lastEB+1:1:lastEB+nNewEBs)'];
                           
elementsBarra.ALL           = [elementsBarra.ALL
                               nodesINTindex (nodesNew_LastPosition+1:size(nodesNew,1))'];
                                                      
nelPlus = size(elementsPlusX,1);
for iEle = 1:nelPlus
    element = elementsPlusX(iEle);
    nodesInElement = elements(element,:);
    [indexA] = ismember(nodesInElement,nodesINTindex);
    [~, indexB] = ismember(nodesInElement(indexA),nodesINTindex);
    
    replacementNodes = indexB + ones(size(indexB))*nodesNew_LastPosition;

    nodesInElement(indexA) = replacementNodes;
    elements(element,:) = nodesInElement;
end

% Luego la separacion de la X
% Se agregan los nodos nuevos de interseccion


nodesINTindexZ              = [nodesINTindex
                               (nodesNew_LastPosition+1:size(nodesNew,1))'];
                    
nodesNew_LastPosition = size(nodesNew,1);

nodesNew = nodesGenerator(nodesINTindexZ,nodesNew,nodesNew,gap,3);

%%% ELEMEN BARRAS Y NODOS FLUIDOS


elementsBarra.INT           = [elementsBarra.INT
                               nodesINTindexZ (nodesNew_LastPosition+1:size(nodesNew,1))'];
 
%%% Aprovecho y genero las relaciones de la interseccion, es decir los grupos de 4 nodos.

aux                         = [nodesINTindexZ (nodesNew_LastPosition+1:size(nodesNew,1))'];
nINTS                       = size(nodesINTindex,1);
intRelations                = [aux(1:nINTS,:) aux(nINTS + 1:end,:)];
                           
lastEB                      = size(elementsBarra.ALL,1);
newEBs                      = [nodesINTindexZ (nodesNew_LastPosition+1:size(nodesNew,1))'];
nNewEBs                     = size(newEBs,1);
EBindex.Z{j}                   = [EBindex.Z{j}
                               (lastEB+1:1:lastEB+nNewEBs)'];                           
                          
elementsBarra.ALL           = [elementsBarra.ALL
                               nodesINTindexZ (nodesNew_LastPosition+1:size(nodesNew,1))'];                                                      
nodosFluidos.EB_Asociados   = [nodosFluidos.EB_Asociados
                              (nElementsBarra+1:1:size(nodosFluidos.coords,1))'
                              (nElementsBarra+1:1:size(nodosFluidos.coords,1))'
                              (nElementsBarra+1:1:size(nodosFluidos.coords,1))'];
                                               
% Ahi ya se generaron 3 elementBarras del encuentro de ambas fisuras, recordar
% que son 4, ahora se agrega el cuarto faltante.

lastEBSet                   = (nodesNew_LastPosition+1:size(nodesNew,1))';
lastEBSet                   = reshape(lastEBSet,[],2);  

lastEB                      = size(elementsBarra.ALL,1);
nNewEBs                     = size(lastEBSet,1);
EBindex.X{i}                = [EBindex.X{i} 
                               (lastEB+1:1:lastEB+nNewEBs)'];     

elementsBarra.ALL           = [elementsBarra.ALL
                               lastEBSet];

nelPlus = size(elementsPlusZ,1);

for iEle = 1:nelPlus
    element = elementsPlusZ(iEle);
    nodesInElement = elements(element,:);
    [indexA] = ismember(nodesInElement,nodesINTindexZ);
    [~, indexB] = ismember(nodesInElement(indexA),nodesINTindexZ);
    
    replacementNodes = indexB + ones(size(indexB))*nodesNew_LastPosition;
    
    nodesInElement(indexA) = replacementNodes;
    
    elements(element,:) = nodesInElement;
end


end