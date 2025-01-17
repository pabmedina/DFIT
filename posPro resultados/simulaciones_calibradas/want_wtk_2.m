clc
clearvars
% Paths
currentPath = pwd;
addpath('C:\Geomec\DFIT\posPro resultados\simulaciones_calibradas\stress_calc_fcn\')
% Input *.mat directory
matDir = 'C:\Geomec\DFIT\posPro resultados\simulaciones_calibradas\base\';
mpa2psi = 145.038;
outputFolder = 'base';
% Define prefix from *.mat
filePrefix = 'resultadosCorrida';

% Define file name
files = dir(fullfile(matDir, [filePrefix, '*.mat']));
% load *mat
% Verify if is *.mat exists 
if ~isempty(files)
    % load *mat
    matFilePath = fullfile(matDir, files(1).name);
    load(matFilePath);
    disp(['Archivo cargado: ', files(1).name]);
else
    disp('No se encontr� ning�n archivo que comience con el prefijo especificado.');
end

output_folder_location = ['D:\Geomec\paper DFN\ITBA\Piloto\DFIT\posPro resultados\simulaciones_calibradas\',outputFolder];

% Input mesh info coors para s�lidos
X = meshInfo.nodes(:,1);
Y = meshInfo.nodes(:,2);
Z = meshInfo.nodes(:,3);

% Input conectividad para s�lidos
elements3D = meshInfo.elements;

% specific range time 
timeInit = 1;
timeEnd = temporalProperties.nTimes;
spanTime = 1;

% inputs 
[constitutivas,Biot,meshProps] = elePropsEdit(physicalProperties,meshInfo.nodes,meshInfo.elements,pGaussParam.upg,'off','on',setBiot);

% input dofs 
pressure_field = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,:); % all history
displacement_field = dTimes(1:paramDiscEle.nDofTot_U,:); 
displacement_array = zeros(paramDiscEle.nNod, paramDiscEle.nDofNod,timeEnd);
for j = timeInit:1:timeEnd
    displacement_array(:,:,j) =  reshape(displacement_field(:,j),3,[])';
end

elementsField =  ones(size(pressure_field));
Eh = meshProps.E_H.*ones(size(pressure_field));
Ev = meshProps.E_V.*ones(size(pressure_field));
nuh = meshProps.nu_H.*ones(size(pressure_field));
nuv = meshProps.nu_V.*ones(size(pressure_field));

% --- Parte para exportar s�lidos en 3D ---
outputFile3D = 'meshSolid';

%% --- C�lculo de tensiones ---
% Calculo de tensiones efectivas por nodos.
[stress_gp, strain_gp] = calc_stress_eff(iTime,paramDiscEle,pGaussParam,meshInfo,constitutivas,dTimes,initialSrainSolPG);
% Extrapolacion de tensiones a los nodos.
[stress_nodal, strain_nodal] = extrapolation_nodal(iTime,pGaussParam,paramDiscEle,stress_gp, strain_gp);
% Calculo de tensiones efectivas. Primero hago el arreglo de array
% pertinente.
[pressure_gp, strain_pressure_gp] = calc_pressure_gp(pGaussParam,paramDiscEle,dTimes,iTime,meshInfo,constitutivas,Biot,temporalProperties);
% Calculo de tension efectiva.
stress_gp_tot = stress_gp - pressure_gp;
strain_gp_tot = strain_gp - strain_pressure_gp;
% Tensiones efectivas promediadas por nodo compartido.
[mean_eff_stress, mean_eff_strain ] = mean_nodal_field(paramDiscEle,iTime,meshInfo,stress_nodal,strain_nodal,'on');
% Calculo tensiones totales en los gp. Tenerlo en cuenta.
[mean_tot_gp_stress, mean_tot_gp_strain] = mean_nodal_field(paramDiscEle,iTime,meshInfo,stress_gp_tot,strain_gp_tot,'on');
% Promediamos el flujo por nodo compartido
[mean_flux, ~] = mean_nodal_field(paramDiscEle,iTime,meshInfo,q_flux,[],'off');
% --- Seguir codigo a partir de aqui
disp('Codigo en desarrollo. Falta calcular campos de tenesiones. Seguir desarrollando a partir de esta linea.');
return;
for i = timeInit:1:timeEnd
    filenameSolid = [outputFile3D, num2str(i), '.vtu'];

    % Extraer las componentes del tensor de tensiones para el instante de tiempo i
    stress_xx = mean_eff_stress(:,1,i);
    stress_yy = mean_eff_stress(:,2,i);
    stress_zz = mean_eff_stress(:,3,i);
    stress_xy = mean_eff_stress(:,4,i);
    stress_yz = mean_eff_stress(:,5,i);
    stress_zx = mean_eff_stress(:,6,i);
    
    % tensiones totales
    stress_xx_tot = mean_tot_gp_stress(:,1,i);
    stress_yy_tot = mean_tot_gp_stress(:,2,i);
    stress_zz_tot = mean_tot_gp_stress(:,3,i);
    stress_xy_tot = mean_tot_gp_stress(:,4,i);
    stress_yz_tot = mean_tot_gp_stress(:,5,i);
    stress_zx_tot = mean_tot_gp_stress(:,6,i);
    
    % strain 
    strain_xx = mean_eff_strain(:,1,i);
    strain_yy = mean_eff_strain(:,2,i);
    strain_zz = mean_eff_strain(:,3,i);
    strain_xy = mean_eff_strain(:,4,i);
    strain_yz = mean_eff_strain(:,5,i);
    strain_zx = mean_eff_strain(:,6,i);
    
    % flujos {q}
    q_x = mean_flux(:,1,i);
    q_y = mean_flux(:,2,i);
    q_z = mean_flux(:,3,i);
    
    % Extraer los desplazamientos en x, y, z para el instante de tiempo i
    displacement_x = displacement_array(:,1,i);
    displacement_y = displacement_array(:,2,i);
    displacement_z = displacement_array(:,3,i);
    
    % Exportar datos de la malla s�lida
    vtkwrite([filenameSolid, '.vtk'], 'cell', 'hexahedron', X, Y, Z, elements3D, ...
        'scalars', 'solid', elementsField(:,i), ...
        'scalars', 'p_p', pressure_field(:,i), ...
        'scalars', 'Ev', Ev(:,i), ...
        'scalars', 'Eh', Eh(:,i), ...
        'scalars', 'nu_h', nuh(:,i), ...
        'scalars', 'nu_v', nuv(:,i), ...
        'vectors', 'stress_eff', stress_xx, stress_yy, stress_zz, ...
        'scalars', 'stress_xy_eff', stress_xy, 'scalars', 'stress_yz_eff', stress_yz, ...
        'scalars', 'stress_zx_eff', stress_zx, ...
        'vectors', 'strain', strain_xx, strain_yy, strain_zz, ...
        'vectors', 'stress_tot', stress_xx_tot, stress_yy_tot, stress_zz_tot, ...
        'scalars', 'stress_xy_tot', stress_xy_tot, 'scalars', 'stress_yz_tot', stress_yz_tot, ...
        'scalars', 'stress_zx_tot', stress_zx_tot, ...
        'vectors', 'displacement', displacement_x, displacement_y, displacement_z, ...
        'vectors', 'flux', q_x, q_y, q_z, ...
        'Precision', 6);  % Aumenta la precisi�n a 6 decimales
    
end


% --- Parte para exportar fluidos (fractura hidr�ulica) en 2D con varios elementos para todos los tiempos --- 
outputFile2D = 'meshFluid';

% Coordenadas de los nodos de fluido
X_fluid = meshInfo.nodes(:,1);
Y_fluid = meshInfo.nodes(:,2);
Z_fluid = meshInfo.nodes(:,3);  % La Z es constante si es 2D

% Conectividad de los elementos de fluido
elementsFluid2D = meshInfo.elementsFluidos.elements;  % Conectividad de los elementos (4 nodos por elemento)

% Iterar sobre todos los tiempos
for iTime = timeInit:timeEnd
    % Presi�n en nodos de fluido para un tiempo espec�fico
    pressure_fluid = pressure_field(:, iTime);  % Presi�n en los nodos en el tiempo iTime
    
    % Generar archivo VTK
    filenameFluid = [outputFile2D, '_pressure_time_', num2str(iTime), '.vtu'];
    
    % Crear archivo VTK
    fid = fopen([filenameFluid, '.vtk'], 'w+');
    
    % 1. Cabecera
    fprintf(fid, '# vtk DataFile Version 2.0\n');
    fprintf(fid, 'Fluido 2D Mesh with Pressure\n');
    fprintf(fid, 'ASCII\n');
    fprintf(fid, 'DATASET UNSTRUCTURED_GRID\n');
    
    % 2. Especificar nodos
    nNodos = size(meshInfo.nodes, 1);
    fprintf(fid, 'POINTS %d float\n', nNodos);
    for i = 1:nNodos
        fprintf(fid, '%f %f %f\n', X_fluid(i), Y_fluid(i), Z_fluid(i));
    end
    
    % 3. Especificar celdas (elementos)
    nElementos = size(elementsFluid2D, 1);
    fprintf(fid, 'CELLS %d %d\n', nElementos, nElementos * 5);  % 4 nodos + 1 para el tipo de celda
    for i = 1:nElementos
        fprintf(fid, '4 %d %d %d %d\n', elementsFluid2D(i,:) - 1);  % Restamos 1 para ajustar a VTK
    end
    
    % 4. Tipo de celda
    fprintf(fid, 'CELL_TYPES %d\n', nElementos);
    for i = 1:nElementos
        fprintf(fid, '9\n');  % El tipo 9 corresponde a QUAD en VTK
    end
    
    % 5. Especificar datos de presi�n en los nodos
    fprintf(fid, 'POINT_DATA %d\n', nNodos);
    fprintf(fid, 'SCALARS Pressure float 1\n');
    fprintf(fid, 'LOOKUP_TABLE default\n');
    for i = 1:nNodos
        fprintf(fid, '%f\n', pressure_fluid(i));  % Presi�n en cada nodo
    end
    
    % Cerrar archivo
    fclose(fid);
    
end

disp('Todos los archivos de presi�n han sido generados.');


% Crear la carpeta "output" dentro de output_folder_location si no existe
outputDir = fullfile(output_folder_location, 'output');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Cambiar al directorio original donde est�n los archivos mesh*
cd(currentPath);

% Mover los archivos mesh* a la carpeta "output"
movefile('mesh*', outputDir);

% %   clf
%         subplot(1,2,1)
%         bandplot(mat.meshInfo.cohesivos.elements,mat.meshInfo.nodes,mat.meshInfo.cohesivos.dNTimes(:,:,50))
%         axis square
%         view(-45,20)
%         daspect([1 1 1])
%         hold on
%         %         scatter3(meshInfo.nodes(reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1),1),meshInfo.nodes(reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1),2),meshInfo.nodes(reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1),3),'r')
% 
%        % title(['iTime: ',num2str(50)])
% 
%         subplot(1,2,2)
%         
%         plotColo(mat.meshInfo.nodes,mat.meshInfo.elementsFluidos.elements,fieldPressure(:,50)*mpa2psi)
%         axis square
%         view(-45,20)
%         daspect([1 1 1])
%         %title(['iTime: ',num2str(50)])
%         drawnow

