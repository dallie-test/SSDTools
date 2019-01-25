function [SVGtext] = SVGpath_format(col, dB)
% Maak path format string voor flood2SVG

[color transp] = SVGrgb(col, dB);

% maak SVGtekst
SVGtext = sprintf('\n\t<!-- Contour %4.1f dB(A) -->\n',dB);
SVGtext= [SVGtext sprintf('\t<path style="fill:%s;fill-opacity:%4.2f;fill-rule:evenodd;stroke:none"\n',color, transp)];
