function fractura = verifyFrac(nodes, fractura,nX,nY,nZ)
Xvalues = unique(nodes(:,1));
Yvalues = unique(nodes(:,2));
Zvalues = unique(nodes(:,3));
for i = 1:nX
    if sum(Xvalues==fractura.posicionX{1,i})>0
    else %reemplazo por el mas cercano
        fractura.posicionX{1,i} = Xvalues(unique(abs(Xvalues-fractura.posicionX{1,i})==min(abs(Xvalues-fractura.posicionX{1,i}))));
        txt = ['La posicion X de la fractura X', num2str(i),' no contiene ningun nodo presente, se modifica por la mas cercana'];
        warning(txt);
    end
end
for i = 1:nY
    if sum(Yvalues==fractura.posicionY{2,i})>0
    else %reemplazo por el mas cercano
        fractura.posicionY{2,i} = Yvalues(unique(abs(Yvalues-fractura.posicionY{2,i})==min(abs(Yvalues-fractura.posicionY{2,i}))));
        txt = ['La posicion Y de la fractura Y', num2str(i),' no contiene ningun nodo presente, se modifica por la mas cercana'];
        warning(txt);
    end
end
for i = 1:nZ
    if sum(Zvalues==fractura.posicionZ{3,i})>0
    else %reemplazo por el mas cercano
        fractura.posicionZ{3,i} = Zvalues(unique(abs(Zvalues-fractura.posicionZ{3,i})==min(abs(Zvalues-fractura.posicionZ{3,i}))));
        txt = ['La posicion Z de la fractura Z', num2str(i),' no contiene ningun nodo presente, se modifica por la mas cercana'];
        warning(txt);
    end
end
end