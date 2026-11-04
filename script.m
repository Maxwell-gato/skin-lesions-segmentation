
%% Inicjalizacja
clc;    clear;  close all;      scrsz=get(0,'ScreenSize');  scrsz=round([1 1 1 0.88].*scrsz+[0 0.05*scrsz(4) 0 0]);

%%%%%%%%     NUMER ZADANIA     %%%%%%%%
zadanie=3;    %2.5 - 75~80

%% Wczytanie danych obrazowych i pomocniczych

J = imread("images\8.jpg");
maska = imread("masks\m8.png");
J = rgb2gray(J);
[w,k]=size(J);                              % w x k - rozmiary obrazu J
Jmin=min(min(J));    Jmax=max(max(J));      % skrajne wartoœci intensywnoœci w J

%%  Zadanie 1. Binaryzacja                                         
if (zadanie==1)

% próg
t = 140;
Jw=zeros(w,k);
Jw = J > t;
% Wyœwietlanie
    subplot(2,2,1), imshow(J);  xlabel('Obraz oryginalny'); 
    subplot(2,2,2), imshow(Jw,[]);  xlabel('Obraz po binaryzacji');
    subplot(2,2,3),   imhist(J);    hold on;    bar(t,w*k,'r');
    subplot(2,2,4), imshow(maska); xlabel('Maska') 
    set(gcf,'Position',scrsz);
end

%%  Zadanie 2. Progowanie 
if (zadanie==2)
   
% progi
    t=round([   70;
                140;
                ]);

    Jw=zeros(w,k);
    for i=1:size(t,1)
        Jw(J>t(i))=i;
    end
% Wyœwietlanie
    subplot(2,2,1), imshow(J);  xlabel('Obraz oryginalny'); 
    subplot(2,2,2), imshow(Jw,[]);  xlabel('Obraz po progowaniu wielokryterialnym');
    subplot(2,2,3),   imhist(J);    hold on;   for i=1:size(t,1)   bar(t(i),w*k,'r');  end
    subplot(2,2,4), imshow(maska); xlabel('Maska')
    set(gcf,'Position',scrsz);
end

%%  Zadanie 2.5. Progowanie wielokryterialne
if (zadanie==2.5)
    global Jd t Jw lA rA dJ px py Label01

    Jw=zeros(w,k);
    py = round(w/2);
    px = round(k/2);
    Jd = double(J);
    t = Jd(py, px);
    dJ = 0;

% Wyœwietlanie
    fH = figure(1);
    Slider01 = uicontrol('Style', 'slider',...
            'Min', 0,...
            'Max',256,...
            'Value', dJ,...
            'SliderStep', [1/256, 10/256],...
            'Units', 'normalized',...
            'Position', [0.49 0.2 0.02 0.6],...
            'Callback', 'Fun_Slider01_Callback');
    Label01 = uicontrol('Style', 'text',...
            'String', [int2str(t),' pm ',int2str(dJ)],...
            'FontSize', 14,...
            'Units', 'normalized',...
            'HorizontalAlignment', 'center',...
            'BackgroundColor', get(gcf, 'Color'),...
            'Position', [0.46 0.83 0.08 0.04]);
    set(gcf, 'WindowButtonDownFcn', 'Fun_lA_Callback');
    lA = subplot(1,2,1,...
                'ButtonDownFcn', 'Fun_lA_Callback');
%     hold on;
    imshow(Jd,[]);  xlabel('Obraz oryginalny'); 
    impoint(lA, px, py);
    rA = subplot(1,2,2);
    imshow(Jw,[]);  xlabel('Obraz po progowaniu wielokryterialnym');
    impoint(rA, px, py);
    set(gcf,'Position',scrsz);
end

%%  Zadanie 3. Progowanie globalne - metoda iteracyjna
if (zadanie==3)
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
end

%%  Zadanie 4. Progowanie lokalne met. Bernsena
if (zadanie==4)

    r=80;           % szerokoœæ okna
    l=90;           % minimalny kontrast
    wariant=1;      % wariant obrazu

    uzupelnianie=true;              % co zrobiæ z fragmentami po prawej i z do³u?
    if (wariant==2)
        J=imread('02_EKG.bmp');     % Ÿród³o (negatyw): http://www.medcitynews.com/index.php/2009/08/most-americans-skeptical-about-health-care-reform-thomson-reuters-survay-says-medcity-morning-read-aug-25-2009/normal-ekg/
        [w,k]=size(J);  Jmin=min(min(J));    Jmax=max(max(J));
    end
    Jw=zeros(w,k);  t=zeros(w,k);   C=zeros(w,k);
    dr=0.5*(r-1);   x0=dr+1;    y0=dr+1;
    lw=ceil(w/r);  rw=mod(w,r);  
    lk=ceil(k/r);  rk=mod(k,r);
    tOtsu=(Jmax-Jmin)*graythresh(J);
    for i=1:lw
        y=y0+(i-1)*r;
        upper = y-dr;
        if (i < lw) || (~rw)    lower = y+dr;   % dolny indeks kwadratu
        else
            if (uzupelnianie)   lower = w;
            else                break;
            end
        end    
        for j=1:lk
            x=x0+(j-1)*r;
            left = x-dr;
            if (j < lk) || (~rk)    right = x+dr;   % dolny indeks kwadratu
            else
                if (uzupelnianie)   right = k;
                else                break;
                end
            end    
            Jxy=J(upper:lower,left:right);
            M=max(max(Jxy));
            m=min(min(Jxy));
            txy=0.5*M+0.5*m;    Cxy=M-m;
            t(upper:lower,left:right)=txy;     C(upper:lower,left:right)=Cxy;
            if (wariant==1)
                if      (Cxy>l)                 Jwxy=zeros(size(Jxy));  Jwxy(Jxy>txy)=1;
                elseif  (txy>tOtsu)             Jwxy=ones(size(Jxy));
                else                            Jwxy=zeros(size(Jxy));
                end
            else
                if      (Cxy>l)                 Jwxy=zeros(size(Jxy));  Jwxy(Jxy<txy)=1;
                elseif  (txy<tOtsu)             Jwxy=ones(size(Jxy));
                else                            Jwxy=zeros(size(Jxy));
                end
            end
            Jw(upper:lower,left:right)=Jwxy;
        end
    end
% Wyœwietlanie
    subplot(2,3,1), imshow(J);  xlabel('Obraz oryginalny');
    subplot(2,3,3), imshow(t,[Jmin Jmax]);  xlabel('Obraz progów t(x,y)');
    subplot(2,3,2), imshow(C,[Jmin Jmax]);  xlabel('Obraz kontrastów C(x,y)');
    subplot(2,3,4), imshow(Jw);  xlabel('Obraz po progowaniu');  set(gcf,'Position',scrsz);
    subplot(2,3,5), imshow(maska); xlabel('Maska')
end

%%  Zadanie 5. Progowanie adaptacyjne - metoda Bernsena

if (zadanie==5)

    r=150;           % szerokoœæ okna
    l=80;           % minimalny kontrast
    wariant=1;      % wariant obrazu

    if (wariant==2)
        J=imread('02_EKG.bmp');     % Ÿród³o (negatyw): http://www.medcitynews.com/index.php/2009/08/most-americans-skeptical-about-health-care-reform-thomson-reuters-survay-says-medcity-morning-read-aug-25-2009/normal-ekg/
        [w,k]=size(J);  Jmin=min(min(J));    Jmax=max(max(J));
    end
    Jw=zeros(w,k);  t=zeros(w,k);
    MAX=ordfilt2(J,r*r,ones(r),'symmetric');    MIN=ordfilt2(J,1,ones(r),'symmetric');
    t=0.5*MAX+0.5*MIN;  C=MAX-MIN;
    tOtsu=(Jmax-Jmin)*graythresh(J);
    if (wariant==1)
        Jw(J>t)=1;
        Jw(C<l & J<=tOtsu)=0;
    else
        Jw(J<t)=1;
        Jw(C<l & J>=tOtsu)=0;
    end
% Wyœwietlanie
    subplot(2,3,1), imshow(J);  xlabel('Obraz oryginalny');
    subplot(2,3,3), imshow(t,[Jmin Jmax]);  xlabel('Obraz progów t(x,y)');
    subplot(2,3,2), imshow(C,[Jmin Jmax]);  xlabel('Obraz kontrastów C(x,y)');
    subplot(2,3,4), imshow(Jw);  xlabel('Obraz po progowaniu');  set(gcf,'Position',scrsz);
    subplot(2,3,5), imshow(maska); xlabel('Maska')
end