function [nodosMuertos,struct] = fcnDeadGathering(struct,nodosMuertos,nodTripleEncuentro)
%No se como simplificar en pocas palabras lo que hace esta funcion. En
%resumidas cuentas hace que si hay un nodo roto este ademas active a todos
%sus nodos rotos vecinos.

nod_id = find(nodTripleEncuentro);
nodDead_id = nodosMuertos;
elementsCohesivos = struct.elements;

deadFlag = struct.deadFlag;

boolC = ismember(nod_id ,nodDead_id);  % boolC va a ser un logico de nx1, siendo n la cantidad de nodos que haya en una interseccion. 
%nod_id(boolC) % me va a dar el ID de los nodos que voy a tener que activar en los cohesivos

boolA = ismember(elementsCohesivos,nod_id(boolC));  
cohesive_id = sum(boolA,2)>0; % me da el id de los elementos cohesivos que voy a tener que activar

deadFlag(cohesive_id,:) = true;
nodosMuertos = [nodosMuertos; unique(elementsCohesivos(cohesive_id,:))' ];

struct.deadFlag = deadFlag;

end

