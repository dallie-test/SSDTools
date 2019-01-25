function [SVGtext] = text2svg(Plot, SVGtag)
% Plot legenda

% Input
%   Plot      Plot structure
%   SVGtag    Tekst van de text-tag
%
% Output
%   SVGtext   SVG text string

NumFields = {'position', 'rotation'};
s=ParseTag(SVGtag, NumFields);


X    = s.position(1);
Y    = s.position(2);
txt = sprintf(s.format, Plot.(s.value));

p = [sprintf('\t<!-- Text -->\n')];
p = [p sprintf('\t<g style="%s"\n\t   transform="rotate(%4.1f %4.1f %4.1f)">\n',s.style, s.rotation, X, Y)];
p = [p sprintf('\t\t<text x="%4.1f"  y="%4.1f">%s</text>\n', X, Y, txt)];
p = [p sprintf('\t</g>\n')];

SVGtext = p;
    