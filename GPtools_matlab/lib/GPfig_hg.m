function GPfig_hg(Trf, MHG, Sjabloon, OutputFile)
% Maak een figuur met de etmaalverdeling van een gemiddelde zomer- en winterdag (gp2013, figuur 2.2)
%
% input
%   Trf                        Struct met Traffic
%   MHG                        MHG-waarde gebruikt in percentage berekening 
%   Sjabloon                   SVG sjabloon
%   OutputFile                 SVG output
%
%   TODO: test uitvoer in dB's
%         in de monitoringsrapportage worden alleen % gebruikt

    % Maanden op de x-as
    n = 12;
    plot.months    = {'nov' 'dec' 'jan' 'feb' 'mrt' 'apr' 'mei' 'jun' 'jul' 'aug' 'sep' 'okt'};

    % Vul volledige struct, data kan een gedeelte vullen
    plot.HGlin     = zeros(1,n);
    plot.HG        = zeros(1,n);   
    plot.som_HGlin = zeros(2,n); 
    plot.som_HG    = zeros(2,n); 
    
    % Agregeer per maand maak plot struct
    for i=1:n
        ibin = strcmp(Trf.Maand, plot.months(i));
        
        if ~sum(ibin)==0
            % per maand
            plot.HGlin(i) = sum(Trf.hg(ibin));
            plot.HG(i)    = 10*log10(plot.HGlin(i));

            % cumulatief
            plot.som_HGlin(1,i) = plot.HGlin(i);
            plot.som_HG(1,i)    = plot.HG(i);

            if i>1
                plot.som_HGlin(2,i) = plot.som_HGlin(1,i-1) + plot.som_HGlin(2,i-1);
                plot.som_HG(2,i)    = 10*log10(plot.som_HGlin(2,i)/plot.HGlin(i));
            end
        end
    end
    
    % Bereken percentage tov MHG
    plot.som_HGp = 100.*plot.som_HGlin./10^(MHG/10);
    
    % Output naar SVG
    plot2svg(plot, Sjabloon, OutputFile);
end