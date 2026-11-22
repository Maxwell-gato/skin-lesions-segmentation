function [Jw] = Fun_region_growth(J, mask, max_dJ, RGB, scrsz)

[w, k] = size(J); 
Jd = double(J);
Jmax = max(max(J));

    f = figure();
    imshow(RGB);
    title('wybór punktu startowego');
    [seed_x, seed_y] = ginput(1);
    s = [round(seed_y), round(seed_x)]; %współrzędne są odwrotnie niż indeksowanie macierzy
    close(f);
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
                kolejka=[kolejka; sasiedzi];          % wstawienie sąsiadów do kolejki
                Jsr=(l_pix*Jsr+Jd(c(1),c(2)))/(l_pix+1);    % aktualizacja średniej intensywności
                Jsr2disp=[Jsr2disp; Jsr];   % dopisanie do wektora średnich intensywności
                l_pix=l_pix+1;                  % inkrementacja licznika pikseli
            end
        end
    end
% Wyświetlanie
    figure(1), subplot(1,2,1), imshow(Fun_dispedges(J,find(bwperim(imdilate(Jw,strel('disk',1)))),Jmax),[]);   xlabel('Obraz po segmentacji');    set(gcf,'Position',scrsz);
    subplot (1, 2, 2), imshow(mask); xlabel('maska')
    if (isempty(kolejka))   info=['Liczba pikseli obiektu: ',int2str(l_pix)];
    else                    info='Przekroczony czas. Segmentacja zakonczona niepowodzeniem';
    end        
    disp(info);

Jw = not(Jw);