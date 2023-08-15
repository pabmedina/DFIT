function index = vectors_equal_tol(matrix, vector, tol)
    % Comparar una matriz con un vector y devolver el índice de la fila igual al vector dentro de una tolerancia
    [m, n] = size(matrix);
    if n ~= length(vector)
        error('La matriz debe tener la misma cantidad de columnas que el largo del vector.');
    end
    
    index = -1;  % Valor inicial para indicar que no se encontró una fila igual
    
    for i = 1:m
        if isequal(matrix(i, :), vector)
            index = i;
            return;
        elseif all(abs(matrix(i, :) - vector) <= tol)
            index = i;
        end
    end
    
    if index == -1
        error('No se encontró una fila igual al vector dentro de la tolerancia especificada.');
    end
end

