function vecInMatrix(b,A)
% b is an array of nx1
% A is an array of pxm
% bool is logical, 1 if all the values of b are in A and 0 if any value of
% b is not in A.

[boolVec, ~] = ismember(b,A);
bool = all(boolVec);

if ~bool
    nodesError = b(~boolVec);
    if length(nodesError) == 1
        str = num2str(nodesError);
        msg = ['El nodo ', str, ' NO pertenece a la matriz de conectividad'];
        msgFile(msg)
        error('El nodo %d NO pertenece a la matriz de conectividad', nodesError)
    else
        str = sprintf('-%d',vec);
        str = str(2:end);
        msg = ['El nodo ', str, ' NO pertenece a la matriz de conectividad'];
        msgFile(msg)
        error('Los nodos %s NO pertenecen a la matriz de conectividad', str)
    end
end
end

