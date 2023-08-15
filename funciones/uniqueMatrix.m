function uniqueMatrix(mat)
% mat is a matrix of mxn
% bool is 1 if mat has all unique values or the only repeted value is 0
% bool is 0 if mat has any repeted value except zero

contador = histcounts(mat, max(max(mat))+1);
countRep = nonzeros(contador);
zeroVal = ismember(0, mat);


if zeroVal && any(countRep(2:end) > 1)
    vecVal = 0:max(max(mat));
    repeted = vecVal(logical(contador));
    if length(repeted) == 1
        str = num2str(repeted);
        msg = ['El nodo ', str, ' NO pertenece a la matriz de conectividad'];
        msgFile(msg)
        error('El nodo %d se repite en la matriz de constraintRelations', repeted)
    else
        str = sprintf('-%d',repeted);
        str = str(2:end);
        msg = ['El nodo ', str, ' NO pertenece a la matriz de conectividad'];
        msgFile(msg)
        error('Los nodos %s se repiten en la matriz de constraintRelations', str)
    end
end

end

