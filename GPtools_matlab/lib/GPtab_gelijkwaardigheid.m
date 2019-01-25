function GPtab_gelijkwaardigheid(gwc, output_file, sheet)
% Exporteer de gelijkwaardigheid resultaten naar Excel
%
% input
%   gwc              struct met tellingen
%   output_file      xls
%   sheet            sheet in de xls

    % Header
    out = {'year', 'w58den', 'eh48den', 'w48n', 'sv40n'};
    
    if isfield(gwc, 'my') % prognose
        % Incl. meteotoeslag
        years = [num2str(gwc.myears(1)) '-' num2str(gwc.myears(end)) 'mm'];
        out = [out; years, num2cell(gwc.w58den), num2cell(gwc.eh48den), num2cell(gwc.w48n), num2cell(gwc.sv40n)];

        % Excl. meteotoeslag
        out = [out; num2cell(gwc.myears), num2cell(gwc.my.w58den), num2cell(gwc.my.eh48den), num2cell(gwc.my.w48n), num2cell(gwc.my.sv40n)];
    else
        % Realisatie
        out = [out; num2cell(gwc.myears), num2cell(gwc.w58den), num2cell(gwc.eh48den), num2cell(gwc.w48n), num2cell(gwc.sv40n)];
    end
    
    % Output naar xls
    xlswrite(output_file,out , sheet, 'A1');
end


