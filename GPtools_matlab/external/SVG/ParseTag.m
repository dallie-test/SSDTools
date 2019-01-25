function struct=ParseTag(Tag, NumFields)
% Deze functie coverteert een Tag naar een structure
%
% input:
%   Tag        tekst in de vorm: Field1="Value1" Field2="Value2" etc.
%                            of: Field1:Value1;Field2:Value2 etc.
%
%   NumFields  velden die naar numerieke waarden worden gevonverteert (optioneel)        


% Optioneel conversie van numerieke velden
str_conv = (nargin == 2);
 
sep = regexp(Tag, '^.*?=\s*"', 'match');
if ~isempty(sep)
    % scheidingsteken: =" en "
    Tag=regexprep(Tag, '^\s*', '');
    Tag=regexprep(Tag, '\s*=\s*"\s*', '\t');
    Tag=regexprep(Tag, '\s*"\s*', '\n');
else
    sep = ':';
    % scheidingsteken: : en ;
    Tag=regexprep(Tag, '^\s*', '');
    Tag=regexprep(Tag, '\s*:\s*', '\t');
    Tag=regexprep(Tag, '\s*;\s*', '\n');
end

List   = textscan(Tag, '%s %s', 'delimiter', '\t');

% Vervang ongeldige characters in fieldnames
Fields = regexprep(List{1},'-','_');
Values = List{2};

% converteer naar struct en converteer tekst (optioneel)
for i=1:length(Fields)
    if(str_conv) && (sum(strcmp(Fields{i}, NumFields)))
        struct.(Fields{i}) = str2num(Values{i});
    else
        struct.(Fields{i}) = Values{i};
    end
end
