function [tab]=read_text(TextFile, NumFields)
% Lees een tab-gescheiden tekst

% Input
%   TextFile     In te lezen tekstfile met tab als scheidingsteken 
%   NumFields    velden die naar numerieke waarden worden gevonverteert (optioneel)
%
% Output
%    tab         Struct met n-tekstvelden

    % Optioneel conversie van numerieke velden
    if nargin < 2
        NumFields = '';
    end

    % Lees de file
    fid=fopen(TextFile);

    % Lees de header
    hdr = textscan(fgetl(fid),'%s','delimiter','\t');
    hdr = strrep(hdr{:},'d_',''); % verwijder 'd_' in de fieldnames
    hdr = strip_hdr(hdr);         % maak er correcte fieldnames van

    % Lees de data
    f = {'%s','%f'}; % numerieke data?
    format = strjoin(f(ismember(hdr, cellstr(NumFields)) + 1));
    dat    = textscan(fid, format,'delimiter','\t');
    
    % Neem lege headers niet mee
    empty_headers = cellfun(@isempty,hdr);
    hdr = hdr(~empty_headers);
    dat = dat(~empty_headers);

    % Afsluiten
    fclose(fid);

    % converteer naar struct
    for i=1:numel(hdr)
        tab.(hdr{i}) = dat{i};
    end
end


function stripped_hdr = strip_hdr(hdr)
    odd_characters = cellfun(@(x) 1*(x=='_') | isstrprop(x,'alphanum'),hdr,'UniformOutput',false);
    for i=1:size(hdr,1)
        hdr_i = hdr{i};
        hdr_i(~odd_characters{i}) = [];
        hdr{i} = hdr_i;
    end
    stripped_hdr = hdr;
end