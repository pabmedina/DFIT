function A = normalConstraintsDFITHardCodeado(A,nodosBoundary)
%Funcion que categoriza las filas del array A(nxm). 
%Agrega una columna del tipo dobule: que puede ser '1', '2', '3'


b = nodosBoundary.Y.sinInt;




boolB = ismember(A,b);

for i = 1:size(boolB,2)
    sumCol = sum(boolB(:,i));
    if sumCol>0
        whichColB = i;
    end
end
A(boolB(:,whichColB),6) = 2;


end

