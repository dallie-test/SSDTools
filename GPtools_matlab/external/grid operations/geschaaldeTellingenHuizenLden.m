% Function that is used by fzero to scale the grid to the most critical
% equivalence criterion (#houses inside 58 dB(A) Lden contour).
%
% Created by: Constantijn Neeteson
% Created for: Schiphol Group A/CAP/EC
% Date: 28/06/2011  Last update: 18/04/2013
% File name: geschaaldeTellingenHuizenLden.m
%
%input:
% - multiplier: scale factor (given by fzero)
% - gridlden: Lden grid [dB(A)]
% - opencontourerror: error handling when contour intersects with boundary of grid (1=inf, 2=error, 3=warning).
%
%output:
% - zerosearch: difference between the number of houses Lden in the scaled grid and the houses Lden limit of the equivalence criteria.


function zerosearch = geschaaldeTellingenHuizenLden(multiplier, gridlden, opencontourerror)
    % Gelijkwaarigheidsnorm
    % limit = 12300;
    limit = 12200; % correctie van het empirisch model

    % Scale the grid by the multiplier (i.e. the amount of aircraft movements is scaled in the same amount as the number in the multilpier).
    gridlden = 10.*log10(multiplier.*(10.^(gridlden./10)));
    
    % Count the houses inside the 58 dB(A) Lden contour
    alltelhouses = huizenlden(gridlden, opencontourerror);
    
    % Calculate the difference between the limit of the equivalence criterion and amount of counted houses.
    zerosearch = alltelhouses - limit;
end