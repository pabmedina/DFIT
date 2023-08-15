
timePlot=16;
timeIter=10;
caso=3 %1 Primer Cordon,2 Segundo Cordon, 3 Ambos

if iTime ==timePlot
    gaps(:,iterP)= dNITER;
    presion(:,iterP)=full(p);
end


if iTime == timePlot  && iterP > timeIter
    
    
    ElemOrdenado=reshape(meshInfo.cohesivos.elements,[],1);
    
    %noddITER %me dice la posicion en la matriz de cohesivos.elements
    
    NodosGaps=ElemOrdenado(noddITER);
    
    tolGaps=0.05;
    
    Filas=find(any(gaps'>tolGaps));
    
    %% Si quiero agregar nodos de interes
    NodoBomba=39;
    
    %% Quiero agregar los elementos que estan pegados al nodo bomba
    aux=max(meshInfo.cohesivos.elements'==NodoBomba)'; %seria nodo Bomba pero hay varios
    IdNod=repmat(aux,1,4);
    
   
    nodInteres=meshInfo.cohesivos.elements(IdNod); %Ejemplo pero tiene que ser cohesivo, si no se quiere buscar poner 0
    
    %% Si quiero el segundo cordon del NodoBomba
    IdNod2=IdNod;
    for j=1:length(nodInteres)
        aux2=max(meshInfo.cohesivos.elements'==nodInteres(j))';
        IdIter=repmat(aux2,1,4);
        
    
        IdNod2=IdNod2+IdIter;
    end
    IdNod2=logical(IdNod2);
    nodInteres2=meshInfo.cohesivos.elements(IdNod2);
    
    %% Filtramos Para tener los nodos que queremos
    
    if caso==3
        nodInteres=nodInteres2;
    elseif caso==2
        nodInteres=setdiff(nodInteres2,nodInteres);
    end
    %% Si buscamos ver algun nodo en particular
    
    position = [];
    
    if ~isempty(position)
        
        [ nodesFound ] = getNodesInPos( 0.01,meshInfo,position);
        
        nodInteres=[nodInteres, nodesFound];
        
    end
    %% Selecciono filas
    
    
    
    for i=1:length(nodInteres)
        IndexPos=find(nodInteres(i)==NodosGaps); %Posicion en la matriz de elementos del nodo
        Filas=[Filas IndexPos];%A que noddIter corresponde esa posicion
    end
    
    
    Filas=unique(Filas);
    
    
    
    for i=Filas
        figure
        hold on
        subplot(2,2,1)
        plot(1:iterP,gaps(i,:),'g*',1:iterP,gaps(i,:),'b--')
        try ylim([0 max(gaps(i,:))]) %Esto puede tirar error si el nodo en cuestion tiene un gap maximo negativo
        catch
            ylim([min(gaps(i,:)) max(gaps(i,:))])
        end
        title('Gaps vs iteraciones')
        
        subplot(2,2,3)
        plot(1:iterP,presion(NodosGaps(i),:),'g*',1:iterP,presion(NodosGaps(i),:),'b--')
        try ylim([0 max(presion(NodosGaps(i),:))])
        catch
            ylim([min(presion(NodosGaps(i),:)) max(presion(NodosGaps(i),:))])
        end
        title('Presion vs iteraciones')
        
        subplot(2,2,[2, 4])
        
        plotMeshColo3D(meshInfo.nodes,meshInfo.elements,meshInfo.cohesivos.elements,'off','on','r','y','k',1)
        scatter3(meshInfo.nodes(NodoBomba,1),meshInfo.nodes(NodoBomba,2),meshInfo.nodes(NodoBomba,3),'MarkerEdgeColor','k','MarkerFaceColor',[1 0 0])
        scatter3(meshInfo.nodes(NodosGaps(i),1),meshInfo.nodes(NodosGaps(i),2),meshInfo.nodes(NodosGaps(i),3),'MarkerEdgeColor','k','MarkerFaceColor',[0 .75 .75])
 
        title('Nodo Ploteado')
        
        
    end
end