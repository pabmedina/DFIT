function elementsFondo = selectFondoEle(nodes, elements, elementsFondo,n)
elementNodes = elements(elementsFondo,:);
switch n
    case 1
        Xnodes = uniquetol(nodes(elementNodes,1),1e-5);
        for t = 1:length(Xnodes)
            cant = sum(nodes(elementNodes, 1) ==Xnodes(t));
            if cant ==4
                for i = length(elementsFondo):-1:1
                    if sum(nodes(elements(elementsFondo(i,:),:),1)==Xnodes(t))>1
                        elementsFondo(i)=[];
                    end
                end 
            end
        end
    case 2
        Ynodes = uniquetol(nodes(elementNodes,2),1e-5);
        for t = 1:length(Ynodes)
            cant = sum(nodes(elementNodes, 2) ==Ynodes(t));
            if cant ==4
                for i = length(elementsFondo):-1:1
                    if sum(nodes(elements(elementsFondo(i,:),:),2)==Ynodes(t))>1
                        elementsFondo(i)=[];
                    end
                end 
            end
        end
    case 3
        Znodes = uniquetol(nodes(elementNodes,3),1e-5);
        for t = 1:length(Znodes)
            cant = sum(nodes(elementNodes, 3) ==Znodes(t));
            if cant ==4
                for i = length(elementsFondo):-1:1
                    if sum(nodes(elements(elementsFondo(i,:),:),3)==Znodes(t))>1
                        elementsFondo(i)=[];
                    end
                end 
            end
        end
end
end