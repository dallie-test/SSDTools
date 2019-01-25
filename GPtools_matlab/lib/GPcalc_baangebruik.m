function [trf_my]=GPcalc_baangebruik(traffic_file, period)
% Aggregeer het baangebruik en bereken gemiddelde, mediaan, min, max en std
%
% input
%   traffic_file  xls of tab-gescheiden text met minimaal d_lt, d_runway, d_period, d_den, d_myear en total
%   period        de periode als regular expression:  bijvoorbeeld 'D|E|N' of 'N'
%
% Output
%    trf_my      Struct met n-tekstvelden en een veld 'vtb' met het aantal
%                vlietuigbewegingen
  
    % Lees traffic: d_lt, d_runway, d_period, d_den, d_myear, total 
    trf = read_traffic(traffic_file);

    % Selecteer de periode
    index1 = MatchingCells(trf.den, period);

    % Agregeer: lt, runway, myear en sommeer total
    keys     = strcat(trf.lt, trf.runway, trf.myear);
    key_list = unique(keys(index1)); % alleen de keys voor 'period'

    trf_new = struct;
    for k=1:length(key_list)
        index2            = strcmp(keys, key_list(k));
        trf_new.lt(k)     = unique(trf.lt(index1 & index2));
        trf_new.runway(k) = unique(trf.runway(index1 & index2));
        trf_new.myear(k)  = unique(trf.myear(index1 & index2));

        trf_new.total(k)  = sum(trf.total(index1 & index2));
    end
    
    % Agregeer op myear en bereken stats
    keys = strcat(trf_new.lt, trf_new.runway);
    key_list = unique(keys);
    Nyears = length(unique(trf_new.myear));
    
    trf_my = struct;
    for k=1:length(key_list)
        index = strcmp(keys, key_list(k));
        trf_my.lt(k)     = unique(trf_new.lt(index));
        trf_my.runway(k) = unique(trf_new.runway(index));
        
        % Zijn alle jaren gevuld?
        total = trf_new.total(index);
        if length(total) < Nyears
            total(end,Nyears) = 0;
        end
        
        total = total;
        
        trf_my.mean(k)  = mean(total);
        trf_my.median(k)= median(total);
        trf_my.std(k)   = std(total);
        trf_my.min(k)   = min(total);
        trf_my.max(k)   = max(total);
    end
end