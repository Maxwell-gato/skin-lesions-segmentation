function [a] = lDice(metoda, maska)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    metoda
    maska
end

arguments (Output)
    a
end
    maska = imbinarize(maska);
    a = dice(metoda, maska);

end