%deze functie telt voor een grid of serie grids het aantal huizen binnen 
%de 58 dB(A) LDEN contour.
%
% Created by: Ramon van Schaik
% Created for: Schiphol Group A/CAP/EC
% Date: 25/02/2011  Last update: 25/02/2011
% File name: huizenlden.m
%
%input:
% - ldengrid: een LDEN dB(A) grid conform de DAISY-standaard. Dit grid dient
%   de volgende afmetingen te hebben: 
%   de volgende afmetingen te hebben: 
%   X-ONDER     84000
%   X-BOVEN    155000
%   X-STAP       500
%   NX       143
%   Y-ONDER    455000
%   Y-BOVEN    526000
%   Y-STAP       500
%   NY       143
% - een waarde voor errorhandling. Dit bepaald welke waarde gehinderdenlden krijgt indien de
%   contour niet gesloten is. errorhandling mag de volgende waardes hebben:
%   errorhandling=1 => gehinderdenlden=inf (DEFAULT SETTING)
%   errorhandling=2 => geef error, stop programma.
%   errorhandling=3 => gehinderdenlden wordt gewoon geteld, waarbij wordt gedaan 
%   alsof contour gesloten is. Resultaat dient met voorzichtigheid te worden
%   geinterpreteerd.
%
%   tevens dienen bepaalde subfuncties, alsmede een personenbestand, in de
%   current directory te staan.
%
%output:
% - huizenlden: number of houses inside the 58 dB(A) Lden contour
%
%LET OP: Woningvariabelen worden in deze functie geladen en globaal
%gemaakt. Indien deze functie in een loop geplaatst wordt waarna er veel
%gecleared wordt, kan deze functie erg traag worden omdat hij de
%woningbestanden telkens weer moet inladen.

function [huizenlden] = huizenlden(ldengrid,errorhandling)

global outputW NW NentriesW;

%woningbestanden laden
if (isempty(outputW) || isempty(NW) || isempty(NentriesW))
    load woningen;
end

%tel de huizen per contourschil
[huizenpercontour,errorflag] = contourtel(ldengrid,58,outputW,NW,NentriesW);

%controle op geslotenheid van contouren. Indien niet gesloten krijgt deze
%contour van bovenstaande functie contourtel een negatieve waarde.
if errorflag
    if exist('errorhandling','var')~=0
        switch errorhandling
            case {1}
                warning('contour niet gesloten, waarde oneindig gemaakt');
                huizenlden = inf;
            case {2}
                error('contour niet gesloten, berekening afgebroken');
            case {3}
                warning('contour niet gesloten, toch doorgerekend.');
                huizenlden = mean(huizenpercontour);
            otherwise
                error('onbekende waarde van errorhandling');
        end
    else
        warning('contour niet gesloten, waarde oneindig gemaakt');
        huizenlden = inf;
    end
else
    huizenlden = mean(huizenpercontour);
end

end