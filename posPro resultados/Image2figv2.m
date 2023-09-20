clc, clear all, close all
imagen = imread('GraficodpdgVerde.png'); 

canal_rojo = imagen(:,:,1);
canal_verde = imagen(:,:,2);
canal_azul = imagen(:,:,3);


umbral_verde = 150; 
% umbral_rojo = 50;
% umbral_azul = 50;
mascara_verde = (canal_verde > umbral_verde) & (canal_rojo < umbral_verde) & (canal_azul < umbral_verde);

region_verde = imagen;
region_verde(repmat(~mascara_verde,[1 1 3])) = 0; 

imshow(region_verde);




[nFilas, nColumnas] = size(mascara_verde);
posicion_primer_pixel_verde = zeros(1, nColumnas); 
for col = 1:nColumnas
    columna_actual = mascara_verde(:, col);
    indices_pixeles_verdes = find(columna_actual); 
    if ~isempty(indices_pixeles_verdes)
        posicion_primer_pixel_verde(col) =size(imagen,1)- indices_pixeles_verdes(1); % Tomar el primer píxel verde de arriba
    else
        posicion_primer_pixel_verde(col) = NaN; 
    end
end

subplot(1, 2, 1);
imshow(region_verde);
title('Región Roja');

subplot(1, 2, 2);
plot(posicion_primer_pixel_verde, 'r.'); 
title('Posiciones del Primer Píxel verde en Cada Columna');
xlabel('Columna');
ylabel('Fila del Primer Píxel verde');

%% Escalado en Y
escala_minima = 0; 
escala_maxima = 25; 
posicion_escalada_Y = (posicion_primer_pixel_verde - min(posicion_primer_pixel_verde)) / (max(posicion_primer_pixel_verde) - min(posicion_primer_pixel_verde)) * (escala_maxima - escala_minima) + escala_minima;

posicionX=linspace(0,145,size(posicion_escalada_Y,2));


figure; hold on

Gfunction3v2
for i=1:size(posicion_escalada_Y,2)
    if posicion_escalada_Y(i)>-1
        scatter(posicionX(i),posicion_escalada_Y(i),'g')
    end
end

% GdpdgData=[posicionX;posicion_escalada_Y];

