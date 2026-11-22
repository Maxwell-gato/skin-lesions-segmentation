clc;    clear;  close all;      scrsz=get(0,'ScreenSize');  scrsz=round([1 1 1 0.88].*scrsz+[0 0.05*scrsz(4) 0 0]);
%%
numerObrazu = 2;
RGB = imread("images\"+numerObrazu+".jpg");
mask = imread("masks\m"+numerObrazu+".png");
J = rgb2gray(RGB);

%% kana�y rgb i hsv
R = RGB(:, :, 1);
G = RGB(:, :, 2);
B = RGB(:, :, 3);
subplot(2, 2, 1), imshow(RGB), title("obraz rgb")
subplot(2, 2, 2), imshow(R), title("kana� R")
subplot(2, 2, 3), imshow(G), title("kana� G")
subplot(2, 2, 4), imshow(B), title("kana� B")
%{
figure();
[H, S, V] = rgb2hsv(RGB);
subplot(2,2,1), imshow(RGB), title('Obraz rgb')
subplot(2,2,2), imshow(H), title('Odcie� (H)')
subplot(2,2,3), imshow(S), title('Nasycenie (S)')
subplot(2,2,4), imshow(V), title('Jasno�� (V)')
%}
pause();
%%
otsuMask = Fun_thresholding(J, mask, scrsz); % PROGOWANIE OTSU TODO - usunicie malych element�w
similarity = dice(logical(otsuMask), logical(mask));
disp("warto�� Dice progowania otsu: "+ similarity)
pause();
%%
J = im2gray(imfuse(G, B));

max_dJ = 7; %TODO - suwak w gui
regionMask = Fun_region_growth(J, mask, max_dJ, RGB, scrsz); % ROZROST REGIONU
similarity = dice(logical(regionMask), logical(mask));
disp("warto�� Dice rozrostu regionu: "+ similarity)
%%
