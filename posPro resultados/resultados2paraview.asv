function resultados2paraview(resultados,nameFile)

load(resultados)

nodes=meshInfo.nodes;
elements=meshInfo.elements;
nCellData=0; %valores para elementos
type='HEXA'; %para dn's quad
temporalProperties.nTimes

for iTime=1:temporalProperties.nTimes
    filename=[nameFile ,num2str(iTime),'.vtu'];
    
    x=dTimes(1:3:paramDiscEle.nDofTot_U,iTime); 
    y=dTimes(2:3:paramDiscEle.nDofTot_U,iTime);
    z=dTimes(3:3:paramDiscEle.nDofTot_U,iTime);
    P=dTimes((paramDiscEle.nDofTot_U+1):(paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P),iTime);
         pressureTimes = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;


   
    
    %% Tensiones (Para distintos tiempos)
    unod = pGaussParam.upg*sqrt(3); 
    stress = zeros(paramDiscEle.nel,paramDiscEle.nNodEl,6);%cell(nnodel,size(constitutivas{1},1),nel,length(Time));
    for iele = 1:paramDiscEle.nel 
        nodesEle = meshInfo.nodes(meshInfo.elements(iele,:),:);

        for npg = 1:size(unod,1)
        
            % Puntos nodales
            ksi = unod(npg,1);
            eta = unod(npg,2);
            zeta = unod(npg,3);

            % Derivadas de las funciones de forma respecto de ksi, eta, zeta         
  
            % Derivadas de las funciones de forma respecto de ksi, eta, zeta
            dN = [ ((eta - 1)*(zeta + 1))/8, -((eta - 1)*(zeta - 1))/8, ((eta + 1)*(zeta - 1))/8, -((eta + 1)*(zeta + 1))/8, -((eta - 1)*(zeta + 1))/8, ((eta - 1)*(zeta - 1))/8, -((eta + 1)*(zeta - 1))/8, ((eta + 1)*(zeta + 1))/8
                ((ksi - 1)*(zeta + 1))/8, -((ksi - 1)*(zeta - 1))/8, ((ksi - 1)*(zeta - 1))/8, -((ksi - 1)*(zeta + 1))/8, -((ksi + 1)*(zeta + 1))/8, ((ksi + 1)*(zeta - 1))/8, -((ksi + 1)*(zeta - 1))/8, ((ksi + 1)*(zeta + 1))/8
                ((eta - 1)*(ksi - 1))/8,  -((eta - 1)*(ksi - 1))/8,  ((eta + 1)*(ksi - 1))/8,  -((eta + 1)*(ksi - 1))/8,  -((eta - 1)*(ksi + 1))/8,  ((eta - 1)*(ksi + 1))/8,  -((eta + 1)*(ksi + 1))/8,  ((eta + 1)*(ksi + 1))/8 ];
            
            dN = dN(:,[8,4,1,5,7,3,2,6]);

            jac = dN*nodesEle;                

            % Derivadas de las funciones de forma respecto de x,y,z
            dNxyz = jac\dN;          % dNxyz = inv(jac)*dN
            
            B = zeros(6,paramDiscEle.nDofEl);

            B(1,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
            B(2,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:); 
            B(3,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
            B(4,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
            B(4,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
            B(5,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
            B(5,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
            B(6,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
            B(6,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);

            eleDofs = paramDiscEle.nodeDofs(meshInfo.elements(iele,:),:);
            eleDofs = reshape(eleDofs',[],1);
            stress(iele,npg,:) = (constitutivas{iele}(:,:,npg))*B*dTimes(eleDofs,iTime);

        end
    end
    %% Presiones efectivas.
    presionEfectiva = zeros(paramDiscEle.nel,paramDiscEle.nNodEl,6);
     pressureTimes = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
    for iele = 1:paramDiscEle.nel
        for nP = 1:size(unod,1)
            
            ksi = unod(nP,1);
            eta = unod(nP,2);
            zeta = unod(nP,3);
            
            % Funciones de forma

            N = [ (1-ksi)*(1-eta)*(1+zeta)/8, (1-ksi)*(1-eta)*(1-zeta)/8, (1-ksi)*(1+eta)*(1-zeta)/8.... 
                  (1-ksi)*(1+eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1-zeta)/8....
                  (1+ksi)*(1+eta)*(1-zeta)/8, (1+ksi)*(1+eta)*(1+zeta)/8 ];
            
            N = N(1,[8,4,1,5,7,3,2,6]);   
            
            presionEfectiva(iele,nP,:) = (Biot{iele}(:,:,nP)*N*pressureTimes(meshInfo.elements(iele,:)))';
            
        end
    end
    tensionEfectiva = stress - presionEfectiva;

    avgStress=zeros(paramDiscEle.nDofTot_P,6); % Descuenta la presion efectiva de las tensiones.
    for inode = 1:paramDiscEle.nDofTot_P
        [I,J] = find(meshInfo.elements == inode);
        nShare = length(I);
        for ishare = 1:nShare
            avgStress(inode,:) = avgStress(inode,:) + squeeze(tensionEfectiva(I(ishare),J(ishare),:))';
        end
        avgStress(inode,:) = avgStress(inode,:) / nShare;

    end

    avgStressComun = zeros(paramDiscEle.nDofTot_P,6); % No descuenta la presion efectiva de las tensiones.
    for inode = 1:paramDiscEle.nDofTot_P
        [I,J] = find(meshInfo.elements == inode);
        nShare = length(I);
        for ishare = 1:nShare
            avgStressComun(inode,:) = avgStressComun(inode,:) + squeeze(stress(I(ishare),J(ishare),:))';
        end
        avgStressComun(inode,:) = avgStressComun(inode,:) / nShare;

    end

 
    % mPa a psi/ft, estando a 2935 m de profundidad.
    meter2feet = 3.28;
     mPa2psi   = 145;
    depthMalla = 2935; % metros de profundidad       
   
    avgStressEdit = -1* mPa2psi * avgStress/(depthMalla*meter2feet); 
    avgStressComunEdit = mPa2psi * avgStressComun/(depthMalla*meter2feet); 
    pressureTimesEdit =  mPa2psi*pressureTimes/(depthMalla*meter2feet);


    
    
    
    %% Guardado y Armado de VTU
%     valName={'P_mpa' 'P_psi'};
%     values={pressureTimes pressureTimes*mPa2psi};
%     
    valName={'X_mm' 'Y_mm' 'Z_mm' 'RealPressure_Mpa' 'SigmaXX_psiRes','SigmaYY_psiRes','SigmaZZ_psiRes','PoralPressure_psiRes','SigmaXX_MPa','SigmaYY_MPa','SigmaZZ_MPa','PoralPressure_MPa'}; 
    values={x y z P avgStressEdit(:,1) avgStressEdit(:,2) avgStressEdit(:,3) pressureTimesEdit avgStress(:,1) avgStress(:,2) avgStress(:,3) pressureTimes };
    nPointData=size(values,2);
    
    vtuwrite(filename,nodes,elements,type,nPointData,nCellData,valName,values)
end


%     %% dN promediado en nodos de fractura
%     fractureElementsTimes = zeros(size(meshInfo.elementsFluidos.activos,1), temporalProperties.nTimes);
%     
%     for iTime = 1:temporalProperties.nTimes
%     nodosMuertos             = reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1);
%     deadIntNodes             = ismember(intNodes,nodosMuertos);
%     
%     if any(deadIntNodes)
%         deadIntNodesIndex    = intNodes(deadIntNodes);
%         nodesToAdd           = nonzeros(unique(reshape(CRFluidos(sum(ismember(CRFluidos,deadIntNodesIndex),2)>0,:),[],1)));
%         nodosMuertos         = [nodosMuertos
%                                 nodesToAdd ];
%         nodosMuertos          = unique(nodosMuertos);                    
%     end
% 
%     fractureElementsTimes(:,iTime)  = sum(ismember(meshInfo.elementsFluidos.elements,nodosMuertos),2) > 0; % elementos que tienen nodos muertos.
%     %^chequear si no es mejor ver qué fracción del elemento está
%     %fracturado.
%     end
% 
%     
% for iTime = 1:temporalProperties.nTimes
%     X = meshInfo.nodes(1:paramDiscEle.nDofTot_P,1);
%     Y = meshInfo.nodes(1:paramDiscEle.nDofTot_P,2);
%     Z = meshInfo.nodes(1:paramDiscEle.nDofTot_P,3);
%     %los cohesivos tienen 4 nodos en su matriz elements y 4 dNTimes por cohesivo.
%     %uso 'quad' en vtkwrite.
%     
%     % promedio los valores de dN que toquen a un nodo. A los de fuera de la
%     % fractura les pongo que valen 0.
%     dNxNodo=zeros(size(X,1),1);
%     indices = meshInfo.cohesivos.elements(:);
%     valoresSinExtrapolar = meshInfo.cohesivos.dNTimes(:,:,iTime);
%     valores = valoresSinExtrapolar; %acá falta hacer unas cuentas para ser más exactos.
%     valores = valores(:);
%     tabla=[];
%     for i=min(indices):max(indices)
%         pos=find(i==indices);
%         if ~isempty(pos)
%             tabla = [tabla; i mean(valores(pos))];
%         end
%     end
%     dNxNodo(tabla(:,1)) = dNxNodo(tabla(:,1))+tabla(:,2);
%     
%     nPointData=1;
%     nCellData=1;
%     valName={'dN_mm','fracturado'};
%     values={dNxNodo,fractureElementsTimes(:,iTime)};
%     filename=[nameFile,'DN',num2str(iTime),'.vtu'];
%     vtuwrite(filename,meshInfo.nodes(1:paramDiscEle.nDofTot_P,1:3),meshInfo.cohesivos.elements,'QUAD',nPointData,nCellData,valName,values);
% end


%% Archivo PVD para todo menos Dn's

fid=fopen(['animacion_' nameFile '.pvd'],'w');

fprintf(fid, '%s \n', '<?xml version="1.0"?>');
fprintf(fid, '%s \n', '<VTKFile type="Collection" version="0.1" byte_order="LittleEndian">');
fprintf(fid, '%s \n', '<Collection> ');

for i=1:temporalProperties.nTimes-1
    fprintf(fid,'%s%s%s%s%s\n', '<DataSet timestep="', num2str(i),'" part="001" file="',nameFile,num2str(i),'.vtu"/>');
end

fprintf(fid, '%s \n', '</Collection>');
fprintf(fid, '%s \n', '</VTKFile>');

fclose(fid);


% %% Archivo PVD para Dn's
% 
% fid=fopen(['animacion_', nameFile,'_DN.pvd'],'w');
% 
% fprintf(fid, '%s \n', '<?xml version="1.0"?>');
% fprintf(fid, '%s \n', '<VTKFile type="Collection" version="0.1" byte_order="LittleEndian">');
% fprintf(fid, '%s \n', '<Collection> ');
% 
% for i=1:temporalProperties.nTimes
%     fprintf(fid,'%s%s%s%s%s\n', '<DataSet timestep="', num2str(i),'" part="001" file="',nameFile,num2str(i),'.vtu"/>');
% end
% 
% fprintf(fid, '%s \n', '</Collection>');
% fprintf(fid, '%s \n', '</VTKFile>');
% 
% fclose(fid);

end

function vtuwrite(filename,nodes,elements,type,nPointData,nCellData,valName,values)
Nnode=size(nodes,1);
Ncell=size(elements,1);
%nodes: matriz (x y z)
%elements: matriz de conectividades
%nPointData: cuantas variables PointData hay
%nCellData: cuantas variables CellData hay
%valName es una celda con los nombres de las variables a guardar. Ingresar
%primero variables pointData, luego variables CellData.
%values es una celda de matrices, con los valores de las variables a guardar.
Ncolafter=size(elements,2); % entiendo q el nro de nodos x elemento
switch type
    case 'HEXA'
        Type=12;
    case 'QUAD'
        Type=9;
end

fid = fopen(filename, 'w+'); 

fprintf(fid, '%s \n', '<?xml version = "1.0"?>');
fprintf(fid, '%s \n', '<VTKFile type="UnstructuredGrid" version="0.1" byte_order="LittleEndian">');
fprintf(fid, '%s \n', '<UnstructuredGrid>');
fprintf(fid, '<Piece NumberOfPoints="%i" NumberOfCells="%i"> \n\n', Nnode, Ncell);
fprintf(fid, '%s \n', '<Points>');
fprintf(fid, '%s \n', '<DataArray type="Float32" NumberOfComponents="3" format="ascii"/>');

%xyz de los nodos
for i = 1:Nnode
    for j=1:3
        fprintf(fid, '%f  ', nodes(i,j));
    end
    fprintf(fid, '\n');
end

fprintf(fid, '%s \n\n', '</Points>');
fprintf(fid, '%s \n', '<Cells>');
fprintf(fid, '%s \n', '<DataArray type="Int32" Name="connectivity" format="ascii"/>');

%conectividades, matriz elements
for i=1:Ncell
    for j=1:Ncolafter
        fprintf(fid, '%i  ', elements(i,j)-1); %-1 xq se cuenta desde 0.
    end
    fprintf(fid, '\n');
end

fprintf(fid, '\n %s \n', '<DataArray type="Int32" Name="offsets" format="ascii"/>');

suma=Ncolafter;
for i=1:Ncell
    fprintf(fid, '%i  ', Ncolafter);
    Ncolafter=Ncolafter+suma;
end

fprintf(fid, '\n %s \n', '<DataArray type="Int32" Name="types" format="ascii"/>');
for i=1:Ncell
    fprintf(fid, '%i ', Type);
end

fprintf(fid,'\n %s \n', '</Cells>');

if nPointData>0
    fprintf(fid, '\n <PointData> \n');
    for iVar=1:nPointData
        fprintf(fid, '<DataArray type="Float32" NumberOfComponents="1" Name="%s" format="ascii"/> \n', valName{iVar});
        %^revisar el name, n of components. Creo que despues le puedo agregar otro
        %dato, el de 'fracturado'.
        iVal=values{iVar};
        for i=1:Nnode
            fprintf(fid,'%10.5E ', iVal(i,1)'); %medio overkill ese 10.5E
        end

    end
    fprintf(fid,'\n </PointData> \n');
end
if nCellData>0
    fprintf(fid, '\n <CellData> \n');
    for iVar=1+nPointData:nCellData+nPointData
        fprintf(fid, '<DataArray type="Float32" NumberOfComponents="1" Name="%s" format="ascii"/> \n', valName{iVar});
        %^revisar el name, n of components. Creo que despues le puedo agregar otro
        %dato, el de 'fracturado'.
        iVal=values{iVar};
        for i=1:length(iVal)
            fprintf(fid,'%10.5E ', iVal(i,1)'); %medio overkill ese 10.5E
        end
    end
    fprintf(fid,'\n </CellData> \n');
end


fprintf(fid,'\n %s \n', '</Piece>');
fprintf(fid,'%s \n', '</UnstructuredGrid>');
fprintf(fid,'%s \n', '</VTKFile>');

fclose(fid);
end