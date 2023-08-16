function [meshInfo] = meshVerification(meshInfo)
if isfield(meshInfo,'winkler')
    cprintf('Err','La malla ingresada tiene winklers. Para continuar se remueven automaticamente.\n' )
    cprintf('Err','Se agrega pausa de 10s para lectura de mensaje\n')  
    
    nWinklers      = size(meshInfo.winkler,1);
    meshInfo.nodes = meshInfo.nodes(1:end-nWinklers,:);
    meshInfo       = rmfield(meshInfo,'winkler');
end

end