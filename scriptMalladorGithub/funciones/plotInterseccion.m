function plotInterseccion(eleID, infoPlot)
% Funcion de ploteo de malla basada en la del Colo pero con un slider por
% coordenada por si hace falta ver algo particular
nodesSinRotar   = infoPlot.nodesSinRotar;
elementsFluidos = infoPlot.elementsFluidos;
elementsFisu    = infoPlot.elementsFisu;
nodes           = infoPlot.nodes;
elements        = infoPlot.elements;
nodesCohesivos  = infoPlot.nodesCohesivos;

fig = figure('Name', 'Intersecciones','NumberTitle','off');hold on;
    set(fig, 'Position', [175, 75, 1000, 500])
    set(fig,'DeleteFcn',@deleteFile);
    auxiliar = elements(eleID,[1 2 6 5 2 3 7 6 3 4 8 7 4 1 5 8 1 2 3 4 5 6 7 8]);
    auxiliar1  = reshape(auxiliar',4,[])' ;

    if nargin<3
        color = 'w';
        opacity = 1;
    else if nargin<4
            opacity = 1;
        end
    end
    
    % Creamos los sliders para cada coordenada
    try
        load('filtered.mat');
    catch
        filtered{1}=1:length(elements(eleID));
        filtered{2}=1:length(elements(eleID));
        filtered{3}=1:length(elements(eleID));
    end
    
    meshPlot(filtered,nodes,nodesSinRotar, elements, elementsFluidos,elementsFisu,eleID,nodesCohesivos);
    
    slider_x = uicontrol('Style', 'slider', 'Position', [0 300 200 20], 'Min', min(nodes(elements(eleID,:),1)), 'Max', max(nodes(elements(eleID,:),1)), 'Value', min(nodes(elements(eleID,:),1)), 'Callback', {@slider_callback, 1,filtered});
    slider_y = uicontrol('Style', 'slider', 'Position', [0 200 200 20], 'Min', min(nodes(elements(eleID,:),2)), 'Max', max(nodes(elements(eleID,:),2)), 'Value', min(nodes(elements(eleID,:),2)), 'Callback', {@slider_callback, 2,filtered});
    slider_z = uicontrol('Style', 'slider', 'Position', [0 100 200 20], 'Min', min(nodes(elements(eleID,:),3)), 'Max', max(nodes(elements(eleID,:),3)), 'Value', max(nodes(elements(eleID,:),2)), 'Callback', {@slider_callback, 3,filtered});

    %% Edits
    edit_x = uicontrol('Style', 'edit', 'Position', [0 325 200 20], 'String', ['X=' num2str(get(slider_x, 'Value'))], 'Callback', {@edit_callback, 1});
    edit_y = uicontrol('Style', 'edit', 'Position', [0 225 200 20], 'String', ['Y=' num2str(get(slider_y, 'Value'))], 'Callback', {@edit_callback, 2});
    edit_z = uicontrol('Style', 'edit', 'Position', [0 125 200 20], 'String', ['Z=' num2str(get(slider_z, 'Value'))], 'Callback', {@edit_callback, 3});

    
    %% Función de callback que se ejecuta cada vez que se mueve un slider
    function filtered= slider_callback(src, event, coord,filtered)
        load('filtered.mat');
    % Obtenemos el valor actual de la coordenada correspondiente al slider
        pos = get(src, 'Value');
    % Filtramos los elementos que atraviesan el plano perpendicular a la coordenada correspondiente
        filtered{coord}=eleFilter([],[],coord, pos);
        meshPlot(filtered,nodes,nodesSinRotar, elements, elementsFluidos,elementsFisu,eleID,nodesCohesivos)
    end


    %% Función de callback que se ejecuta cada vez que se ingresa un valor en un cuadro de texto
    function filtered = edit_callback(src, event, slider,filtered)
        load('filtered.mat');
    % Obtenemos el valor ingresado en el cuadro de texto
    text = get(src, 'String');
    if length(text)<2
        val = str2double(text);
        if isnan(val)
            error
        end
    elseif char(text(2))== '=' 
        val = str2double(text(3:end));
    else
        val = str2double(text);
    end
    
    % Verificamos si el valor ingresado es un número válido
        if ~isnan(val)
            % Si es válido, actualizamos el valor del slider correspondiente
                switch slider
                    case 1
                        set(slider_x, 'Value', val,'Callback', {@slider_callback, 1});
                        filtered{1}=eleFilter([],[],1, val);
                        meshPlot(filtered)
                    case 2
                        set(slider_y, 'Value', val,'Callback', {@slider_callback, 2});
                        filtered{2}=eleFilter([],[],2, val);
                        meshPlot(filtered)                    
                    case 3
                        set(slider_z, 'Value', val,'Callback', {@slider_callback, 3});
                        filtered{3}=eleFilter([],[],3, val);
                        meshPlot(filtered)
                end

        end
    end

%% Funcion de filtrar elementos
    function filtered_elements=eleFilter(src,event,coord, pos)
        filtered_elements = [];
        if coord==3
            for t = 1:size(eleID,1)
                if(sum(nodes(elements(eleID(t),:),coord)<=pos)==8)
                     filtered_elements = [filtered_elements; t];
                end
            end
        else 
            for t = 1:size(eleID,1)
                if(sum(nodes(elements(eleID(t),:),coord)>=pos)==8)
                     filtered_elements = [filtered_elements; t];
                end
            end
        end
        set(edit_x,'String', ['X=' num2str(get(slider_x, 'Value'))]);
        set(edit_y,'String', ['Y=' num2str(get(slider_y, 'Value'))]);
        set(edit_z,'String', ['Z=' num2str(get(slider_z, 'Value'))]);
    end

%% Actualizar la figura
    function meshPlot(filtered,nodes,nodesSinRotar, elements, elementsFluidos,elementsFisu,eleID,nodesCohesivos)
        filter = unique(filtered{1}(find(ismember(filtered{1},filtered{2}(find(ismember(filtered{2},filtered{3})))))));
        cla
        plotIntersecciones(nodes,nodesSinRotar, elements, elementsFluidos,elementsFisu,eleID(filter),nodesCohesivos)
        function plotIntersecciones(nodes,nodesSinRotar, elements, elementsFluidos,elementsFisu,eleID,nodesCohesivos)       
        eleInt = elements(eleID,[1 2 6 5 2 3 7 6 3 4 8 7 4 1 5 8 1 2 3 4 5 6 7 8]);
        eleInter  = reshape(eleInt',4,[])' ;


        % figure
        patch('Vertices',nodes,'Faces',eleInter,'FaceColor','b','EdgeColor',[0.2,0.2,0.2],'EdgeAlpha',0.6, 'FaceAlpha',1)
        plotNodesTag(nodes, elements(eleID,:))
        colormap jet
        view(-45,20)
        %% Busco elementos vecinos
        elementsFiltro = [];
        cohesivosFiltro = [];
        for j = 1:size(eleID)
        nodesInElement = elements(eleID(j),:);
        face{1} = nodesInElement(find(nodesSinRotar(nodesInElement,1)==max(nodesSinRotar(nodesInElement,1))));
        face{2} = nodesInElement(find(nodesSinRotar(nodesInElement,1)==min(nodesSinRotar(nodesInElement,1))));
        face{3} = nodesInElement(find(nodesSinRotar(nodesInElement,2)==max(nodesSinRotar(nodesInElement,2))));
        face{4} = nodesInElement(find(nodesSinRotar(nodesInElement,2)==min(nodesSinRotar(nodesInElement,2))));
        face{5} = nodesInElement(find(nodesSinRotar(nodesInElement,3)==max(nodesSinRotar(nodesInElement,3))));
        face{6} = nodesInElement(find(nodesSinRotar(nodesInElement,3)==min(nodesSinRotar(nodesInElement,3))));

        for i = 1:length(face)
            filtro = find(sum(elements(elementsFisu.ALL.index,:)==face{i}(1),2)==1);
            filtro2 = filtro(find(sum(elements(elementsFisu.ALL.index(filtro),:)==face{i}(2),2)==1));
            filtro3 = filtro2(find(sum(elements(elementsFisu.ALL.index(filtro2),:)==face{i}(3),2)==1));
            filtro4 = filtro3(find(sum(elements(elementsFisu.ALL.index(filtro3),:)==face{i}(4),2)==1));
            filtro4 = setdiff(unique(elementsFisu.ALL.index(filtro4)),eleID(j));
            try
                elementsFiltro = [elementsFiltro; filtro4];
            end
        end
        for i = 1:length(face)
            filtro = find(sum(elementsFluidos.elements==face{i}(1),2)==1);
            filtro2 = filtro(find(sum(elementsFluidos.elements(filtro,:)==face{i}(2),2)==1));
            filtro3 = filtro2(find(sum(elementsFluidos.elements(filtro2,:)==face{i}(3),2)==1));
            filtro4 = filtro3(find(sum(elementsFluidos.elements(filtro3,:)==face{i}(4),2)==1));
            try
                cohesivosFiltro = [cohesivosFiltro; filtro4];
            end
        end
        end
        eleNeighbour = elements(elementsFiltro,[1 2 6 5 2 3 7 6 3 4 8 7 4 1 5 8 1 2 3 4 5 6 7 8]);
        eleNeigh  = reshape(eleNeighbour',4,[])' ;
        patch('Vertices',nodes,'Faces',eleNeigh,'FaceColor',[0.7 0.7 0.7],'EdgeColor','k','EdgeAlpha',0.3,'FaceAlpha',0.2)
        %Ploteo cohesivos entre elementsFisu
        PlotMesh(nodesCohesivos,elementsFluidos.elements(cohesivosFiltro,:));

        function plotNodesTag(nodes,selectedNodes)
        nodesID= [nodes,(1:size(nodes,1))'];

        hold on;
        for i = selectedNodes
            text(nodesID(i, 1), nodesID(i, 2), nodesID(i, 3), num2str(nodesID(i,4)), 'FontSize', 10);
        end
        end

        end

        save('filtered.mat','filtered');
    end



function deleteFile(~,~)
    try
        delete('filtered.mat');
    catch
    end
end
end