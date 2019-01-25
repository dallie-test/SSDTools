function s = Duizendtallen(Nummer, Decimalen, Decimaalteken, Scheidingsteken)
% Zet getallen om naar tekst in Nederlandse opmaak. 
% Aantal decimalen, decimaalteken en Scheidingsteken voor duizendtallen
% zijn optioneel te wijzigen.
%
% Input
%   Nummer           Een numerieke waarde 
%   Decimalen        [optioneel] Integer met aantal decimalen, default is 0
%                                negatief getal voor afronden op tientallen, honderdtallen etc.
%   Decimaalteken    [optioneel] Een char met het decimaalteken, default is ','
%   Scheidingsteken  [optioneel] Een char met het scheidingsteken dat wordt
%                                gebruikt voor duizendtallen, default is '.'
%

%Zet defaults voor ontbrekende parameters
if(nargin < 2), Decimalen       = 0;    end
if(nargin < 3), Decimaalteken   = ',';  end
if(nargin < 4), Scheidingsteken = '.';  end

% Definieer java objecten
nf  = java.text.DecimalFormat;
dfs = java.text.DecimalFormatSymbols(java.util.Locale('nl'));

% Wijzig het scheidingsteken voor duizendtallen en het decimaalteken
if strcmp(Scheidingsteken, '')
    nf.setGroupingUsed(false);
else
    dfs.setGroupingSeparator(Scheidingsteken)
end
dfs.setDecimalSeparator(Decimaalteken)
nf.setDecimalFormatSymbols(dfs)

% Afronding
if(Decimalen < 0)
    Nummer = round(Nummer*10^Decimalen)*10^-Decimalen;
    Decimalen = 0;
end
nf.setMaximumFractionDigits(Decimalen)
nf.setMinimumFractionDigits(Decimalen)

s = char(nf.format(Nummer));
