function plotCT(meshInfo,key,nodosOverConstrained)

if strcmp(key,'on')
figure
hold on
plotMeshColo3D(meshInfo.nodes,meshInfo.elements,meshInfo.cohesivos.elements,'off','on','w','r','k',0.2) % Se plotea la malla
scatter3(meshInfo.nodes(nodosOverConstrained,1),meshInfo.nodes(nodosOverConstrained,2),meshInfo.nodes(nodosOverConstrained,3),'MarkerEdgeColor','k','MarkerFaceColor',[0 .75 .75])
hold off
end

end


