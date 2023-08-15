function [ CTFrac ,nCREqFrac ] = getCTFracNormalPromedio(nodeDofs,constraintsRelations,precondCT,nDofTot_U,meshInfo)

nodes = meshInfo.nodes;
%% - Borde de fractura sin interseccion - 
nCREqFracSinInt    = sum(sum(constraintsRelations(:,1:5)>0,2)<4)*5;
nCRFracSinInt      = sum(sum(constraintsRelations(:,1:5)>0,2)<4);

if isempty(constraintsRelations)
    nDofTot_U = [];
    nCREqFracSinInt = [];
    nCRFracSinInt = [];
end

CTFracSinInt = zeros(nCREqFracSinInt,nDofTot_U);
constraintsRelationsSinInt = constraintsRelations(sum(constraintsRelations(:,1:5)>0,2)<4,:);
iFila = 1;

for iCR = 1:nCRFracSinInt
    midNode = constraintsRelationsSinInt(iCR,1);
    slave1 = constraintsRelationsSinInt(iCR,2);
    slave2 = constraintsRelationsSinInt(iCR,3);
    
    if constraintsRelationsSinInt(iCR,6) == 1
        % EQ FOR u (direccion X) DOFS %
        CTFracSinInt(iFila,[nodeDofs(midNode,1) nodeDofs(slave1,1) nodeDofs(slave2,1)]) = precondCT*[1 -1/2 -1/2];
        iFila = iFila + 1;
        % EQ FOR v (direccion Y) DOFS %
        CTFracSinInt(iFila,[nodeDofs(midNode,2) nodeDofs(slave1,2) ]) = precondCT*[1 -1];
        iFila = iFila + 1;
        CTFracSinInt(iFila,[nodeDofs(midNode,2) nodeDofs(slave2,2)]) = precondCT*[1 -1];
        iFila = iFila + 1;
        % EQ FOR w (direccion Z) DOFS  %
        CTFracSinInt(iFila,[nodeDofs(midNode,3) nodeDofs(slave1,3)]) = precondCT*[ 1 -1];
        iFila = iFila + 1;
        CTFracSinInt(iFila,[nodeDofs(midNode,3) nodeDofs(slave2,3)]) = precondCT*[ 1 -1];
        iFila = iFila + 1;
 
            
    else
        if constraintsRelationsSinInt(iCR,6) == 2
            % EQ FOR v (direccion Y) DOFS %
            CTFracSinInt(iFila,[nodeDofs(midNode,2) nodeDofs(slave1,2) nodeDofs(slave2,2)]) = precondCT*[1 -1/2 -1/2];
            iFila = iFila + 1;
            
            % EQ FOR w (direccion Z) DOFS %
            CTFracSinInt(iFila,[nodeDofs(midNode,3) nodeDofs(slave1,3) ]) = precondCT*[1 -1];
            iFila = iFila + 1;
            CTFracSinInt(iFila,[nodeDofs(midNode,3) nodeDofs(slave2,3)]) = precondCT*[1 -1];
            iFila = iFila + 1;
            
            % EQ FOR u (direccion X) DOFS  AVG %
            CTFracSinInt(iFila,[nodeDofs(midNode,1) nodeDofs(slave1,1)]) = precondCT*[ 1 -1];
            iFila = iFila + 1;
            CTFracSinInt(iFila,[nodeDofs(midNode,1) nodeDofs(slave2,1)]) = precondCT*[ 1 -1];
            iFila = iFila + 1;
    
            
        else
            if constraintsRelationsSinInt(iCR,6) == 3
                % EQ FOR w (direccion Z) DOFS %
                CTFracSinInt(iFila,[nodeDofs(midNode,3) nodeDofs(slave1,3) nodeDofs(slave2,3)]) = precondCT*[1 -1/2 -1/2];
                iFila = iFila + 1;
                
                % EQ FOR u (direccion X) DOFS %
                CTFracSinInt(iFila,[nodeDofs(midNode,1) nodeDofs(slave1,1) ]) = precondCT*[1 -1];
                iFila = iFila + 1;
                CTFracSinInt(iFila,[nodeDofs(midNode,1) nodeDofs(slave2,1)]) = precondCT*[1 -1];
                iFila = iFila + 1;
                
                % EQ FOR v (direccion Y) DOFS  %
                CTFracSinInt(iFila,[nodeDofs(midNode,2) nodeDofs(slave1,2)]) = precondCT*[ 1 -1];
                iFila = iFila + 1;
                CTFracSinInt(iFila,[nodeDofs(midNode,2) nodeDofs(slave2,2)]) = precondCT*[ 1 -1];
                iFila = iFila + 1;
            
            end
        end
    end

    
end

%%  - Borde de fractura con interseccion - 
% nCREqFracInt            = sum(sum(constraintsRelations>0,2)>3)*3; % Caso
% Tshape original
nCREqFracInt            = sum(sum(constraintsRelations(:,1:5)>0,2)>3)*6;
nCRFracInt              = sum(sum(constraintsRelations(:,1:5)>0,2)>3);
CTFracInt               = zeros(nCREqFracInt,nDofTot_U);
constraintsRelationsInt = constraintsRelations(sum(constraintsRelations(:,1:5)>0,2)>3,1:5);
iFila                   = 1;

for iCR = 1:nCRFracInt
    midNode = constraintsRelationsInt(iCR,1);
    slave1 = constraintsRelationsInt(iCR,2);
    slave2 = constraintsRelationsInt(iCR,3);
    slave3 = constraintsRelationsInt(iCR,4);
    slave4 = constraintsRelationsInt(iCR,5);
    
    casoCT = '';
    
    if size(unique(nodes(constraintsRelationsInt(iCR,:),1)),1) == 1
        casoCT = 'normalX';
    else
        if size(unique(nodes(constraintsRelationsInt(iCR,:),2)),1) == 1
            casoCT = 'normalY';
        else
            if size(unique(nodes(constraintsRelationsInt(iCR,:),3)),1) == 1
                casoCT = 'normalZ';
            else
                warning('Caso no definido para los CT de fractura')
            end
        end
    end
    
    switch casoCT
        case 'normalX'
            %% EQ FOR v (direccion Y) DOFS %%
            CTFracInt(iFila,[nodeDofs(midNode,2)    nodeDofs(slave1,2)...
                nodeDofs(slave2,2)     nodeDofs(slave3,2)...
                nodeDofs(slave4,2)]) = precondCT*[-1 1/4 1/4 1/4 1/4];
            iFila = iFila + 1;
            
            %% EQ FOR w (direccion Z) DOFS %%
            CTFracInt(iFila,[nodeDofs(midNode,3)    nodeDofs(slave1,3)...
                nodeDofs(slave2,3)     nodeDofs(slave3,3)...
                nodeDofs(slave4,3)]) = precondCT*[-1 1/4 1/4 1/4 1/4];
            iFila = iFila + 1;
            
            %% EQ FOR u (direccion X) DOFS %%
            CTFracInt(iFila,[nodeDofs(midNode,1) nodeDofs(slave1,1)]) = precondCT*[-1 1];
            iFila = iFila + 1;
            CTFracInt(iFila,[nodeDofs(midNode,1) nodeDofs(slave2,1)]) = precondCT*[-1 1];
            iFila = iFila + 1;
            CTFracInt(iFila,[nodeDofs(midNode,1) nodeDofs(slave3,1)]) = precondCT*[-1 1];
            iFila = iFila + 1;
            CTFracInt(iFila,[nodeDofs(midNode,1) nodeDofs(slave4,1)]) = precondCT*[-1 1];
            iFila = iFila + 1;

            
        case 'normalY'
            %% EQ FOR u (direccion X) DOFS %%
            CTFracInt(iFila,[nodeDofs(midNode,1)    nodeDofs(slave1,1)...
                nodeDofs(slave2,1)     nodeDofs(slave3,1)...
                nodeDofs(slave4,1)]) = precondCT*[-1 1/4 1/4 1/4 1/4];
            iFila = iFila + 1;
            
            %% EQ FOR w (direccion Z) DOFS %%
            CTFracInt(iFila,[nodeDofs(midNode,3)    nodeDofs(slave1,3)...
                nodeDofs(slave2,3)     nodeDofs(slave3,3)...
                nodeDofs(slave4,3)]) = precondCT*[-1 1/4 1/4 1/4 1/4];
            iFila = iFila + 1;
            
            %% EQ FOR v (direccion Y) DOFS %% 
            CTFracInt(iFila,[nodeDofs(midNode,2) nodeDofs(slave1,2)]) = precondCT*[-1 1];
            iFila = iFila + 1;
            CTFracInt(iFila,[nodeDofs(midNode,2) nodeDofs(slave2,2)]) = precondCT*[-1 1];
            iFila = iFila + 1;
            CTFracInt(iFila,[nodeDofs(midNode,2) nodeDofs(slave3,2)]) = precondCT*[-1 1];
            iFila = iFila + 1;
            CTFracInt(iFila,[nodeDofs(midNode,2) nodeDofs(slave4,2)]) = precondCT*[-1 1];
            iFila = iFila + 1;
        case 'normalZ'
            %% EQ FOR u (direccion X) DOFS %%
            CTFracInt(iFila,[nodeDofs(midNode,1)    nodeDofs(slave1,1)...
                nodeDofs(slave2,1)     nodeDofs(slave3,1)...
                nodeDofs(slave4,1)]) = precondCT*[-1 1/4 1/4 1/4 1/4];
            iFila = iFila + 1;
            
            %% EQ FOR v (direccion Y) DOFS %%
            CTFracInt(iFila,[nodeDofs(midNode,2)    nodeDofs(slave1,2)...
                nodeDofs(slave2,2)     nodeDofs(slave3,2)...
                nodeDofs(slave4,2)]) = precondCT*[-1 1/4 1/4 1/4 1/4];
            iFila = iFila + 1;
            
            %% EQ FOR w (direccion Z) DOFS %%
            CTFracInt(iFila,[nodeDofs(midNode,3) nodeDofs(slave1,3)]) = precondCT*[-1 1];
            iFila = iFila + 1;
            CTFracInt(iFila,[nodeDofs(midNode,3) nodeDofs(slave2,3)]) = precondCT*[-1 1];
            iFila = iFila + 1;
            CTFracInt(iFila,[nodeDofs(midNode,3) nodeDofs(slave3,3)]) = precondCT*[-1 1];
            iFila = iFila + 1;
            CTFracInt(iFila,[nodeDofs(midNode,3) nodeDofs(slave4,3)]) = precondCT*[-1 1];
            iFila = iFila + 1;
    end

end

%% JUNTO TODOS LOS CONSTRAINTS DE LA FRACTURA %%
CTFrac  = [CTFracSinInt
           CTFracInt];
nCREqFrac     = nCREqFracSinInt + nCREqFracInt;

end


