function elementNodesArray = conectivityCheck(elementNodesArray, nodesPositionArray)
% Checks the conectivity matrix elementNodesArray according
% to nodesPositionArray.
% Only for H8 elements without distortion 

% elementNodesArray:  [nElements x 8] Matrix
% nodesPositionArray: [nNodes x 4] Matrix
% boolMatrix:         logical matrix with 1 where the conectivity is OK
%                      and 0 where the conecitivity is wrong

nElements = size(elementNodesArray,1);
mSort = logical([1 1 1
                 0 1 1
                 0 0 1
                 1 0 1
                 1 1 0
                 0 1 0
                 0 0 0
                 1 0 0]);
             
wrngElements = zeros(nElements,1);
for iElement=1:nElements
    xCoord = nodesPositionArray(elementNodesArray(iElement,:),1);
    yCoord = nodesPositionArray(elementNodesArray(iElement,:),2);
    zCoord = nodesPositionArray(elementNodesArray(iElement,:),3);
    
    maxX = max(xCoord); 
    maxY = max(yCoord); 
    maxZ = max(zCoord); 
    
    mskMax = [xCoord == maxX, yCoord == maxY, zCoord == maxZ];
                 
    boolMatrix = mskMax == mSort;
    bool = all(all(boolMatrix));
    
    if ~bool && length(unique(xCoord))==2 && length(unique(yCoord))==2 && length(unique(zCoord))==2
        wrngElements(iElement) = iElement;
        elementNodesArray(iElement,:) = sortConectivity(elementNodesArray(iElement,:), nodesPositionArray(elementNodesArray(iElement,:),:));
    end
end

if ~isempty(nonzeros(wrngElements))
    qWrngEle = length(nonzeros(wrngElements));
    warning('Hay %d elementos con las conectividades mal ordenadas', qWrngEle)
    str = sprintf('-%d',qWrngEle);
    str = str(2:end);
    msg = ['Hay ', str,' elementos con las conectividades mal ordenadas -> arreglado'];
    msgFile(msg)
end
end