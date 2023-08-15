function [eFisu, eBarra, Boundary] = datos_celda2estruct(elementsFisu,elementsBarra,nodosBoundary,nX,nY,nZ,Boundary)
% Todas las variables que hay que exportar para el solver y estan guardadas
% en celdas tengo que pasarlas a estructuras con el formato compatible, me
% base en las variables que se suelen exportar, si se agrega alguna
% posteriormente hay que simplemente repetir el patron
%% ELEMENTS FISU
eFisu = struct('ALL',elementsFisu.all);
if islogical(eFisu.ALL.nodes)==0|| islogical(eFisu.ALL.minusNodes)==0
warning('elementsFisu.nodes no es una matrix logica');
end
for i = 1:nX
nombre = ['X' char(num2str(i))];
eFisu = setfield(eFisu,nombre,'index',elementsFisu.index{1,i});
eFisu = setfield(eFisu,nombre,'nodes',cast(elementsFisu.nodes{1,i},'logical'));
eFisu = setfield(eFisu,nombre,'minus',elementsFisu.minus{1,i});
eFisu = setfield(eFisu,nombre,'plus',elementsFisu.plus{1,i});
eFisu = setfield(eFisu,nombre,'minusNodes',cast(elementsFisu.minusNodes{1,i},'logical'));
end
for i = 1:nY
nombre = ['Y' char(num2str(i))];
eFisu = setfield(eFisu,nombre,'index',elementsFisu.index{2,i});
eFisu = setfield(eFisu,nombre,'nodes',cast(elementsFisu.nodes{2,i},'logical'));
eFisu = setfield(eFisu,nombre,'minus',elementsFisu.minus{2,i});
eFisu = setfield(eFisu,nombre,'plus',elementsFisu.plus{2,i});
eFisu = setfield(eFisu,nombre,'minusNodes',cast(elementsFisu.minusNodes{2,i},'logical'));
end
for i = 1:nZ
nombre = ['Z' char(num2str(i))];
eFisu = setfield(eFisu,nombre,'index',elementsFisu.index{3,i});
eFisu = setfield(eFisu,nombre,'nodes',cast(elementsFisu.nodes{3,i},'logical'));
eFisu = setfield(eFisu,nombre,'minus',elementsFisu.minus{3,i});
eFisu = setfield(eFisu,nombre,'plus',elementsFisu.plus{3,i});
eFisu = setfield(eFisu,nombre,'minusNodes',cast(elementsFisu.minusNodes{3,i},'logical'));
end
%% ELEMENTS BARRA
eBarra = struct('ALL', elementsBarra.ALL, 'INT', elementsBarra.INT);
for i = 1:nX
nombre = ['X' char(num2str(i))];
eBarra = setfield(eBarra,nombre,elementsBarra.X{i});
end
for i = 1:nY
nombre = ['Y' char(num2str(i))];
eBarra = setfield(eBarra,nombre,elementsBarra.Y{i});
end
for i = 1:nZ
nombre = ['Z' char(num2str(i))];
eBarra = setfield(eBarra,nombre,elementsBarra.Z{i});
end
%% NODOS BOUNDARY
Boundary = struct('borrar', []);
for i = 1:nX
nombre = ['X' char(num2str(i))];
Boundary = setfield(Boundary,nombre,'all',nodosBoundary.all{1,i});
Boundary = setfield(Boundary,nombre,'sinInt',nodosBoundary.sinInt{1,i});
end
for i = 1:nY
nombre = ['Y' char(num2str(i))];
Boundary = setfield(Boundary,nombre,'all',nodosBoundary.all{2,i});
Boundary = setfield(Boundary,nombre,'sinInt',nodosBoundary.sinInt{2,i});
end
for i = 1:nZ
nombre = ['Z' char(num2str(i))];
Boundary = setfield(Boundary,nombre,'all',nodosBoundary.all{3,i});
Boundary = setfield(Boundary,nombre,'sinInt',nodosBoundary.sinInt{3,i});
end
Boundary = rmfield(Boundary, 'borrar');
Boundary.all = Boundary;
end
