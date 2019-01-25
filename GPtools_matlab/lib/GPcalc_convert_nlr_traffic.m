function [OutFile1, OutFile2] = GPcalc_convert_nlr_traffic(TrafficFile, CorrectionFile, JaarInfo, Filter)
% convert NLR traffic from input_filename to export_filename
%
% input
%   TrafficFile     naam van het NLR traffic; verplichte velden zijn: Datum en Tijd (LT)
%   CorrectionFile  xls of tab-gescheiden tekst met correctiefactoren per maand
%   JaarInfo        struct met jaarinfo, zie GPcalc_gebruiksjaar
%   Filter          struct met aggregatie en optioneel Filter (field en values), bijvoorbeeld:
%                   Filter.aggregation = {'filter' 'seizoen' 'd_schedule' 'd_lt' 'd_runway' 'd_route' 'ac_cat'};
%                   Filter.field  = 'Nature';
%                   Filter.values = {'FC','FF','FL','FP','PC','PF','PL','PP'};
%                   Filter.result = {'HV','GA'};
%
% output
%   OutFile1      naam van de traffic file voor filter.result{1}
%   OutFile2      naam van de traffic file voor filter.result{2}
%
%                 tab-gescheiden tekst, de naam is deze gelijk aan Trafficfile met de toevoeging
%                 '_Filter.result'

% Defaults
%TODO defaults?


%% Lees TrafficFile (let op: xlsx gaat niet goed!)
disp('... lees traffic');
trf = read_traffic(TrafficFile);
trfLines = numel(trf.Datum);
corr = read_traffic(CorrectionFile, {'Correctie'}, 'Corr');

%% Van datum en tijd naar maanden en uur
disp('... verwerk datum/tijd');
[datum,~,i] = unique(trf.Datum);            % unique data
[y, m, d] = datevec(datum, 'dd-mm-yyyy');

Dnum = datenum(y,m,d);                      % numerieke waarde
Dstr = datestr(Dnum, 'yyyymmdd');           % string, maar dan in het
                                            % gewenste format
                                
M = m(i);                                   % vul de complete array
datum = Dnum(i);
trf.Datum = cellstr(Dstr(i,:));

maand = {'jan'; 'feb'; 'mrt'; 'apr'; 'mei'; 'jun'; 'jul'; 'aug'; 'sep'; 'okt'; 'nov'; 'dec'};
trf.Maand = maand(M);
[tijd,~,i] = unique(regexprep(trf.TijdLT,':..$', '')); % verwijder de seconden
[~, ~, ~, hh, mm] = datevec(tijd, 'HH:MM');

HH = hh(i);                                            % vul de complete array

% Aggregeer de tijd default op uren
iSchedule = find(MatchingCells(Filter.aggregation, 'd_schedule.*'));

if ~isempty(iSchedule)
    tSpec = textscan(Filter.aggregation{iSchedule}, '%10s:%1s%n'); % bijvb: d_schedule:h of d_schedule:m10
    tStr = cellstr(num2str(hh, '%02d'));                           % default alleen uren
    if strcmpi(tSpec{2}, 'm')      
        if ~isempty(tSpec{3})                                      % aggregeren op n-minuten?
            mm = floor(mm/tSpec{3})*tSpec{3};
        end
        tStr = strcat(tStr, cellstr(num2str(mm, ':%02d')));        % hh:mm, bijvoorbeeld 02:10
    end
    trf.d_schedule = tStr(i);                                      % vul de complete array
    Filter.aggregation{iSchedule} = 'd_schedule';                  % verwijder format string
end

%% Callsign prefix?
iCallsign = find(strcmp(Filter.aggregation, 'Callsign:3'));

if ~isempty(iCallsign)
    trf.Callsign = cellfun(@(x) x(1:3), trf.Callsign, 'UniformOutput', false); 
    Filter.aggregation{iCallsign} = 'Callsign'; % verwijder format string
    
%     %test Leisureverkeer
%     iLeisure = ismember(trf.Callsign, {'TRA', 'TFL', 'CND', 'CAI'});
%     trf.segment(~iLeisure) = {'1'};
%     trf.segment(iLeisure)  = {'5'};
end

%% Sector toevoegen?
iSector = find(MatchingCells(Filter.aggregation, 'sector.*'));

if ~isempty(iSector)
    disp('... sector toevoegen obv route');
    tab_file = Filter.aggregation{iSector}(8:end);   % bijvb: sector:RouteSector.txt
    tab = read_traffic(tab_file);                    % lees conversie file
            
    [route,~,r] = unique(trf.Route);                 % unique data
    [gevonden, i] = ismember(route, tab.route); 
    sector(gevonden)  = tab.sector(i(gevonden));
    sector(~gevonden) = {'onbekend'};                % onbekende routes
    trf.sector = sector(r);                          % vul volledige traffic
        
    if ~isempty(route(~gevonden))                    % raporteer onbekende routes
        disp('    onbekende routes:');
        fprintf('    ''%s''\n', route{~gevonden});
    end
    Filter.aggregation{iSector} = 'sector';          % verwijder format string
end

%% Seizoen
seizoen = {'winter'; 'zomer'};
zomer = datum>=JaarInfo.zomer.begin & datum<=JaarInfo.zomer.eind;
trf.seizoen = seizoen(zomer+1);

%% ac_cat, S23 wordt 2/3
if ismember('VVCcode', fields(trf))
    trf.d_ac_cat = regexprep(trf.VVCcode, 'S(\d)(\d)', '$1/$2', 'ignorecase');
end

%% LT-bepaling obv klasse: 0***, wordt T en 1*** wordt L
if ismember('Klasse', fields(trf))
    lt = {'T'; 'L'};
    trf.d_lt = lt(strncmp('1', trf.Klasse, 1) + 1);
elseif ismember('lt', fields(trf))
    trf.d_lt = trf.lt;
end

%% CDA-procedure?
if ismember('cda', Filter.aggregation)
    cda = {'false', 'true'};
    trf.cda = cda(ismember(trf.Klasse, {'1009', '1209', '1900'})+1);
end

%% DEN-bepaling, let op alle uren + 1 zodat 0 uur het eerste uur wordt
den = {'N';'N';'N';'N';'N';'N';'N';'D';'D';'D';'D';'D';'D';'D';'D';'D';'D';'D';'D';'E';'E';'E';'E' ;'N'};
trf.d_den = den(HH + 1);

%% Meteojaar, voor het plotten van baangebruik
trf.d_myear = repmat({num2str(JaarInfo.jaar)}, trfLines, 1);

%% Waar wordt dit voor gebruikt?

%d_period (bevat alleen '0'
trf.d_period = repmat({'0'}, trfLines, 1);

%% rename fields to Daisy spec
if ismember('Runway', fields(trf)); trf.d_runway = trf.Runway; end
if ismember('Route',  fields(trf)); trf.d_route  = trf.Route;  end
if ismember('Type',   fields(trf)); trf.d_type   = trf.Type;   end
if ismember('Klasse', fields(trf)); trf.d_proc   = trf.Klasse; end

%% Correctiefactor toepassen, sorteer correctiefactoren per maand
disp('... pas correctiefactor toe');
correctie = corr.Correctie(cellfun(@(x) find(strcmpi(x, corr.Maand)), maand));
trf.corr = correctie(M);
fprintf('    incl. corr.: %6.0f\n', sum(trf.corr))
fprintf('          corr.: %6.0f\n', sum(trf.corr)-numel(trf.corr))

%% Selecteer de gewenste periode
if isfield(Filter, 'days')
    days = num2str(Filter.days(:));
    d = ismember(trf.Datum, days);
else
    d = true;
end

%% Filter de data: bijvoorbeeld op commercial flights vs GA
if isfield(Filter, 'field')
    disp('... filter verkeer:');
    f = ismember(trf.(Filter.field), Filter.values);
    trf.filter = Filter.result(2-f);
    trf.filter(~d) = {'NotSelected'};
    fprintf('    %s: %6.0f\n', Filter.result{1}, sum(trf.corr(d &  f)))
    fprintf('    %s: %6.0f\n', Filter.result{2}, sum(trf.corr(d & ~f)))
else
    %f = ones(trfLines);
    Filter.result = cellstr(Filter.result);
    trf.filter = repmat(Filter.result(1), trfLines, 1);
end

%% Aggregeer traffic, filterwaarde in de eerste kolom
disp('... aggregeer verkeer');
data = cell(trfLines, numel(Filter.aggregation)+1);
data(:,1) = trf.filter;
for i=1:numel(Filter.aggregation)
    data(:,i+1) = trf.(Filter.aggregation{i});
end

%filter unique
[trf_agg,~,i] = uniqueRowsCA(data);

%bereken totaal
totaal = accumarray(i, trf.corr);
trf_agg = [trf_agg, num2cell(totaal)];

%% Uitvoer traffics
disp('... schrijf naar bestand:');
[pathstr,name,ext] = fileparts(TrafficFile);

%format strings
ncol = numel(Filter.aggregation);
header_format = [repmat('%s\t', 1, ncol) 'total\n'];
data_format   = [repmat('%s\t', 1, ncol) '%f\n'];

for res=1:numel(Filter.result)
    %filenaam
    out{res} = [pathstr '\' name '_' Filter.result{res} ext];
    fid_out = fopen(out{res},'W');
    disp(['    ' out{res}]);
    
    %file header
    fprintf(fid_out, header_format, Filter.aggregation{:});
    
    %filter
    f = strcmp(trf_agg(:,1), Filter.result{res});
    trf_out = trf_agg(f,2:end);

    %schrijf data
    for i=1:size(trf_out,1)
        fprintf(fid_out, data_format, trf_out{i,:});
    end
    fclose(fid_out);
end

% klaar
OutFile1 = out{1};
if numel(Filter.result) == 2
    OutFile2 = out{2};
end

end