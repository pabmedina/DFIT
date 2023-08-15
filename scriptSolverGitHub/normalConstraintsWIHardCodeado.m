function A = normalConstraintsWIHardCodeado(A,nodosBoundary)
%Funcion que categoriza las filas del array A(nxm). 
%Agrega una columna del tipo dobule: que puede ser '1', '2', '3'

a = nodosBoundary.Y1.sinInt;
b = nodosBoundary.Z1.sinInt;
c = nodosBoundary.Z2.sinInt;
d = nodosBoundary.Z3.sinInt;
e = nodosBoundary.Z4.sinInt;
f = nodosBoundary.Z5.sinInt;
g = nodosBoundary.Z6.sinInt;

boolA = ismember(A,a);

for i = 1:size(boolA,2)
    sumCol = sum(boolA(:,i));
    if sumCol>0
        whichColA = i;
    end
end

A(boolA(:,whichColA),6) = 2;

boolB = ismember(A,b);

for i = 1:size(boolB,2)
    sumCol = sum(boolB(:,i));
    if sumCol>0
        whichColB = i;
    end
end
A(boolB(:,whichColB),6) = 3;

boolC = ismember(A,c);

for i = 1:size(boolC,2)
    sumCol = sum(boolC(:,i));
    if sumCol>0
        whichColC = i;
    end
end
A(boolC(:,whichColC),6) = 3;

boolD = ismember(A,d);

for i = 1:size(boolD,2)
    sumCol = sum(boolD(:,i));
    if sumCol>0
        whichColD = i;
    end
end
A(boolD(:,whichColD),6) = 3;

boolE = ismember(A,e);

for i = 1:size(boolE,2)
    sumCol = sum(boolE(:,i));
    if sumCol>0
        whichColE = i;
    end
end
A(boolE(:,whichColE),6) = 3;

boolF = ismember(A,f);

for i = 1:size(boolF,2)
    sumCol = sum(boolF(:,i));
    if sumCol>0
        whichColF = i;
    end
end
A(boolF(:,whichColF),6) = 3;

boolG = ismember(A,g);

for i = 1:size(boolG,2)
    sumCol = sum(boolG(:,i));
    if sumCol>0
        whichColG = i;
    end
end
A(boolG(:,whichColG),6) = 3;

end

