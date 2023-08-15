function c = testingMesh(A,b)
%Funcion que revisa si los elementos del array b esta dentro del array A.
% c es un vector booleano que indica con true el index del elemento b que
% no esta dentro de A.

c = false(size(b,1),1);
b = 1:1:size(b,1);
d = ismember(b,A);

c(~d) = true;
end

