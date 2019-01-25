function index_of_match = MatchingCells(CellArray, Pattern, OutKey)
% Zoek met een regular expression de overeenkomstige cellen uit de cell
% array
%
% input:
%   CellArray   Array van cell strings
%   Pattern     Regular expression
%   OutKey      (Optioneel) index of match,  default is index
%
% output
%   index       vector met logicals, een index op de overeenkomstige cellen 


    match = regexp(CellArray, Pattern); 
    
    % converteer cell array naar vector
    index = ~cellfun('isempty', match); 
    
    % index of match?
    if (nargin == 2) || strcmp(OutKey, 'index')
        index_of_match = index;
    elseif strcmp(OutKey, 'match')
        index_of_match = CellArray(index);
    else
        disp('MatchingCells: onbekende OutKey')
    end 
end
    