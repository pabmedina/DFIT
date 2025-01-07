function [mean_field_1, mean_field_2] = mean_nodal_field(paramDiscEle,times,meshInfo,nodal_field_1,nodal_field_2,key)
% Funcion que promedia un campo discreto interpolado. En los nodos en
% comun, de dos o mas elementos, se promedia el campo que cada uno de los
% elementos tiene. 
% El input "key" se usa para determinar el tamaño del array que se va a
% promediar. Ej: si son tensiones este array promediado tiene que ser de 6,
% si el campo a promediar es un flujo o una velocidad, entonces el array va
% a ser de 3.

if strcmp(key,'on')
    mean_field_1 = zeros(paramDiscEle.nDofTot_P,6,times);
    mean_field_2 = zeros(paramDiscEle.nDofTot_P,6,times);
else
    mean_field_1 = zeros(paramDiscEle.nDofTot_P,3,times);
    mean_field_2 = zeros(paramDiscEle.nDofTot_P,3,times);
end
for itime = 1:1:times
    for inode = 1:paramDiscEle.nDofTot_P
        [I,J] = find(meshInfo.elements == inode);
        nShare = length(I);
        for ishare = 1:nShare
            if strcmp(key,'on')
                mean_field_1(inode,:,itime) = mean_field_1(inode,:,itime) + squeeze(nodal_field_1(I(ishare),J(ishare),:,itime))';
                mean_field_2(inode,:,itime) = mean_field_2(inode,:,itime) + squeeze(nodal_field_2(I(ishare),J(ishare),:,itime))';
            else
                mean_field_1(inode,:,itime) = mean_field_1(inode,:,itime) + squeeze(nodal_field_1(I(ishare),J(ishare),:,itime))';
            end
        end
        if strcmp(key,'on')
            mean_field_1(inode,:,itime) = mean_field_1(inode,:,itime) / nShare;
            mean_field_2(inode,:,itime) = mean_field_2(inode,:,itime) / nShare;
        else
            mean_field_1(inode,:,itime) = mean_field_1(inode,:,itime) / nShare;
            
        end
    end
end
end

