function [otsuMask] = Fun_thresholding(J, mask, scrsz)
    % metoda Otsu
    tOtsu=graythresh(J);
    otsuMask = im2bw(J,tOtsu);
    figure();
    subplot(1,3,1), imshow(J);  xlabel('Obraz oryginalny');
    subplot(1,3,2), imshow(otsuMask);  xlabel('Metoda Otsu');
    subplot(1,3,3), imshow(mask); xlabel('Maska')
    set(gcf,'Position',scrsz);