function traffic = merge_traffic(traffics, idField, ids)
% Merge traffics
%
% input
%   traffic     structure met traffic(1), traffic(2) etc
%   idField     optioneel: veld dat wordt toegevoegd met de id's
%   ids         optioneel: ids van de traffics


    % Voeg ids toe
    if(nargin == 3)
        for s=1:2;
            n = numel(traffics(s).lt);
            traffics(s).(idField) = repmat(ids(s), n, 1); 
        end
    end  
    
    % Converteer naar cell and merge
    fNames = fieldnames(traffics);
    cellData = cellfun(@(x) {vertcat(traffics.(x))},fNames);

    % Construct the output.
    traffic = cell2struct(cellData, fNames, 1);

