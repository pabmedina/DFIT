clearvars
clc
close all
mainPlot = false;

mpa2psi = 145.038;
%% MAIN constructed to export data into VTK format.
addpath('D:\Geomec\paper DFN\ITBA\Piloto\DFIT\scriptSolverGitHub\')
% change current directory to the path where results (.mat) were saved.
currentPath = cd('D:\Geomec\paper DFN\ITBA\Piloto\DFIT\Resultados de corridas (.mat)\');
% input sub folder and load .mat file
inputFolder = cd('DFIT_WIplusDFNs_permNerf');
mat = load('resultadosCorrida_DFIT_WIplusDFNs_permNerf.mat');

% get back to paraview folder
% mainFolder = cd(currentPath);

%work with the matFile. Select data that you want graph in paraview

% e.g:
cd(currentPath)
% Input mesh info coors
X = mat.meshInfo.nodes(:,1);
Y = mat.meshInfo.nodes(:,2);
Z = mat.meshInfo.nodes(:,3);

% Input connectivity 
elements2D = mat.meshInfo.elementsFluidos.elements;
elements3D = mat.meshInfo.elements;
elements2D_cohesivos = mat.meshInfo.cohesivos.elements;
dfn_bool_index = strcmp('X',mat.meshInfo.cohesivos.name);
wi_bool_index = strcmp('Z',mat.meshInfo.cohesivos.name);
hf_bool_index = strcmp('Y',mat.meshInfo.cohesivos.name);

if mainPlot
    plotMeshColo3D(mat.meshInfo.nodes,elements3D,elements2D(hf_bool_index,:),'off','on','w','g','k',1)
end

% specific range time 
timeInit = 1;% mat.temporalProperties.drainTimes;
timeEnd = mat.temporalProperties.nTimes;
spanTime = 1;

% inputs 
[constitutivas,Biot,meshProps] = elePropsEdit(mat.physicalProperties,mat.meshInfo.nodes,mat.meshInfo.elements,mat.pGaussParam.upg,'off','on',mat.setBiot);

% input dofs 
dTimes = mat.dTimes; % all history
fieldPressure = dTimes(mat.paramDiscEle.nDofTot_U+1:mat.paramDiscEle.nDofTot_U+mat.paramDiscEle.nDofTot_P,:); % all history
gap = [];%mat.meshInfo.cohesivos.dNTimes;
for itime = 1:size(mat.meshInfo.cohesivos.dNTimes,3)
    for k = 1:size(mat.meshInfo.cohesivos.dNTimes,1)
        gap(k,itime) = mean(mat.meshInfo.cohesivos.dNTimes(k,:,itime));
    end
end


elementsField =  ones(size(fieldPressure));
Eh = meshProps.E_H.*ones(size(fieldPressure));
Ev = meshProps.E_V.*ones(size(fieldPressure));
outputFile2D = 'meshFluid';
outputFile2D_X = 'meshFluid_X';
outputFile2D_Y = 'meshFluid_Y';
outputFile2D_Z = 'meshFluid_Z';
outputFile3D = 'meshSolid';

nameFile = 'my_trial';
for i = timeInit:1:100
    filenameComp =[nameFile,num2str(i),'.vtu'];
    vtkwrite([outputFile2D num2str(i) '.vtk'],'cell','quad',X,Y,Z,elements2D,...
    'scalars','pressure_psi',fieldPressure(:,i)*mpa2psi);

    vtkwrite(['meshGap' num2str(i) '.vtk'],'cell','quad',X,Y,Z,elements2D_cohesivos,...
    'scalars','dN',gap(:,i));

    vtkwrite([outputFile2D_X num2str(i) '.vtk'],'cell','quad',X,Y,Z,elements2D(dfn_bool_index,:),...
    'scalars','pressure_psi',fieldPressure(:,i)*mpa2psi);

    vtkwrite([outputFile2D_Y num2str(i) '.vtk'],'cell','quad',X,Y,Z,elements2D(hf_bool_index,:),...
    'scalars','pressure_psi',fieldPressure(:,i)*mpa2psi);

    vtkwrite([outputFile2D_Z num2str(i) '.vtk'],'cell','quad',X,Y,Z,elements2D(wi_bool_index,:),...
    'scalars','pressure_psi',fieldPressure(:,i)*mpa2psi);

    vtkwrite([outputFile3D num2str(i) '.vtk'],'cell','hexahedron',X,Y,Z,elements3D,...
    'scalars','solid',elementsField(:,i),'scalars','Eh',Eh(:,i),'scalars','Ev',Ev(:,i))
    
%     %%% 2D MESH %%%
%     fileName = strcat(baseFileName2D,num2str(int16(fileNumber)),".vtk");
%     vtkwrite(fileName,'cell','quad',X,Y,Z,elementsFluidos.elements,'scalars','pressure_MPa',dTimes(nDofTot_U+1:nDofTot_U+nDofTot_P,timeStep)*preCond)
%     %%% 3D MESH %%%
%     fileName = strcat(baseFileName3D,num2str(int16(fileNumber)),".vtk");
%     vtkwrite(fileName,'cell','hexahedron',X,Y,Z,elements,'scalars','pressure_MPa',dTimes(nDofTot_U+1:nDofTot_U+nDofTot_P,timeStep)*preCond)

    
    
end
% 
%% Archivo PVD para todo menos Dn's

% fid=fopen(['animacion_' outputFile '.pvd'],'w');
% 
% fprintf(fid, '%s \n', '<?xml version="1.0"?>');
% fprintf(fid, '%s \n', '<VTKFile type="Collection" version="0.1" byte_order="LittleEndian">');
% fprintf(fid, '%s \n', '<Collection> ');
% 
% for j = timeInit:1:100
%     fprintf(fid,'%s%s%s%s%s\n', '<DataSet timestep="', num2str(j),'" part="001" file="',nameFile,num2str(j),'.vtu"/>');
% end
% 
% fprintf(fid, '%s \n', '</Collection>');
% fprintf(fid, '%s \n', '</VTKFile>');
% 
% fclose(fid);


% incate folder outputname eg:vtkTest
movefile mesh* vtkNoFeatures
%   clf
%         subplot(1,2,1)
%         bandplot(mat.meshInfo.cohesivos.elements,mat.meshInfo.nodes,mat.meshInfo.cohesivos.dNTimes(:,:,50))
%         axis square
%         view(-45,20)
%         daspect([1 1 1])
%         hold on
%         %         scatter3(meshInfo.nodes(reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1),1),meshInfo.nodes(reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1),2),meshInfo.nodes(reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1),3),'r')
% 
%         title(['iTime: ',num2str(50)])
% 
%         subplot(1,2,2)
%         
%         plotColo(mat.meshInfo.nodes,mat.meshInfo.elementsFluidos.elements,fieldPressure(:,50))
%         axis square
%         view(-45,20)
%         daspect([1 1 1])
%         title(['iTime: ',num2str(50)])
%         drawnow

