function [color transp] = SVGrgb(col, dB)
% Interpoleer in col voor de dB-waarde
% Col is een string in het format: 'dB1, col1, transp1; dB2, col2, transp2'
% hierin zijn col1, col2 ... coln kleuren in SVG definitie: '#RRGGBB'

if ~isempty(strfind(col, ';'))
    % parse de kleuren: dB's, kleuren en transparantie
    
    % Bug in textscan in R2006a???
    % Onderstaande textscan werkt wel in de 2012 versie, alternatief werkt wel correct. 
  % List = textscan(col, '%f %s %f', 'delimiter', ',', 'EndOfLine', ';');
    col  = regexprep(col, '\s*,\s*', '\t');
    col  = regexprep(col, '\s*;\s*', '\n');
    
    List = textscan(col, '%f %s %f', 'delimiter', '\t');

    CdB = List{1};
    Ctr = List{3};

    for i=1:length(List{2})
        C.R(i) = hex2dec(List{2}{i}(2:3));
        C.G(i) = hex2dec(List{2}{i}(4:5));
        C.B(i) = hex2dec(List{2}{i}(6:7));
    end

    % RGD-waarde ligt tussen 0 en 255, transparantie tussen 0 en 1
    color = [ '#'...
              dec2hex(round(max(0,min(255,interp1(CdB,C.R,dB,'linear', 'extrap')))),2)...
              dec2hex(round(max(0,min(255,interp1(CdB,C.G,dB,'linear', 'extrap')))),2)...
              dec2hex(round(max(0,min(255,interp1(CdB,C.B,dB,'linear', 'extrap')))),2)];

    transp = max(0,min(1,interp1(CdB,Ctr,dB,'linear', 'extrap')));
elseif ~isempty(strfind(col, ','))

    % parse de kleuren: één kleur en één transparantie
    List = textscan(col, '%s %f', 'delimiter', ',', 'EndOfLine', ';');
    
    color = char(List{1});
    transp = List{2};
elseif strcmp(col, 'none')
    color = 'none';
    transp = 0;     % transparant
else
    color = col;
    transp = 1;     % niet-transparant
end