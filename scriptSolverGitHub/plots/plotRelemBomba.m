

%% PlotPerfilDeFractura

presion = dITER(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P)*temporalProperties.preCond;

if physicalProperties.poroelasticas.pPoral<0.1
    presionNormalizada=presion;
else
    presionNormalizada=presion/physicalProperties.poroelasticas.pPoral;
end
figure; hold on;
plotColo(meshInfo.nodes,meshInfo.elementsFluidos.elements,full(presionNormalizada));
c = colorbar;
c.Label.String = ['Presion normalizada (p_{reservorio}=' num2str(physicalProperties.poroelasticas.pPoral,'%.2f') ' MPa)'];
axis square
daspect([1 1 1])
view(-20,10);
% title({['Presion normalizada - iTime: ',num2str(iTime)]})

axis square

view([0 -1 0]);
daspect([1 1 1])
hold on

set(gcf, 'Position', get(0, 'Screensize')); drawnow();






%% KEY
key='Normales'; % Normles o Todos
% key='Todos'

%% plot si queremos elementos cercanos al nodo bomba

% nElem=size(meshInfo.elements,1);
% nodosCohesivos=unique(meshInfo.cohesivos.elements);
% nNodosCohesivos=size(nodosCohesivos,1);
% 
% elementosBomba=[];
% 
% for i=1:size(bombaProperties.nodoBomba,1)
%     elementosBomba=[elementosBomba find(bombaProperties.nodoBomba(i)==meshInfo.elements)'];
% end
% 
% elementosBomba=mod(elementosBomba,size(meshInfo.elements,1))+nElem.*(mod(elementosBomba,nElem)==0);
% 
% elementosPlot=unique(elementosBomba');

%% Si queremos plotear minus plus o los elementos que tienen al nodo bomba (Si queremos eso comentar las dos lineas de abajo)
% elementosPlot=meshInfo.elementsFisu.Y.minus;
elementosPlot=meshInfo.elementsFisu.Y.plus;
%%
nodosdeElementosBomba=unique(reshape(meshInfo.elements(elementosPlot,:),[],1));


ax2=meshInfo.elements(elementosPlot,:);
auxiliar = ax2(:,[1 2 6 5 2 3 7 6 3 4 8 7 4 1 5 8 1 2 3 4 5 6 7 8]);
auxiliar1  = reshape(auxiliar',4,[])' ;


%% Plot Elementos

    hold on
    patch('Faces',auxiliar1,'Vertices',meshInfo.nodes,'FaceAlpha',1,'EdgeColor','green','FaceColor','none')
    axis square
    view(-45,20)
    daspect([1 1 1])
    xlabel('X [mm]')
    ylabel('Y [mm]')
    zlabel('Z [mm]')

%% Magnification

magnorm=1e-3;
magnification=1;%1e-5;

%% Plot Flechas


for i=1:length(nodosdeElementosBomba)
    

    x0=meshInfo.nodes(nodosdeElementosBomba(i),1);
    y0=meshInfo.nodes(nodosdeElementosBomba(i),2);
    z0=meshInfo.nodes(nodosdeElementosBomba(i),3);

if strcmp(key,'Normales')
    d=R_u((nodosdeElementosBomba(i)-1)*3+2)*magnorm; %el *2 es porque es la direccion normal que queremos
    quiver3(x0,y0,z0,0,d,0,'r','LineWidth',2,'MaxHeadSize',10);
    title({['Presion-iTime: ',num2str(iTime)],'magnificacion x' ,num2str(magnorm),'Normales'})
elseif strcmp(key,'Todos')
    d1=R((nodosdeElementosBomba(i)-1)*3+1)*magnification;
    d2=R((nodosdeElementosBomba(i)-1)*3+2)*magnification; 
    d3=R((nodosdeElementosBomba(i)-1)*3+3)*magnification;
    quiver3(x0,y0,z0,d1,d2,d3,'r','LineWidth',2,'MaxHeadSize',10);
    title({['Presion-iTime: ',num2str(iTime)],'magnificacion x' ,num2str(magnification),'Todos'})

end
    

end