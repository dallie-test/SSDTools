function [SVG] = contour2svg(Plot, SVGtag)
% Maak een contouren-plot op basis van het opgegeven sjabloon
%
% Input
%   SVGtag     Text uit het SVG sjabloon van de te plotten contouren
%
% Output
%   SVG        Te maken SVG-bestand


NumFields = {'dB'};
s=ParseTag(SVGtag, NumFields);
if ~isfield(s, 'method')
    s.method = 'matlab';
end

% Bereken contourpunten
grd.dat = Plot.(s.grid);
grd.hdr = Plot.hdr;
contouren = ContourPunten(grd, s.dB, s.method);

% Tweede grid bij een hilo-plot
if strcmp(s.type, 'hilo')
    grd2.dat = Plot.(s.grid2);
    grd2.hdr = Plot.hdr;
    contouren2 = ContourPunten(grd2, s.dB, s.method);
end

% Tekstje voor in de SVG
if strcmp(s.type, 'hilo')
    grid_id = [s.grid '/' s.grid2];
else
    grid_id = s.grid;    
end
    
% Loop langs alle contourwaarden
p = '';
dBn = length(s.dB);
for dBi = 1:dBn
    dB1 = s.dB(dBi);
    
    % Bereken voor een flood- en delta-plot een schil tussen twee contourwaarden
    if dBi < dBn && (strcmp(s.type, 'flood') || strcmp(s.type, 'delta'))
        dBi2 = dBi+1;
        dB2  = s.dB(dBi2);
        contours = [contouren{dBi} contouren{dBi2}];
    else
        dB2 = dB1;
        contours = contouren{dBi};
    end
    
    % Tweede grid bij een hilo-plot
    if strcmp(s.type, 'hilo')
        contours = [contours contouren2{dBi}];
    end

    % Interpoleer voor de kleur en transparantie
    [Scol Stransp] = SVGrgb(s.stroke, (dB1+dB2)/2);
    [Fcol Ftransp] = SVGrgb(s.fill,   (dB1+dB2)/2);

    p = [p sprintf('\t<path id="%s %4.1f"\n', grid_id, dB1)];
    p = [p sprintf('\t      style="%s;stroke:%s;fill:%s;stroke-opacity:%4.2f;fill-opacity:%4.2f"\n', s.style, Scol, Fcol, Stransp, Ftransp)];
    p = [p SVGpath(contours)];
end

SVG = p;