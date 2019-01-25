%deze functie telt voor een grid of serie grids het gemiddeld aantal
%gehinderden in de 48 dB(A) LDEN contour. 
%
% Created by: Ramon van Schaik
% Created for: Schiphol Group A/CAP/EC
% Date: 25/02/2011  Last update: 25/02/2011
% File name: huizenlnight.m
%
%input:
% - ldengrid: een LDEN dB(A) grid conform de DAISY-standaard. Dit grid dient
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
% - gehinderdenlden: number of highly annoyed people inside the 48 dB(A) Lden contour
%
%LET OP: Persoonsvariabelen worden in deze functie geladen en globaal
%gemaakt. Indien deze functie in een loop geplaatst wordt waarin er veel
%gecleared wordt, kan deze functie erg traag worden omdat hij de
%persoonsbestanden telkens weer moet inladen.

function [gehinderdenlden] = gehinderdenlden(ldengrid,errorhandling)

global outputP NP NentriesP;

%persoonbestanden laden
if (isempty(outputP) || isempty(NP) || isempty(NentriesP))
    load personen;
end

%tel de personen per contourschil
conttocheckP = 48:65;
[personenpercontour,errorflag] = contourtel(ldengrid,conttocheckP,outputP,NP,NentriesP);

%controle op geslotenheid van contouren. Indien niet gesloten krijgt deze
%contour van bovenstaande functie contourtel hier informatie over mee via
%de errorflag.
if errorflag
    if exist('errorhandling','var')~=0
        switch errorhandling
            case {1}
                warning('contour niet gesloten, waarde oneindig gemaakt');
                gehinderdenlden = inf;
            case {2}
                error('contour niet gesloten, berekening afgebroken');
            case {3}
                warning('contour niet gesloten, toch doorgerekend.');
                gehinderdenlden = mean(sum(personenpercontour.*(ones(size(personenpercontour,1),1)*(1-1./(1+exp(-8.1101+(0.1333.*(conttocheckP+0.5)))))),2));
            otherwise
                error('onbekende waarde van errorhandling');
        end
    else
        warning('contour niet gesloten, waarde oneindig gemaakt');
        gehinderdenlden = inf;
    end
else
    gehinderdenlden = mean(sum(personenpercontour.*(ones(size(personenpercontour,1),1)*(1-1./(1+exp(-8.1101+(0.1333.*(conttocheckP+0.5)))))),2));
end