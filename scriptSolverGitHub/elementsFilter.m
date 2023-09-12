function elementsIn = elementsFilter(cohesivos, nameFrac, nodes, yLim, zLim)
%{ 

nameFrac: strirng que identifica la fractura. Ej 'X1'

Función que filtra elementos de una fractura con normal Z. 

elementsIn es un vector lógico con 1 para aquellos elementos que caen 
completamente en el área encerrada por los límites yLim y zLim

%}

eleFrac = cohesivos.elements(cohesivos.name == nameFrac, :);
eleFracNodes = cohesivos.related8Nodes(cohesivos.name == nameFrac, :); 
elementsIn = false(size(cohesivos.elements,1), 1);
nElements = size(eleFracNodes,1);
% elementsIn = zeros(size(cohesivos.elements,1), 1);
filtered = zeros(nElements, 4);

for iElement = 1:nElements
    eleCoordY = nodes(eleFracNodes(iElement,:), 2);
    eleCoordZ = nodes(eleFracNodes(iElement,:), 3);
    
    if all(eleCoordY >= yLim(1)) && all(eleCoordY <= yLim(2)) && ...
            all(eleCoordZ >= zLim(1)) && all(eleCoordZ <= zLim(2)) && strcmpi(cohesivos.name(1),'X')
                
        filtered(iElement,:) = eleFrac(iElement,:);
    end
end

filtered(all(filtered == 0,2),:) = [];
[~, validRows] = ismember(filtered, eleFrac, 'rows');

elementsIn(validRows) = true;
end