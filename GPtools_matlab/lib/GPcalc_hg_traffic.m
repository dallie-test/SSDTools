function [HG, Trf] = GPcalc_hg_traffic(Trf_file, Scale, just_night)
% Bereken de Hoeveelheid Geluid (HG).
%
% Input
%   Trf_file    In te lezen traffic, extentie bepaalt het type:
%               .txt tekstfile met tab als scheidingsteken 
%               .xls Excel bestand
%   scale       Schaalfactor (optioneel)
%   just_night  Boolean. Als waar worden de vluchten met D en E er uit gefilterd, en alleen de vluchten met N berekend
%
% Output
%   HG          Hoeveelheid geluid
%   Trf         Traffic met HG-bijdrage in Trf.hg

%% Zet defaults voor optionele parameters
if(nargin < 2), Scale = 1; end        % geen opschaling
if(nargin < 3), just_night = false; end % alle vluchten uit DEN, geen nachtfilter

%% Inlezen traffic
if iscell(Trf_file)
    for i=1:size(Trf_file, 2);
        t(i) = read_traffic(Trf_file{i}, 'total');
    end   
    trf = merge_traffic(t);
elseif ischar(Trf_file)
    trf = read_traffic(Trf_file, 'total');
else
    error('unkown variable type for variable traffic')
end

if just_night
    trf.total(~strcmp('N',trf.den)) = 0;
end

% Corrigeer de start-procedure van 0-3 naar 500-503
% Dit is niet nodig bij een import traffic, dan komt 5xx gewoon voor
% De NADP2-procedure zit wel normaal in een traffic 600-603
trf.proc = regexprep(trf.proc,'^[0123]$', '050$1');

% Corrigeer de procedurenummering van 1900 naar 1009
trf.proc(strcmp(trf.proc, '1900')) = {'1009'};

% Maak key aan
key = strcat(trf.ac_cat, '-', trf.proc);

% Toeslag etmaalperiode
weegfactor = [1; sqrt(10); 10];
[~, i] = ismember(trf.den, {'D', 'E', 'N'});
trf.weegfactor = weegfactor(i);

% Schaalfactor
trf.total = trf.total .* Scale;

%% Bepaal de HG bijdrage

% Lees de database in
% TODO: optioneel user database?
lib_dir = fileparts(mfilename('fullpath'));
HGtab = read_traffic([lib_dir '\HGdbase.xls'], {'dBlin'});

% Niet in de dbase -> 0
[t, i] = ismember(key, HGtab.key);
hg = [0; HGtab.dBlin];
trf.hg = hg(i+1) .* trf.total .* trf.weegfactor;

% Zijn de keys te vinden in de HG table?
NotFound = unique(key(~t));
if ~isempty(NotFound) 
    disp('Geen HG bijdrage voor:')
    NotFound
end

%% Totaal
HG = 10*log10(sum(trf.hg));

%% Uitvoer traffic
Trf = trf;

