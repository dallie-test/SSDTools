function GPtab_preferenties(traffic, conversion_file, xls_output, sheet)
% Exporteer vtb's per preferentie naar Excel
%
% input
%   traffic          xls of tab-gescheiden text met minimaal d_combination,  d_schedule, total
%   conversion_file  tabel met preferentie per baancombinatie
%   xls_output       xls
%   sheet            sheet in de xls

    % Traffic
    trf = read_traffic(traffic);
    
    if isempty(trf.combination)
        warning(['No runway combinations found in traffic file ''' traffic '''. This is normal if this is an empirical study.'])
        return;
    end

    % Preferentietabel kiezen (modus): dag of nacht
    Ntrf = MatchingCells(trf.schedule,'23|0[0-5]');
    trf.modus(Ntrf,1)  = {'N'};
    trf.modus(~Ntrf,1) = {'D'};
    
    % Tabel met preferenties met index voor dag of nacht
    tab  = read_text(conversion_file);
    Ntab = strcmp(tab.period,'N');
    
    % Zoek de preferentie op in 'tab'; nacht heeft een aparte tabel
    for i=1:length(trf.combination),
        % Nacht of etmaaltabel
        if Ntrf(i)
            index = Ntab;
        else
            index = ~Ntab;
        end
        
        match = tab.preference(strcmp(tab.combination, trf.combination(i)) & index);
        if ~isempty(match)
            trf.preference(i,1) = match;
        else 
            trf.preference(i,1) = {'-'};
            % debug
            disp(['Warning! Runway combination not defined in the conversion tabel: ', 'period: ', trf.den{i}, ' - ', trf.combination{i}]);
        end
    end
    
    % Agregeer het traffic
    [unique_trf,pos,invpos] = uniqueRowsCA([trf.modus, trf.preference, trf.combination]);

    for i=1:length(unique_trf)
        total(i,1) = sum(trf.total(invpos==i));
    end
    xls_dat = [unique_trf num2cell(total)];

    % Output naar xls
    xls_hdr = {'modus', 'preference', 'combination', 'total'};
    xlswrite(xls_output, [xls_hdr; xls_dat], sheet, 'A1');
