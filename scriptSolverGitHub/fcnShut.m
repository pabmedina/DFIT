function [flagPreCierre, flagCierre] = fcnShut(flagPreCierre,flagCierre,dN,a,b)
% Funcion que devuelve un booleano  "flagCierre". flagCierre sera de valor
% true si un componente del array "dN" (nxm) esta por debajo de un limite dado por
% el entero "a". 
bool = false(size(dN,1),1);
for i = 1:size(dN,1)
    if any(dN(i,:)>a)
        bool(i) = true;
    end
end

if all(~bool)
    flagPreCierre = true;
end

bool1 = false(size(dN,1),1);
for i = 1:size(dN,1)
    if any(dN(i,:)>b)
        bool1(i) = true;
    end
end

if all(~bool1)
    flagCierre = true;
end
end

