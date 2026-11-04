
%% Inicjalizacja
clc;    clear;  close all;      scrsz=get(0,'ScreenSize');  scrsz=round([1 1 1 0.88].*scrsz+[0 0.05*scrsz(4) 0 0]);

%% Wczytanie danych obrazowych i pomocniczych
numerObrazu = 1;
J = imread("images\"+numerObrazu+".jpg");
maska = imread("masks\m"+numerObrazu+".png");
J = rgb2gray(J);
[w,k]=size(J);                              % w x k - rozmiary obrazu J
Jmin=min(min(J));    Jmax=max(max(J));      % skrajne wartoœci intensywnoœci w J

%%  progowanie globalne otsu i iteracyjne
% Próg z metody Otsu dla porównania
    tOtsu=graythresh(J);
    disp(['Prog wyznaczony metoda Otsu:       ',int2str((Jmax-Jmin)*tOtsu)]);
% Pierwotna wartoœæ progowa
    told=round(0.5*Jmin+0.5*Jmax);
    Jw=uint8(zeros(w,k));
% Wyœwietlanie t w zerowej iteracji
    subplot(2,3,1), imshow(J);  xlabel('Obraz oryginalny');
    subplot(2,3,4), imshow(Jw,[]);  xlabel('Metoda iteracyjna');
    subplot(2,3,2), imshow(im2bw(J,tOtsu));  xlabel('Metoda Otsu');
    subplot(2,3,3),   imhist(J);    hold on;   bar((Jmax-Jmin)*tOtsu,w*k,'r');  bar(told,w*k,'r');
    subplot(2,3,5), imshow(maska); xlabel('Maska')
    set(gcf,'Position',scrsz);
    pause(1);
% Pêtla g³ówna
    for i=1:1000
        Jw(J>told)=1;
        tb =sum(sum(   Jw .*J))/nnz(  Jw);
        tcz=sum(sum((1-Jw).*J))/nnz(1-Jw);
        tnew=round(0.5*tcz+0.5*tb);
        info=['Iteracja ',int2str(i),'    tstare = ',int2str(told),'    tnowe = ',int2str(tnew)];  disp(info);
% Wyœwietlanie
        subplot(2,3,1), imshow(J);  xlabel('Obraz oryginalny');
        subplot(2,3,4), imshow(Jw,[]);  xlabel('Metoda iteracyjna');
        subplot(2,3,2), imshow(im2bw(J,tOtsu));  xlabel('Metoda Otsu');
        subplot(2,3,3),   imhist(J);    hold on;   bar((Jmax-Jmin)*tOtsu,w*k,'r');  bar(tnew,w*k,'r');
        subplot(2,3,5), imshow(maska); xlabel('Maska')
        set(gcf,'Position',scrsz);
% Warunek koñca
        if (tnew==told)     break;  end
        told=tnew;
        pause(1);
    end
    disp(['Prog wyznaczony metoda iteracyjna: ',int2str(tnew)]);