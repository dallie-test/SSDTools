% Function that is used by fzero to scale the grid to the
% equivalence criterion (#gehinderden inside 48 dB(A) Lden contour).
%
% Created by: Ed Gordijn
% Date: 18/04/2013  Last update: 18/04/2013
%
%input:
% - multiplier: scale factor (given by fzero)
% - gridlden: Lden grid [dB(A)]
% - opencontourerror: error handling when contour intersects with boundary of grid (1=inf, 2=error, 3=warning).
%
%output:
% - zerosearch: difference with the limit of the equivalence criteria.


function zerosearch = geschaaldeTellingenGehinderdenLden(multiplier, gridlden, opencontourerror)
    % Gelijkwaarigheidsnorm
    %limit = 239500;
    limit = 180000; % correctie empirisch model
    
    % Scale the grid by the multiplier (i.e. the amount of aircraft movements is scaled in the same amount as the number in the multilpier).
    gridlden = 10.*log10(multiplier.*(10.^(gridlden./10)));
    
    % Count
    count = gehinderdenlden(gridlden, opencontourerror);
    
    % Calculate the difference between the limit of the equivalence criterion and amount of counted houses.
    zerosearch = count - limit;
end