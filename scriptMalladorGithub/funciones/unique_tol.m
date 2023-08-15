function C = unique_tol(A, tol)
    % Obtener los valores �nicos en A con tolerancia
    C = [];  % Vector para almacenar los valores �nicos
    n = length(A);
    
    % Recorrer los elementos de A
    for i = 1:n
        % Verificar si el valor actual ya est� en C con tolerancia
        is_unique = true;
        for j = 1:length(C)
            if abs(A(i) - C(j)) <= tol
                is_unique = false;
                break;
            end
        end
        
        % Agregar el valor �nico a C si no est� presente
        if is_unique
            C = [C A(i)];
        end
    end
end
