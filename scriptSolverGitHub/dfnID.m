function bool = dfnID(meshInfo,arrayVecY,arrayVecZ,arrayInt)

bool = false(size(meshInfo.cohesivos.elements,1),1);

for i = 1:size(meshInfo.cohesivos.elements,1)
    nodesEleID = meshInfo.cohesivos.elements(i,:);
    nodesEle_coord = meshInfo.nodes(nodesEleID,:);
    yCoord = nodesEle_coord(:,2); zCoord = nodesEle_coord(:,3);
    [in,~] = inpolygon(yCoord,zCoord,arrayVecY,arrayVecZ);
%     
%     figure
%     
%     plot(arrayVecY,arrayVecZ) % polygon
%     
%     hold on
%     plot(yCoord,zCoord,'r+') % points inside polygon
%     hold off
%     close

    if all(in) && i <= max(arrayInt) && i>=min(arrayInt)
        bool(i) = true;
    end
    
    
end

end

