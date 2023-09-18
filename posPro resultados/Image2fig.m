clc, clear all
imagen = imread('graficoSOLOLimpio.png'); 

canal_rojo = imagen(:,:,1);
canal_verde = imagen(:,:,2);
canal_azul = imagen(:,:,3);


umbral_rojo = 180; 
mascara_roja = (canal_rojo > umbral_rojo) & (canal_verde < umbral_rojo) & (canal_azul < umbral_rojo);

region_roja = imagen;
region_roja(repmat(~mascara_roja,[1 1 3])) = 0; 

imshow(region_roja);




[nFilas, nColumnas] = size(mascara_roja);
posicion_primer_pixel_rojo = zeros(1, nColumnas); 
for col = 1:nColumnas
    columna_actual = mascara_roja(:, col);
    indices_pixeles_rojos = find(columna_actual); 
    if ~isempty(indices_pixeles_rojos)
        posicion_primer_pixel_rojo(col) =size(imagen,1)- indices_pixeles_rojos(1); % Tomar el primer píxel rojo de arriba
    else
        posicion_primer_pixel_rojo(col) = NaN; 
    end
end

subplot(1, 2, 1);
imshow(region_roja);
title('Región Roja');

subplot(1, 2, 2);
plot(posicion_primer_pixel_rojo, 'r.'); 
title('Posiciones del Primer Píxel Rojo en Cada Columna');
xlabel('Columna');
ylabel('Fila del Primer Píxel Rojo');

%% Escalado en Y
escala_minima = 0; 
escala_maxima = 25; 
posicion_escalada_Y = (posicion_primer_pixel_rojo - min(posicion_primer_pixel_rojo)) / (max(posicion_primer_pixel_rojo) - min(posicion_primer_pixel_rojo)) * (escala_maxima - escala_minima) + escala_minima;

posicionX=linspace(0,145,size(posicion_escalada_Y,2));


figure; hold on
for i=1:size(posicion_escalada_Y,2)
    if posicion_escalada_Y(i)>-1
        scatter(posicionX(i),posicion_escalada_Y(i))
    end
end

GdpdgData=[posicionX;posicion_escalada_Y];
