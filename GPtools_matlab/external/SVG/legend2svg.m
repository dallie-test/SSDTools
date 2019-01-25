function [SVGtext] = legend2svg(Plot, SVGtag)
% Plot legenda

% Input
%   Plot      Plot structure
%   SVGtag    Tekst van de legenda tag
%
% Output
%   SVGtext   d="m x y x y ... z"/>

NumFields = {'width', 'height', 'range', 'labels'};
s=ParseTag(SVGtag, NumFields);

dBn  = length(s.range)-1;
Hbar = s.height * 0.9;
dX   = s.width;
dY   = Hbar / dBn;
X0   = dX/2;
Y0   = s.height - (s.height-Hbar)/2;

% Kleurenbalk
XYo=[X0, Y0];
p = '';
p = [p sprintf('\t<!-- Floodbar -->\n')];
p = [p sprintf('\t<g style="%s">\n',s.style)];
for dBi = 1:dBn
    dB1 = s.range(dBi);
    dB2 = s.range(dBi+1);
    
    XYrel = [XYo; dX,0; 0,-dY; -dX,0; 0,dY]';

    % Interpoleer voor de kleur en transparantie
    [Scol Stransp] = SVGrgb(Plot.(s.id).contour_plot.stroke, (dB1+dB2)/2);
    [Fcol Ftransp] = SVGrgb(Plot.(s.id).contour_plot.fill,   (dB1+dB2)/2);
    
    p = [p sprintf('\t\t<path id="%4.1f"', dB1)];
    p = [p sprintf(' style="stroke:%s;fill:%s;stroke-opacity:%4.2f;fill-opacity:%4.2f"', Scol, Fcol, Stransp, Ftransp)];
    p = [p sprintf(' d="m %s z"/>\n', sprintf('%4.1f,%4.1f ',XYrel))];

    XYo(2) = XYo(2)- dY;
end
p = [p sprintf('\t</g>\n\n')];

% Tick-marks
dBn = length(s.labels);
X1 = zeros(1,dBn)+(dX/2);
X2 = X1+dX*1.1;
Y = Y0 - (s.labels-s.range(1)).*(Hbar/(s.range(end)-s.range(1)));

p = [p sprintf('\t<!-- Tick-marks -->\n')];
p = [p sprintf('\t<g style="%s">\n',s.tic_style)];
p = [p sprintf('\t\t<line x1="%3.1f" y1="%3.1f" x2="%3.1f" y2="%3.1f"/>\n',[X1; Y; X2; Y])];
p = [p sprintf('\t</g>\n\n')];

% Legenda tekst
X = X1+dX*1.2;

p = [p sprintf('\t<!-- Labels -->\n')];
p = [p sprintf('\t<g style="%s">\n',s.label_style)];
p = [p sprintf('\t\t<text x="%4.1f"  y="%4.1f">%2.0f dB(A)</text>\n', [X; Y; s.labels])];
p = [p sprintf('\t</g>\n')];

SVGtext = p;
    