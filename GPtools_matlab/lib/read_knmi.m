function [tab]=read_knmi(TextFile)
% Lees een tab-gescheiden knmi file

% Input
%   TextFile     In te lezen knmifile met tab als scheidingsteken 
%
% Output
%    tab         Struct met n-tekstvelden

    % Lees de file
    fid=fopen(TextFile);

    % Lees de header
    hdr = textscan(fgetl(fid),'%s','delimiter','\t');
    hdr = strrep(hdr{:},'10','x'); % vervang '10' door x in de fieldnames
    ncol = length(hdr);

    % Lees de data
    format = repmat('%f',1,ncol);
    dat    = textscan(fid, format,'delimiter','\t');

    % converteer naar struct
    for i=1:numel(hdr)
        tab.(hdr{i}) = dat{i};
    end
    
    % Afsluiten
    fclose(fid);
end
