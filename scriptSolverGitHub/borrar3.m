close all
figure
for iEle = 1:paramDiscEle.nel
     plotMeshColo3D(meshInfo.nodes,meshInfo.elements(iEle,:),meshInfo.cohesivos.elements,'on','off','k','none','k',0.2)
     title(num2str(iEle))
%      drawnow
     saveas(gcf,[num2str(iEle),'.png']);
end