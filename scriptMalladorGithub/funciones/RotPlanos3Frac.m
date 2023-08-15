function nodesNew = RotPlanos3Frac(nodes, fractura, alpha)
%Si despues armo yo el mallador eliminar esta linea y configurar para
%poner las fracturas equiespaciadas

%%Funcion de puntos fuga
d1 = fractura.posicionX{1,1}/tand(alpha);
last = size(fractura.posicionX,2);
for i = 1:last
    if isempty(fractura.posicionX{1,last})
        last = last-1;
    end
end
d4 = (max(nodes(:,1))-fractura.posicionX{1,last})/tand(alpha);

pF1(:,1) = zeros(1,length(sort(uniquetol(nodes(:,3)))));
pF1(:,2)=-d1+(max(nodes(:,2))+min(nodes(:,2)))/2;
pF1(:,3)=sort(uniquetol(nodes(:,3)));

pF4(:,1) = max(nodes(:,1))*ones(1,length(sort(uniquetol(nodes(:,3)))));
pF4(:,2)=d4+(max(nodes(:,2))+min(nodes(:,2)))/2;
pF4(:,3)=sort(uniquetol(nodes(:,3)));


%% Busco todos los nodos de un mismo plano con normal X
X = sort(uniquetol(nodes(:,1)));
nodesNew = nodes;
%Supongo que los elementos son de igual dimension en X
cte = X(2)-X(1);
for t = 1:length(X)
    x0 = X(t);
    N = find(nodes(:,1)==x0);
    z0 = max(nodes(N,3));
    %% Interpolacion de la coordenada x en funcion al punto fuga y al punto de
    %% la fractura principal que queda constante
    %  Los planos anteriores a la ultima fractura los rota respecto al
    %  primer punto fuga pF1 y los siguientes hasta el final respecto a pF2
    if x0 <= fractura.posicionX{1,1}
        y0 = (max(nodes(N,2))+min(nodes(N,2)))/2;%max(nodes(N,2));
        
        for i = 1:length(N)
            j = N(i);
            nodesNew(j,1)=(x0-pF1(1,1))/(y0-pF1(1,2))*(nodes(j,2)-y0)+nodes(j,1);
%% Descomentar para plotear el desplazamiento de un nodo del plano
%           figure
%           hold on
%           scatter3(nodesNew(N,1),nodesNew(N,2),nodesNew(N,3),'y')
%           scatter3(nodes(N,1),nodes(N,2),nodes(N,3),'b')
%           scatter3(pF1(:,1),pF1(:,2),pF1(:,3),'r')
%           scatter3(x0,y0,z0,'g'); 
%           hold off
        end
        
    elseif fractura.posicionX{1,1}< x0 && x0 <=fractura.posicionX{1,last}
        y0 = (max(nodes(N,2))+min(nodes(N,2)))/2;%max(nodes(N,2));
        pF(1)=0; pF(2)=-x0/tand(alpha)+(max(nodes(:,2))+min(nodes(:,2)))/2;
        for i = 1:length(N)
            j = N(i);
            nodesNew(j,1)=(x0-pF(1))/(y0-pF(2))*(nodes(j,2)-y0)+nodes(j,1);
            %% Descomentar para plotear el desplazamiento de un nodo del plano
%           figure
%           hold on
%           scatter3(nodesNew(N,1),nodesNew(N,2),nodesNew(N,3),'y')
%           scatter3(nodes(N,1),nodes(N,2),nodes(N,3),'b')
%           scatter3(pF1(:,1),pF1(:,2),pF1(:,3),'r')
%           scatter3(x0,y0,z0,'g'); 
%           hold off
        end
    else
        y0 = (max(nodes(N,2))+min(nodes(N,2)))/2;%min(nodes(N,2));
            for i = 1:length(N)
            j = N(i);
            nodesNew(j,1)=(x0-pF4(1,1))/(y0-pF4(1,2))*(nodes(j,2)-y0)+nodes(j,1);
            end

    end
% % Descomentar para plotear el desplazamiento de un plano
%         figure
%         subplot(1,2,1)
%         hold on
%         scatter3(nodes(:,1),nodes(:,2),nodes(:,3),'b')
%         hold off
%         subplot(1,2,2)
%         hold on
%         scatter3(nodesNew(:,1),nodesNew(:,2),nodesNew(:,3),'k')
%         hold off
end
% %Descomentar para graficar la comparacion entre la malla inicial y la final
% figure
% subplot(1,2,1)
% hold on
% scatter3(nodes(:,1),nodes(:,2),nodes(:,3),'b')
% % scatter3(pF1(:,1),pF1(:,2),pF1(:,3),'r')
% % scatter3(pF4(:,1),pF4(:,2),pF4(:,3),'r')
% hold off
% subplot(1,2,2)
% hold on
% scatter3(nodesNew(:,1),nodesNew(:,2),nodesNew(:,3),'k')
% % scatter3(pF1(:,1),pF1(:,2),pF1(:,3),'r')
% % scatter3(pF2(:,1),pF2(:,2),pF2(:,3),'r')
% % scatter3(pF3(:,1),pF3(:,2),pF3(:,3),'r')
% %scatter3(pF4(:,1),pF4(:,2),pF4(:,3),'r')
% hold off
end