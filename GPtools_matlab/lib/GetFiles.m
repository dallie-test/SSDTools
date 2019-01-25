function [files] = getFiles(dir_or_files, pattern)
% Selecteer files op basis van een regular expression
%
% input
%   dir_or_files  naam van de directory of een cell array met filenamen
%   pattern       regular expression

% Files en naam van de directory
if ischar(dir_or_files)
    d = dir(dir_or_files);
    % Files en in de directory 'd', dus geen directory's
    F = {d(~[d.isdir]).name}';
    D = [fileparts(dir_or_files) '\'];
else
    F = dir_or_files;
    D = []; 
end

% Selecteer files die overeenkomen met 'pattern'
F = F(~cellfun('isempty', regexp(F,pattern)));

% incl. de directory naam
files = strcat(D, F); 
