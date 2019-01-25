function GPfig_historisch_perspectief(xls_file, prognose, sjabloon, output_file)
% Maak een figuur met de prognose en de realisatie van de afgelopen jaren(gp2013, figuur 2.1 en 5.3/5.6 )
%
% input
%   xls_file      xls met history: year, waarde1, waarde2, waarde3 ...
%   prognose      struct met prognose: year, waarde1, waarde2, waarde3 ...
%                 als een 'waarde' een array is dan wordt met gemiddelde,
%                 mediaan, min en max berekend en is die te plotten als:
%                 <waarde>_mean, _median, _min, _max
%   sjabloon      SVG sjabloon, je plot de <waarde> door de naam op te
%                 geven. De naam is in de xls de kolomnaam en in een struct
%                 de fieldname.
%   output_file   SVG output

    
    % Prognose
    f=fields(prognose);
    for i=1:numel(f)
        % bij een array statistiek toevoegen
        if size(prognose.(f{i}),1) == 1 
            plot.(['prognosis_' f{i}]) = prognose.(f{i});
        else
            plot.(['prognosis_' f{i} '_mean'])   = mean(prognose.(f{i}));
            plot.(['prognosis_' f{i} '_median']) = median(prognose.(f{i}));
            plot.(['prognosis_' f{i} '_min'])    = min(prognose.(f{i}));
            plot.(['prognosis_' f{i} '_max'])    = max(prognose.(f{i}));
        end
    end
    fp = cellfun(@(x) x(11:end), fields(plot), 'UniformOutput', false);
    
    % Lees historische data
    history = read_traffic(xls_file, {'year', 'verkeer', 'w58den', 'eh48den', 'w48n', 'sv40n'});
    
    % Historie
    fh=fields(history);
    for i=1:numel(fh)
        plot.(['history_' fh{i}]) = history.(fh{i});

        % de realisatie is het laatste punt van de history
        plot.(['realisation_' fh{i}]) = history.(fh{i})(end);
        
        % gebied tussen historie en prognose
        if isfield(prognose, fh{i})
            f = MatchingCells(fp, [fh{i} '.*'], 'match'); % dus ook mean, median, min en max
            for j=1:numel(f)
                plot.(['fill_' f{j}]) = [history.(fh{i})(end), plot.(['prognosis_' f{j}])];
            end
        end
    end
    
    % Output naar SVG
    plot2svg(plot, sjabloon, output_file);
end