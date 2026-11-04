global Jd t Jw rA dJ Label01

dJ = round(get(Slider01, 'value'));

Jw = abs(Jd - t) <= dJ;

set(Label01, 'String', [int2str(t),' pm ',int2str(dJ)]);
axes(rA);   imshow(Jw,[]);  xlabel('Obraz po progowaniu');
impoint(rA, px, py);