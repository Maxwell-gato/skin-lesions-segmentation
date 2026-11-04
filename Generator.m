%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LABORATORIUM PRZETWARZANIA OBRAZÓW
%%
%% Pawe³ Badura 2009
%% Generator danych .mat dla sekcji
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;    clear;  close all;
sciezka1=['Rys',filesep];       sciezka2=['Mat',filesep];
lsekcji=11;

% punkty wskazuj¹ce struktury do wyodrêbnienia
seeds=[ 262 355     286 238     389 248;
        282 206     109 361     260 60;
        306 252     237 260     216 181;
        291 277     154 240     339 267;
        180 129     19  179     90  62;
        22  61      134 107     184 156;
        58  142     30  98      165 123;
        258 255     118 325     174 398;
        265 230     86  275     111 182;
        188 126     162 108     83  134;
        214 147     418 387     83  228];

for nrsekcji=1:lsekcji
    if (nrsekcji<10)    sciezkain=[sciezka1,'0',int2str(nrsekcji),'.dcm'];
                        sciezkaout=[sciezka2,'0',int2str(nrsekcji),'.mat'];
    else                sciezkain=[sciezka1,int2str(nrsekcji),'.dcm'];
                        sciezkaout=[sciezka2,int2str(nrsekcji),'.mat'];
    end
    J=double(dicomread(sciezkain));
    J=uint8(255*normalizuj_DCM(J,1));
    seed=seeds(nrsekcji,:);
    save(sciezkaout,'J','seed');
end