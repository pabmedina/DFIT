function A = normalConstraintsDFN(A,nodosBoundary)
%Funcion que categoriza las filas del array A(nxm). 
%Agrega una columna del tipo dobule: que puede ser '1', '2', '3'

a1 = nodosBoundary.X1.sinInt;
% a2 = nodosBoundary.X2.sinInt;
% a3 = nodosBoundary.X3.sinInt;
b = nodosBoundary.Y1.sinInt;
c1 = nodosBoundary.Z1.sinInt;
% c2 = nodosBoundary.Z2.sinInt;
% c3 = nodosBoundary.Z3.sinInt;
% c4 = nodosBoundary.Z4.sinInt;
% c5 = nodosBoundary.Z5.sinInt;
% c6 = nodosBoundary.Z6.sinInt;


boolA1 = ismember(A,a1);
for i = 1:size(boolA1,2)
    sumCol = sum(boolA1(:,i));
    if sumCol>0
        whichColA1 = i;
    end
end
A(boolA1(:,whichColA1),6) = 1;


% boolA2 = ismember(A,a2);
% for i = 1:size(boolA2,2)
%     sumCol = sum(boolA2(:,i));
%     if sumCol>0
%         whichColA2 = i;
%     end
% end
% A(boolA2(:,whichColA2),6) = 1;
% 
% 
% boolA3 = ismember(A,a3);
% for i = 1:size(boolA3,2)
%     sumCol = sum(boolA3(:,i));
%     if sumCol>0
%         whichColA3 = i;
%     end
% end
% A(boolA3(:,whichColA3),6) = 1;

boolB = ismember(A,b);
for i = 1:size(boolB,2)
    sumCol = sum(boolB(:,i));
    if sumCol>0
        whichColB = i;
    end
end
A(boolB(:,whichColB),6) = 2;

boolC1 = ismember(A,c1);
for i = 1:size(boolC1,2)
    sumCol = sum(boolC1(:,i));
    if sumCol>0
        whichColC1 = i;
    end
end
A(boolC1(:,whichColC1),6) = 3;


% boolC2 = ismember(A,c2);
% for i = 1:size(boolC2,2)
%     sumCol = sum(boolC2(:,i));
%     if sumCol>0
%         whichColC2 = i;
%     end
% end
% A(boolC2(:,whichColC2),6) = 3;
% 
% 
% boolC3 = ismember(A,c3);
% for i = 1:size(boolC3,2)
%     sumCol = sum(boolC3(:,i));
%     if sumCol>0
%         whichColC3 = i;
%     end
% end
% A(boolC3(:,whichColC3),6) = 3;
% 
% 
% boolC4 = ismember(A,c4);
% for i = 1:size(boolC4,2)
%     sumCol = sum(boolC4(:,i));
%     if sumCol>0
%         whichColC4 = i;
%     end
% end
% A(boolC4(:,whichColC4),6) = 3;
% 
% 
% boolC5 = ismember(A,c5);
% for i = 1:size(boolC5,2)
%     sumCol = sum(boolC5(:,i));
%     if sumCol>0
%         whichColC5 = i;
%     end
% end
% A(boolC5(:,whichColC5),6) = 3;
% 
% 
% boolC6 = ismember(A,c6);
% for i = 1:size(boolC6,2)
%     sumCol = sum(boolC6(:,i));
%     if sumCol>0
%         whichColC6 = i;
%     end
% end
% A(boolC6(:,whichColC6),6) = 3;
end

