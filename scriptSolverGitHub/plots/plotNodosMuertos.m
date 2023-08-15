function plotNodosMuertos(meshInfo,key,cara1)

%% Ejemplo plotCara(meshInfo,nodosCara.este)

if strcmp(key,'on')
    figure
    hold on
    plotMeshColo3D(meshInfo.nodes,meshInfo.elements,meshInfo.cohesivos.elements,'off','on','w','r','k',0.2) % Se plotea la malla
    scatter3(meshInfo.nodes(cara1,1),meshInfo.nodes(cara1,2),meshInfo.nodes(cara1,3),'MarkerEdgeColor','k','MarkerFaceColor',[0 .75 .75])
    hold off
end

end

