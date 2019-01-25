function GPtab_baangebruik(traffic_file, period, output_file, sheet)
% Exporteer het baangebruik naar Excel
%
% input
%   traffic_file     xls of tab-gescheiden text met minimaal d_lt, d_runway, d_period, d_den, d_myear en total
%   output_file      xls
%   sheet            sheet in de xlsfunction TabelBaangebruik(traffic_file, output_file, night)
    

    % Lees traffic en bereken stats
    trf_my = GPcalc_baangebruik(traffic_file, period);

    % Sorteer vector op 'mean' voor Landingen en Starts afzonderlijk
    key = [trf_my.mean(strcmp(trf_my.lt, 'L')), trf_my.mean(strcmp(trf_my.lt, 'T'))-1000000];
    [v, index] = sort(key, 'descend');

    % Output naar xls
    hdr = {'lt', 'runway', 'min', 'max', 'std', 'median', 'mean'};
    dat = [trf_my.lt; trf_my.runway; num2cell(trf_my.min); num2cell(trf_my.max); num2cell(trf_my.std); num2cell(trf_my.median); num2cell(trf_my.mean)];
    
    xlswrite(output_file,[hdr; dat(:,index)'], sheet, 'A1');
end