clc;    clear;  close all;      scrsz=get(0,'ScreenSize');  scrsz=round([1 1 1 0.88].*scrsz+[0 0.05*scrsz(4) 0 0]);
%%
numerObrazu = 1;
RGB = imread("images\"+numerObrazu+".jpg");
maska = imread("masks\m"+numerObrazu+".png");
GRAY = rgb2gray(RGB);                             
J = GRAY; % obraz w zmiennej J bior¹ wszystkie funkcje ni¿ej

%do mode 2
[w, k] = size(J); 
Jd = double(J);
Jmax = max(max(J));

mode = 2;

if(mode == 1) % PROGOWANIE
    %% kana³y rgb
    R = RGB(:, :, 1);
    G = RGB(:, :, 2);
    B = RGB(:, :, 3);
    subplot(2, 2, 1), imshow(RGB), title("obraz rgb")
    subplot(2, 2, 2), imshow(R), title("kana³ R")
    subplot(2, 2, 3), imshow(G), title("kana³ G")
    subplot(2, 2, 4), imshow(B), title("kana³ B")
    %% hsv
    figure();
    [H, S, V] = rgb2hsv(RGB);
    figure
    subplot(2,2,1), imshow(RGB), title('Obraz rgb')
    subplot(2,2,2), imshow(H), title('Odcieñ (H)')
    subplot(2,2,3), imshow(S), title('Nasycenie (S)')
    subplot(2,2,4), imshow(V), title('Jasnoœæ (V)')
    
    J = G;
    Jmin=min(min(J));    Jmax=max(max(J));
    [w,k]=size(J);
    % Próg z metody Otsu dla porównania
        tOtsu=graythresh(J);
        disp(['Prog wyznaczony metoda Otsu:       ',int2str((Jmax-Jmin)*tOtsu)]);
    % Pierwotna wartoœæ progowa
        told=round(0.5*Jmin+0.5*Jmax);
        Jw=uint8(zeros(w,k));
    % Pêtla g³ówna
    figure();
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
end

if(mode == 2) %ROZROST REGIONU
    figure;
    imshow(RGB);
    title('wybór punktu startowego');
    [seed_x, seed_y] = ginput(1);%funkcjê ginput zaproponowa³ chatgpt
    s = [round(seed_y), round(seed_x)]; %wspó³rzêdne s¹ odwrotnie ni¿ indeksowanie macierzy

    kryterium=2; %kryterium = ró¿nica intensywnoœci w stosunku do œredniej intensywnoœci obszaru
    max_dJ=40;               % maksymalna ró¿nica intensywnoœci 
    sasiedztwo=8;           % typ s¹siedztwa

    Jsr2disp=[];                % wektor œrednich intensywnoœci
    l_pix=0;                    % licznik pikseli obiektu
    Jw=false(w,k);              % binarny obraz wynikowy
    maska=false(w,k);           % pomocnicza macierz informuj¹ca czy ju¿ sprawdzono dany piksel
    kolejka=s;                  % wstawienie do kolejki punktu startowego
    Jsr=Jd(s(1),s(2));          % pierwotna (lub jedyna) œrednia intensywnoœæ obiektu
% Wyœwietlenie obrazu oryginalnego ze wskazanym punktem
    figure(1), subplot('Position', [0.04 0.02 0.44 0.96]), imshow(Fun_dispseed(J,s,Jmax));  xlabel('Obraz oryginalny z punktem startowym'); set(gcf,'Position',scrsz);
% Procedura rozrostu obszaru
    while (~isempty(kolejka))                   % pêtla g³ówna (max. 1s)
        c=kolejka(1,:);                         % punkt c ze szczytu kolejki do analizy
        kolejka=kolejka(2:size(kolejka,1),:);   % usuniêcie c z kolejki
        if (~maska(c(1),c(2)))                  % czy punkt nie by³ jeszcze analizowany?
            maska(c(1),c(2))=true;              % odznaczenie punktu c w masce, ...
            if (abs(Jd(c(1),c(2))-Jsr)<=max_dJ) % czy kryterium w³¹czenia jest spe³nione?
                Jw(c(1),c(2))=true;             % w³¹czenie punktu c do obiektu
                sasiedzi=Fun_neighbors(c,w,k,sasiedztwo);       % wyznaczenie indeksów s¹siadów punktu c
                kolejka=[   kolejka;
                            sasiedzi];          % wstawienie s¹siadów do kolejki
                if (kryterium==2)
                    Jsr=(l_pix*Jsr+Jd(c(1),c(2)))/(l_pix+1);    % aktualizacja œredniej intensywnoœci
                    Jsr2disp=[Jsr2disp; Jsr];   % dopisanie do wektora œrednich intensywnoœci
                end
                l_pix=l_pix+1;                  % inkrementacja licznika pikseli
            end
        end
    end
% Wyœwietlanie
    if (kryterium==2)   figure(2);     plot(Jsr2disp);     xlabel('Zmiany sredniej intensywnosci obiektu');    set(gcf,'Position',scrsz);  end
    figure(1), subplot('Position', [0.52 0.02 0.44 0.96]), imshow(Fun_dispedges(J,find(bwperim(imdilate(Jw,strel('disk',1)))),Jmax),[]);   xlabel('Obraz po segmentacji');    set(gcf,'Position',scrsz);
    if (isempty(kolejka))   info=['Liczba pikseli obiektu: ',int2str(l_pix)];
    else                    info='Przekroczony czas. Segmentacja zakonczona niepowodzeniem';
    end        
    disp(info);
end