clc;clear;close all
%% Archivos a leer
for i=1:7
addpath(['D:\Corridas\Paper geomec DFN\Santi\DFIT 7 del 23\DFIT\Resultados de corridas (.mat)\DFIT_DFN_github_new_variasPerm_' num2str(i)]);

end
addpath('D:\Corridas\Paper geomec DFN\Santi\DFIT 7 del 23\DFIT\scriptSolver\')
addpath('D:\Geomec\paper DFN\ITBA\Piloto\DFIT\scriptSolver\')
%% Parametros para analizar
names = {'resultadosFinFractura_DFIT_DFN_github_new_variasPerm_5'};%{'resultadosCorrida_DFIT_mensual'};%{'resultadosCorrida_resultadosCorrida_test6BorrarMatch'};%{'resultados_DFITFract_trial_poralMod1'};%
fName = 'zonaInteresPreproLimpio';
z1 = 3050e3;  %Profundidades entre las que se analiza. Z1 < Z2
z2 = 3120e3;

fileName = [fName '.xlsx'];
%% Lectura de tensiones por nodos
%% Si se usa plotTensionesSinPromediar
for h = 1:length(names)
load([names{h} '.mat']);
plotTensionesSinPromediarStrain
    c = 1;
    for i = 1:length(meshInfo.elements)
        for j =1:8
            st_mat(c,1) = meshInfo.nodes(meshInfo.elements(i,j),3);
            st_mat(c,2) = tensionEfectivaPG(i,j,1)*mPa2psi;
            st_mat(c,3) = tensionEfectivaPG(i,j,2)*mPa2psi;
            st_mat(c,4) = tensionEfectivaPG(i,j,3)*mPa2psi;
            st_mat(c,5) = zeros(length(st_mat(c,4)),1);
            c = c+1;
        end
    end
    %% Si se usa plotTensionesPromediadas descomentar esto
    % st_mat(:,1)=meshInfo.nodes(:,3); %Coordenada z
    % st_mat(:,2)=avgStress(:,1)*mPa2psi; % Sxx
    % st_mat(:,3)=avgStress(:,2)*mPa2psi; % Syy
    % st_mat(:,4)=avgStress(:,3)*mPa2psi; % Szz

    z = unique(st_mat(:,1));
    check = 0;
    k = 1;
    target = 1;

    while check ==0
        if target-1==length(z)
            check =1;
        elseif st_mat(k,1)== z(target)
            uStress(target,:)=st_mat(k,:);
            target = target+1;
            k = 1;
        else
            k = k+1;
        end
    end
    uStress(1,1) = z2;
    uStress(end,1) = z1;
    for i = 2:length(z)-1
        uStress(i,1) = z2 - z(i,1);
    end
%     %% Cambio de escala para z
%     % El z intermedio - 20m = 3800000
%     % z intermedio + 20 m = 3760000 
%     z_aux1 = (max(uStress(:,1))+min(uStress(:,1)))/2+2e4;
%     z_aux2 = (max(uStress(:,1))+min(uStress(:,1)))/2-2e4;
% 
%     a = (z2-z1)/(z_aux2-z_aux1);
%     b = z2-a*z_aux2;
% 
%     uStress(:,1)=a*uStress(:,1)+b;
    
    %Calculo de Sz/Z
    uStress(:,5) = zeros(length(uStress(:,1)),1);
    for t = 1:length(uStress(:,1))
        uStress(t,5)= (uStress(t,4)/uStress(t,1))*1000/meter2feet;
    end
    effstress{h} = uStress;
end

H=uStress(2:end-2,1)/1000; %ya esta en m
depth = H;


grad = effstress{:}(2:end-2,2:4)./ repmat((depth(:,1)*meter2feet),1,3);


% for i = 1:15
%     grad(i,1) = grad(i,1)  + 0.8*2800/3125/3.28;
%     grad(i,2) = grad(i,2)  + 0.8*3100/3125/3.28;
% end

%% Del Excel
% Cuando llega a este punto aparece la variable relev ya formada por eso
% agregue la siguiente linea
clear relev

relev(:,1)=round(xlsread(fileName,1,'A2:A71','basic')*1e-3,3)*1e3; %z
relev(:,2)= -xlsread(fileName,1,'K2:K71','basic'); %Szz/z
relev(:,3)= -xlsread(fileName,1,'L2:L71','basic'); %Sxx/z
relev(:,4)= -xlsread(fileName,1,'M2:M71','basic'); %Syy/z
% relev(:,5) = zeros(length(relev(:,1)),1);
%     for t = 1:length(relev(:,1))
%         relev(t,5)= (relev(t,4)/relev(t,1))*1000/meter2feet;% Szz/Z
%     end
    
%% Plot
figure
hold on
plot(abs(relev(:,3)),relev(:,1))
plot(abs(grad(:,1)),depth)
set(gca,'YDir','reverse');
xAxis = [0.3 1.45];
line(xAxis,[3104 3104 ],'Color','red')
line(xAxis,[3109 3109 ],'Color','red')
ylabel('z [m]');xlabel('Grad Sxx [psi/ft]');
legend('DataPiloto','FEA');
xlim(xAxis)
grid minor
pbaspect([1 2.5 1 ])

figure
hold on
plot(abs(relev(:,4)),relev(:,1))
plot(abs(grad(:,2)),depth)
set(gca,'YDir','reverse');
xAxis = [0.3 1.7];
line(xAxis,[3104 3104 ],'Color','red')
line(xAxis,[3109 3109 ],'Color','red')
ylabel('z [m]');xlabel('Grad Syy [psi/ft]');
legend('DataPiloto','FEA');
xlim(xAxis)
grid minor
pbaspect([1 2.5 1 ])

% figure
% hold on
% plot(abs(relev(:,2)),relev(:,1))
% plot(abs(grad(:,1)),depth)
% set(gca,'YDir','reverse');
% ylabel('z [m]');xlabel('Grad Szz [psi/ft]');
% legend('DatosConocidos','resultadosCorrida_trial3');
% figure
% hold on
% plot(relev(find(relev(:,1)==z1):find(relev(:,1)==z2),2),relev(find(relev(:,1)==z1):find(relev(:,1)==z2),1));
% for i = 1:length(names)
%     plot(effstress{i}(find(effstress{i}(:,1)==z2):find(effstress{i}(:,1)==z1),2),effstress{i}(find(effstress{i}(:,1)==z2):find(effstress{i}(:,1)==z1),1));
% end
% set(gca,'YDir','reverse');xlabel('Sx [psi]');ylabel('z [mm]');
% legend(fName,names{:});
% 
% figure;
% hold on
% plot(relev(find(relev(:,1)==z1):find(relev(:,1)==z2),3),relev(find(relev(:,1)==z1):find(relev(:,1)==z2),1));
% for i = 1:length(names)
%     plot(effstress{i}(find(effstress{i}(:,1)==z2):find(effstress{i}(:,1)==z1),3),effstress{i}(find(effstress{i}(:,1)==z2):find(effstress{i}(:,1)==z1),1));
% end
% set(gca,'YDir','reverse');xlabel('Sy [psi]');ylabel('z [mm]');
% legend(fName,names{:});
% 
% figure;
% hold on
% plot(relev(find(relev(:,1)==z1):find(relev(:,1)==z2),4),relev(find(relev(:,1)==z1):find(relev(:,1)==z2),1));
% for i = 1:length(names)
%     plot(effstress{i}(find(effstress{i}(:,1)==z2):find(effstress{i}(:,1)==z1),4),effstress{i}(find(effstress{i}(:,1)==z2):find(effstress{i}(:,1)==z1),1));
% end
% set(gca,'YDir','reverse');xlabel('Sz [psi]');ylabel('z [mm]');
% legend(fName,names{:});
% 
% figure;
% hold on
% plot(relev(find(relev(:,1)==z1):find(relev(:,1)==z2),5),relev(find(relev(:,1)==z1):find(relev(:,1)==z2),1));
% for i = 1:length(names)
%     plot(effstress{i}(find(effstress{i}(:,1)==z2):find(effstress{i}(:,1)==z1),5),effstress{i}(find(effstress{i}(:,1)==z2):find(effstress{i}(:,1)==z1),1));
% end
% set(gca,'YDir','reverse');xlabel('Sz/Z [psi/ft]');ylabel('z [mm]');
% legend(fName,names{:});
DeltaTensionesAVG=mean(abs(effstress{:}(2:end-2,2)-effstress{:}(2:end-2,3)))