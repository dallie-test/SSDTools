function [StartDatum] = StartSeizoen(Seizoen, Jaar)
% Bereken de start van het seizoen
% - de zomer(tijd) begint de laatste zondag in maart
% - de winter(tijd) begint de laatste zondag in oktober
%
% Input
%    Seizoen     String: 'zomer' of 'winter'
%    Jaar        Numerieke waarde van het jaar
%
% Output
%    StartDatum  Datum van de start van het seizoen
%
% bron: http://delphiforfun.org/Programs/Math_Topics/DSTCalc.htm
% geldig tussen 1900 en 2099

if strcmp(Seizoen, 'zomer')
    StartDatum = datenum(Jaar,  3, 31 - mod(fix(4 + 5 * Jaar/4), 7));
else
    StartDatum = datenum(Jaar, 10, 31 - mod(fix(1 + 5 * Jaar/4), 7));
end
