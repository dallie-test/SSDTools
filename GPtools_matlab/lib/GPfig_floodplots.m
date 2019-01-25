function GPfig_floodplots(Lden_multigrid, SVGin, SVGout)
% Wrapper voor plot2svg, maakt meerdere plots
%
% input
%  Lden_multigrid   TODO beschrijving toevoegen
%  SVGin            Eén (ischar) of meerdere SVG sjablonen als cell array 
%  SVGout           output directory (ischar) of een cell array met
%                   filenamen

if ischar(SVGin)
    plot2svg(Lden_multigrid, SVGin, SVGout);
else
    nSVGin  = size(SVGin,1); 
    for i=1:nSVGin
        if ischar(SVGout)
            plot2svg(Lden_multigrid, SVGin{i}, SVGout);
        else
            plot2svg(Lden_multigrid, SVGin{i}, SVGout{i});
        end
    end
end