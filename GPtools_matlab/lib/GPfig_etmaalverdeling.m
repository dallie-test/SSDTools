function GPfig_etmaalverdeling(traffic_file_winter,traffic_file_zomer, dagen_winter, dagen_zomer, sjabloon, output_file)
% Maak een figuur met de etmaalverdeling van een gemiddelde zomer- en winterdag (gp2013, figuur 2.2)
%
% input
%   traffic_file_winter   xls of tab-gescheiden text met minimaal d_lt,  d_schedule, total
%   traffic_file_zomer    idem voor de zomer
%   dagen_winter          aantal dagen van het winter schedule
%   dagen_zomer           aantal dagen van het zomer schedule
%   sjabloon              SVG sjabloon
%   output_file           SVG output

    % Lees traffic: d_lt, d_schedule, total 
    trf      = read_traffic(traffic_file_zomer);
    trf(2,:) = read_traffic(traffic_file_winter);
    
    % Dagen van de seizoenen
    days = [dagen_zomer, dagen_winter];
    
    % Periode toevoegen op basis van de uren in 'schedule'
    %         {'D'            , 'E'          , 'N'        , 'EM'}
    period  = {'0[7-9]|1[0-8]', '19|20|21|22', '23|0[0-5]', '06'};
    
    direction = { 'T', 'L'};
    
    % Agregeer en maak plot struct
    plot.cat  = {'zomer', 'winter'};
    for s=1:2 % seizoenen: z, w
        trf(s).hour = cellfun(@(x) x(1:2), trf(s).schedule, 'UniformOutput', false); % 'HH:MM' -> 'HH'
        for d=1:2 % direction: T, L
            index1 = strcmp(trf(s).lt, direction(d));
            for p=1:4 % period: d, e, n, em
                index2 = MatchingCells(trf(s).hour, period(p)); 
                plot.(direction{d})(p,s) = sum(trf(s).total(index1 & index2))/days(s);
            end
        end
    end

    % Output naar SVG
    plot2svg(plot, sjabloon, output_file);
end