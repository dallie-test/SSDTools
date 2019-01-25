function plot2svg(Plot, SVGin, SVGout)
% Maak een contourenplot op basis van het opgegeven sjabloon
%
% Input
%   Plot_struct   Multigrid struct ... TODO beschrijving toevoegen
%   SVGin         SVG sjabloon
%   SVGout        Te maken SVG-bestand of
%                 output directory (laatste char '\')
%                 filenaam wordt SVGin met 'svg' als extentie


% Lees SVG sjabloon
SVG = fileread(SVGin);

% Maak een style-struct obv het sjabloon
Tags=regexp(SVG,'<plot\s?(.*?)\s?/>','tokens');

% Conversie van numerieke velden
NumFields = {'size','width', 'radius', 'height', 'dB', 'range', 'gap', 'label_offset','label_xoffset','label_yoffset', 'label_rotation', 'decimals', 'bar_width'};

for i=1:size(Tags,2)
    s=ParseTag(Tags{i}{:}, NumFields);
    object=s.object;
    id=s.id;
    s=rmfield(s, {'object', 'id'});
    Plot.(id).(object)=s;
end

% -------------------------------------------------------------------------
% plot_area
SVG=regexprep(SVG,'\s?<plot\s*?(object="plot_area".*?)/>','${graph2svg(Plot, $1)}');

% plot_axis
SVG=regexprep(SVG,'\s?<plot\s*?(object="[xy]_axis".*?)/>','${graph2svg(Plot, $1)}');

% bar_plot
SVG=regexprep(SVG,'\s?<plot\s*?(object="bar_plot[0-9]".*?)/>','${graph2svg(Plot, $1)}');

% polar_bar_plot
SVG=regexprep(SVG,'\s?<plot\s*?(object="polar_bar_plot[0-9]".*?)/>','${graph2svg(Plot, $1)}');

% xy_plot
SVG=regexprep(SVG,'\s?<plot\s*?(object="xy_plot[0-9]".*?)/>','${graph2svg(Plot, $1)}');

% density_plot
SVG=regexprep(SVG,'\s?<plot\s*?(object="density_plot[0-9]".*?)/>','${graph2svg(Plot, $1)}');

% -------------------------------------------------------------------------
% contouren
SVG=regexprep(SVG,'\s?<plot\s*?(object="contour_plot".*?)/>','${contour2svg(Plot, $1)}');

% schaalbalk
SVG=regexprep(SVG,'\s?<plot\s*?(object="viewbox".*?)/>','${scale2svg(Plot, $1)}');
SVG=regexprep(SVG,'\s?<plot\s*?(object="scalebar".*?)/>','${scale2svg(Plot, $1)}');

% Plot de legenda
SVG=regexprep(SVG,'\s?<plot\s*?(object="floodbar".*?)/>','${legend2svg(Plot, $1)}');

%TODO Test of de viewbox (als deze niet start met 0,0) correct wordt geaccepteerd in indesign.
%     Zie de versie van de repository van circa 18 juli 2012

% -------------------------------------------------------------------------
% text
SVG=regexprep(SVG,'\s?<plot\s*?(object="text".*?)/>','${text2svg(Plot, $1)}');

% -------------------------------------------------------------------------
% Aanmaken nieuwe SVG
% Is SVGout een directorynaam: SVGout = SVGin met extentie 'svg'
if isdir(SVGout)
    if ~strcmp(SVGout(end),'\')
        SVGout = [SVGout '\'];
    end
    [dirname, filename, extension] = fileparts(SVGin);
    SVGout = strcat(SVGout, filename, '.svg');
end

% dlmwrite blijkt super traag te zijn, onderstaande alternatief is veel
% sneller.
% dlmwrite(SVGout, SVG, 'delimiter', '');
fid = fopen( SVGout, 'w' );
fprintf( fid, '%s\n', SVG);
fclose( fid );

