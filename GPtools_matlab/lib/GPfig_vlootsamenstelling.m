function GPfig_vlootsamenstelling(traffic_file, sjabloon, output_file)
% Maak een figuur met de vlootsamenstelling (gp2013, figuur 2.3)
%
% input
%   traffic_file          xls of tab-gescheiden text met minimaal ac_cat en total
%   sjabloon              SVG sjabloon
%   output_file           SVG output
    
    if size(traffic_file,2)==2
        % Lees traffic: ac_cat,	total 
        Trf{1} = read_traffic(traffic_file{1});
        Trf{2} = read_traffic(traffic_file{2});
        n_Trf = 2;
    else
        % Lees traffic: ac_cat,	total 
        Trf{1} = read_traffic(traffic_file);
        n_Trf = 1;
    end

    % Gewichtsklassen en overeenkomende vvc's (regular expression)
    plot.mtow_cat = {'&lt; 6', '6 - 40', '40 - 60', '60 - 160', '160 - 230', '230 - 300',  '&gt; 300'};
    vvc_pattern   = {    '^0',  '^[12]',      '^3',    '^[45]',        '^6',        '^7',     '^[89]'};

    % Agregeer op mtow_cat en maak plot struct
    for k=1:length(vvc_pattern)
        index       = MatchingCells(Trf{1}.ac_cat, vvc_pattern(k)); % zoek vvc's van mtow_cat(k)
        plot.vtb(k) = sum(Trf{1}.total(index));
    end
    
    % Bereken percentage
    plot.percentage = 100 * plot.vtb / sum(plot.vtb);
    
    %indien tweede traffic, herhaal stappen
    if n_Trf==2
        for k=1:length(vvc_pattern)
            index       = MatchingCells(Trf{2}.ac_cat, vvc_pattern(k)); % zoek vvc's van mtow_cat(k)
            plot.vtb2(k) = sum(Trf{2}.total(index));
        end 
        plot.percentage2 = 100 * plot.vtb2 / sum(plot.vtb2);
    end
    
    
    
    % Output naar SVG
    plot2svg(plot, sjabloon, output_file);
end