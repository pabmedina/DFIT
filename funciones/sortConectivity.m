function sortedConectivity = sortConectivity(elementNodesArray, nodesPositionArray)
% Sorts elementNodesArray according to nodesPositionArray
% Only for H8 elements without distortion 
% elementNodesArray:  [nElements x 8] Matrix
% nodesPositionArray: [nNodes x 4] Matrix

sortedConectivity = zeros(size(elementNodesArray));
nodesPositionArray = round(nodesPositionArray,3);

mSort = logical([1 1 1
                 0 1 1
                 0 0 1
                 1 0 1
                 1 1 0
                 0 1 0
                 0 0 0
                 1 0 0]);

xCoord = nodesPositionArray(:,1); 
yCoord = nodesPositionArray(:,2); 
zCoord = nodesPositionArray(:,3);
    
maxX = max(xCoord); minX = min(xCoord);
maxY = max(yCoord); minY = min(yCoord);
maxZ = max(zCoord); minZ = min(zCoord);
    
sortedPositions = [mSort(:,1)*maxX + ~mSort(:,1)*minX, mSort(:,2)*maxY + ~mSort(:,2)*minY, mSort(:,3)*maxZ + ~mSort(:,3)*minZ];
[~, index] = ismember(sortedPositions, nodesPositionArray,'rows');

sortedConectivity(index) = elementNodesArray;

end