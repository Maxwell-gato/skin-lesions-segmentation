clc;    clear;  close all;      scrsz=get(0,'ScreenSize');  scrsz=round([1 1 1 0.88].*scrsz+[0 0.05*scrsz(4) 0 0]);
%%
numerObrazu = 3;
RGB = imread("images\"+numerObrazu+".jpg");
mask = imread("masks\m"+numerObrazu+".png");
GRAY = rgb2gray(RGB);                             
J = GRAY; % obraz w zmiennej J biorą wszystkie funkcje niżej

%do mode 2
[w, k] = size(J); 
Jd = double(J);
Jmax = max(max(J));

mode = 2;

if(mode == 1) % PROGOWANIE
    %% kanały rgb
    R = RGB(:, :, 1);
    G = RGB(:, :, 2);
    B = RGB(:, :, 3);
    subplot(2, 2, 1), imshow(RGB), title("obraz rgb")
    subplot(2, 2, 2), imshow(R), title("kanał R")
    subplot(2, 2, 3), imshow(G), title("kanał G")
    subplot(2, 2, 4), imshow(B), title("kanał B")
    %% hsv
    figure();
    [H, S, V] = rgb2hsv(RGB);
    figure
    subplot(2,2,1), imshow(RGB), title('Obraz rgb')
    subplot(2,2,2), imshow(H), title('Odcień (H)')
    subplot(2,2,3), imshow(S), title('Nasycenie (S)')
    subplot(2,2,4), imshow(V), title('Jasność (V)')
    
    J = G;
    Jmin=min(min(J));    Jmax=max(max(J));
    [w,k]=size(J);
    % Próg z metody Otsu dla porównania
        tOtsu=graythresh(J);
        disp(['Prog wyznaczony metoda Otsu:       ',int2str((Jmax-Jmin)*tOtsu)]);
    % Pierwotna wartość progowa
        told=round(0.5*Jmin+0.5*Jmax);
        Jw=uint8(zeros(w,k));
    % Pętla główna
    figure();
        for i=1:1000
            Jw(J>told)=1;
            tb =sum(sum(   Jw .*J))/nnz(  Jw);
            tcz=sum(sum((1-Jw).*J))/nnz(1-Jw);
            tnew=round(0.5*tcz+0.5*tb);
            info=['Iteracja ',int2str(i),'    tstare = ',int2str(told),'    tnowe = ',int2str(tnew)];  disp(info);
    % Wyświetlanie
            subplot(2,3,1), imshow(J);  xlabel('Obraz oryginalny');
            subplot(2,3,4), imshow(Jw,[]);  xlabel('Metoda iteracyjna');
            subplot(2,3,2), imshow(im2bw(J,tOtsu));  xlabel('Metoda Otsu');
            subplot(2,3,3),   imhist(J);    hold on;   bar((Jmax-Jmin)*tOtsu,w*k,'r');  bar(tnew,w*k,'r');
            subplot(2,3,5), imshow(mask); xlabel('Maska')
            set(gcf,'Position',scrsz);
    % Warunek końca
            if (tnew==told)     break;  end
            told=tnew;
            pause(1);
        end
        disp(['Prog wyznaczony metoda iteracyjna: ',int2str(tnew)]);
end

if(mode == 2) %ROZROST REGIONU
    figure;
    imshow(RGB);
    title('wybór punktu startowego');
    [seed_x, seed_y] = ginput(1);
    s = [round(seed_y), round(seed_x)]; %współrzędne są odwrotnie niż indeksowanie macierzy

    kryterium=2; %kryterium = różnica intensywności w stosunku do średniej intensywności obszaru
    max_dJ=20;               % maksymalna różnica intensywności 
    sasiedztwo=8;           % typ sąsiedztwa

    Jsr2disp=[];                % wektor średnich intensywności
    l_pix=0;                    % licznik pikseli obiektu
    Jw=false(w,k);              % binarny obraz wynikowy
    maska=false(w,k);           % pomocnicza macierz informująca czy już sprawdzono dany piksel
    kolejka=s;                  % wstawienie do kolejki punktu startowego
    Jsr=Jd(s(1),s(2));          % pierwotna (lub jedyna) średnia intensywność obiektu
% Wyświetlenie obrazu oryginalnego ze wskazanym punktem
    figure(1), subplot('Position', [0.04 0.02 0.44 0.96]), imshow(Fun_dispseed(J,s,Jmax));  xlabel('Obraz oryginalny z punktem startowym'); set(gcf,'Position',scrsz);
% Procedura rozrostu obszaru
    while (~isempty(kolejka))                   % pętla główna (max. 1s)
        c=kolejka(1,:);                         % punkt c ze szczytu kolejki do analizy
        kolejka=kolejka(2:size(kolejka,1),:);   % usunięcie c z kolejki
        if (~maska(c(1),c(2)))                  % czy punkt nie był jeszcze analizowany?
            maska(c(1),c(2))=true;              % odznaczenie punktu c w masce, ...
            if (abs(Jd(c(1),c(2))-Jsr)<=max_dJ) % czy kryterium włączenia jest spełnione?
                Jw(c(1),c(2))=true;             % włączenie punktu c do obiektu
                sasiedzi=Fun_neighbors(c,w,k,sasiedztwo);       % wyznaczenie indeksów sąsiadów punktu c
                kolejka=[   kolejka;
                            sasiedzi];          % wstawienie sąsiadów do kolejki
                if (kryterium==2)
                    Jsr=(l_pix*Jsr+Jd(c(1),c(2)))/(l_pix+1);    % aktualizacja średniej intensywności
                    Jsr2disp=[Jsr2disp; Jsr];   % dopisanie do wektora średnich intensywności
                end
                l_pix=l_pix+1;                  % inkrementacja licznika pikseli
            end
        end
    end
% Wyświetlanie
    if (kryterium==2)   figure(2);     plot(Jsr2disp);     xlabel('Zmiany sredniej intensywnosci obiektu');    set(gcf,'Position',scrsz);  end
    figure(1), subplot(1,2,1), imshow(Fun_dispedges(J,find(bwperim(imdilate(Jw,strel('disk',1)))),Jmax),[]);   xlabel('Obraz po segmentacji');    set(gcf,'Position',scrsz);
    subplot (1, 2, 2), imshow(mask); xlabel('maska')
    if (isempty(kolejka))   info=['Liczba pikseli obiektu: ',int2str(l_pix)];
    else                    info='Przekroczony czas. Segmentacja zakonczona niepowodzeniem';
    end        
    disp(info);
end
