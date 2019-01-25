function [SVG] = scale2svg(Plot, SVGtag)
% Plot viewBox

% Input
%   Plot      Plot structure
%   SVGtag    Tekst van de legenda tag
%
% Output
%   SVG       SVG text

NumFields = {'size', 'height', 'range','label_xoffset', 'label_yoffset'};
s=ParseTag(SVGtag, NumFields);

% -------------------------------------------------------------------------
%viewbox
if strcmp(s.object, 'viewbox')
    SVG = sprintf('\t\tviewBox="%4.1f %4.1f %4.1f %4.1f"', s.size);
end

% -------------------------------------------------------------------------
%schaalbalk
if strcmp(s.object, 'scalebar')

    scale  = Plot.ref.viewbox.size(3)/Plot.(s.id).viewbox.size(3);    
    x      = scale * s.range;
    width  = x(2) - x(1);

    p = '';
    p = [p sprintf('\t\t<!-- schaalbalk -->\n')];
    for i=1:length(x)-1
        if  mod(i,2) == 0
            style = s.style2;
        else
            style = s.style1;
        end
        p = [p sprintf('\t\t<rect width="%3.1f" height="%3.1f" x="%3.1f" y="0" style="%s" />\n', width, s.height, x(i), style)];
    end

    xd = x(end) + 15;
    yd = s.height;
    
    %tekst
     p = [p sprintf('\n\t\t<text  x="%3.1f"  y="%3.1f" style="%s">%s</text>', xd, yd, s.label_style, s.label)];

    SVG = p;
end
    