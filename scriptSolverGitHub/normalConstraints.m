function A = normalConstraints(A,nodosBoundary)
%Funcion que categoriza las filas del array A(nxm). 
%Agrega una columna del tipo dobule: que puede ser '1', '2', '3'

a = nodosBoundary.X1.sinInt;
b = nodosBoundary.Y1.sinInt;
c = nodosBoundary.Z1.sinInt;

boolA = ismember(A,a);

for i = 1:size(boolA,2)
    sumCol = sum(boolA(:,i));
    if sumCol>0
        whichColA = i;
    end
end

A(boolA(:,whichColA),6) = 1;

boolB = ismember(A,b);

for i = 1:size(boolB,2)
    sumCol = sum(boolB(:,i));
    if sumCol>0
        whichColB = i;
    end
end
A(boolB(:,whichColB),6) = 2;

boolC = ismember(A,c);

for i = 1:size(boolC,2)
    sumCol = sum(boolC(:,i));
    if sumCol>0
        whichColC = i;
    end
end
A(boolC(:,whichColC),6) = 3;
end

