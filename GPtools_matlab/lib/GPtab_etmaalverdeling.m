function GPtab_etmaalverdeling(traffic, idField, ids, output_file, sheet)
% Exporteer de etmaalverdeling naar Excel van een zomer- en wintertraffic
%
% input
%   traffic          naam van xls of tab-gescheiden text
%                    - cell array met traffic, bijvb. {'winter_traffic.xls', 'zomer_traffc.xls} met minimaal: d_lt,  d_schedule, total
%                    - één traffic met minimaal: 'idField' d_lt,  d_schedule, total
%   idField          veld met de ids van de traffics, bijvb. seizoen
%   ids              als meerdere traffics worden opgegeven zijn dit de ids van de traffics
%   output_file      xls
%   sheet            sheet in de xls

    % Lees traffic
    if iscell(traffic)
        for i=1:numel(ids);
            t(i) = read_traffic(traffic{i});
        end   
        trf = merge_traffic(t, idField, ids);
    elseif ischar(traffic)
        trf = read_traffic(traffic);
    else
        error('unkown variable type for variable traffic')
    end

    % Header
    trf_new = {idField, 'lt', 'schedule', 'den', 'total'};
    
    % Periode toevoegen op basis van de uren in 'schedule'
    den    = {'D'            , 'E'          , 'N'        , 'EM'};
    period = {'0[7-9]|1[0-8]', '19|20|21|22', '23|0[0-5]', '06'};
    trf.hour = cellfun(@(x) x(1:2), trf.schedule, 'UniformOutput', false); % 'HH:MM' -> 'HH'
    for p=1:size(period,2)
        index = MatchingCells(trf.hour, period(p)); 
        traffic_den(index) = den(p);
    end

    % Aggregeer op hele uren
    [unique_trf,pos,invpos] = uniqueRowsCA([trf.(idField) trf.lt trf.hour traffic_den']);

    occurence = unique(invpos);
    for i=1:size(pos,1)
        occurence(i) = sum(trf.total(invpos==occurence(i)));
    end

    % Output cell array
    trf_new = [trf_new; unique_trf num2cell(occurence)];
        
    % Output naar xls
    xlswrite(output_file,trf_new, sheet, 'A1');
end


