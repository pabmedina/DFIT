%% PlotColo
meshInfo.cohesivos = cohesivos;
meshInfo.nodes = nodes;
    close all
    hold on
    patch('Faces',meshInfo.cohesivos.elements,'Vertices',meshInfo.nodes,'FaceColor','r','FaceAlpha',1)
    axis square
    view(-45,20)
    daspect([1 1 1])
    xlabel('X [mm]')
    ylabel('Y [mm]')
    zlabel('Z [mm]')
    
    

%% tiempo especifico

iTime=5;

%% plot
nCohesivos=size(meshInfo.cohesivos.elements,1);
nodosCohesivos=unique(reshape(meshInfo.cohesivos.elements,[],1));
nNodosCohesivos=size(nodosCohesivos,1);

%% Magnification

magnification=1e18;

%% Plot

for i=1:nNodosCohesivos
    gap=0;
    %% Agarro el nodo y me fijo que elementos lo tienen y la posicion dentro del Q4
    
    EleQueTieneNodCrudo=find(nodosCohesivos(i)==meshInfo.cohesivos.elements);
    EleQueTieneNod=mod(EleQueTieneNodCrudo,nCohesivos)+600.*(mod(EleQueTieneNodCrudo,nCohesivos)==0);
    Posicion=fix(EleQueTieneNodCrudo/nCohesivos)+1.*(mod(EleQueTieneNodCrudo,nCohesivos)~=0);
    
    x0=meshInfo.nodes(nodosCohesivos(i),1);
    y0=meshInfo.nodes(nodosCohesivos(i),2);
    z0=meshInfo.nodes(nodosCohesivos(i),3);
    
    %% Promedio la apertura segun cuantos elementos tenga nuestro nodo
    
    for j=1:size(EleQueTieneNodCrudo,1)
        gap=gap+meshInfo.cohesivos.dS1Calculado(EleQueTieneNod(j),Posicion(j));
    end 
    gap=gap./size(EleQueTieneNodCrudo,1);

    d=gap*magnification;
    
    plot3([x0 x0], [y0 y0+d],[z0 z0] ,'g','LineWidth', 0.5);
    plot3([x0 x0], [y0 y0-d],[z0 z0], 'g','LineWidth', 0.5);
    
    
end