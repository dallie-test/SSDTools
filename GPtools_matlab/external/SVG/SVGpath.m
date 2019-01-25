function [SVGtext] = SVGpath(contours)
% Haal coördinaten uit de contouren en geef SVG text terug

% Input
%   contours  het resultaat van de functie 'contourc'
%
% Output
%   SVGtext   d="m x y x y ... z"/>

SVGtext = sprintf('\td="\n');

% Loop langs sub-contouren
i = 1;
while i <= length(contours)
    % dBi = contours(1,i);    % contour dB(A)-waarde
    n = contours(2,i);        % aantal punten
    XY = contours(:,i+1:i+n); % de coordinaten

    % Maak de string
    SVGtext = [SVGtext sprintf('\tM %s Z\n', sprintf('%2.0f,%2.0f ',XY))];

    i = i+n+1;
end

SVGtext = [SVGtext sprintf('\t"/>\n')]; 