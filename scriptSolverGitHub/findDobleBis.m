function nod = findDobleBis(dominio, x,y,z1,z2,tol)

%Encuentra todas las coordenadas x y z de un dominio que se encuentran
%a una determinada tolerancia de x,y,z. Devuelve un array booleano de nx1
%cuyos elementos son "true" cuando el @x @y @z que se ingresa esta dentro
%del dominio.

coords = dominio.nodes;

nod = false(size(coords,1),1);
nod(coords(:,1)<x+tol & coords(:,1)>x-tol & coords(:,2)<y+tol & coords(:,2)>y-tol & coords(:,3)<z2+tol & coords(:,3)>z1-tol) = true;

end

