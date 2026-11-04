global Jd t Jw lA rA Label01 dJ px py

p = round(get(lA, 'CurrentPoint'));
px = p(1,1);    py = p(1,2);
if ((py >= 1) && (py <= size(Jd,1)) && (px >= 1) && (px <= size(Jd,2))) 
    t = Jd(py, px);
    Jw = abs(Jd - t) <= dJ;
    axes(lA);   imshow(Jd,[]);  xlabel('Obraz oryginalny');
    impoint(lA, px, py);
    set(Label01, 'String', [int2str(t),' pm ',int2str(dJ)]);
    axes(rA);   imshow(Jw,[]);  xlabel('Obraz po progowaniu');
    impoint(rA, px, py);
end