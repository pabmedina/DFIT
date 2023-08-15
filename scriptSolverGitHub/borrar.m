% 0   1.0667e+05   1.7733e+05
% 0   1.7333e+05   1.7733e+05
% 40000      1.4e+05   1.7733e+05
elementosSRV = [1:paramDiscEle.nel]';
mskElementosSRV = false(size(elementosSRV));
% for iElement = 1:paramDiscEle.nel
%     nodos = meshInfo.nodes(meshInfo.elements(iElement,:),:);
%     mskX = nodos(:,1) - 0 >= 0 & nodos(:,1) - 100000 <= 0;
%     mskY = nodos(:,2) - 1.0667e+05 >= 0 & nodos(:,2) - 1.7333e+05 <= 0;
%     mskZ = nodos(:,3) - 120000 >= 0 & nodos(:,3) - 206000 <= 0;
%     if  all(mskX & mskY & mskZ)    
%         mskElementosSRV(iElement) = true;
%     end
% end

for iElement = 1:paramDiscEle.nel
    nodos = meshInfo.nodes(meshInfo.elements(iElement,:),:);
    mskX = nodos(:,1) - 0 >= 0 & nodos(:,1) - 140000 <= 0;
    mskY = nodos(:,2) - 1.0667e+05 >= 0 & nodos(:,2) - 1.7333e+05 <= 0;
    mskZ = nodos(:,3) - 80000 >= 0 & nodos(:,3) - 246000 <= 0;
    if  all(mskX & mskY & mskZ)    
        mskElementosSRV(iElement) = true;
    end
end