function [trf, rawhdr]=read_traffic_with_hdr(Trf_file, NumFields, Sheet)
% Lees een traffic file, xls of tab-gescheiden tekst
%
% Input
%   Trf_file     Filenaam of struct met: Trf_file.filename
%                                        Trf_file.sheet
%                                        Trf_file.numfields
%                De extentie van de filenaam bepaalt het type:
%                .txt tekstfile met tab als scheidingsteken 
%                .xls Excel bestand met data in het sheet 'Export'
%   NumFields    velden die naar numerieke waarden worden gevonverteert (optioneel)
%                Default wordt 'total' geconverteerd.
%   Sheet        Te lezen sheet van de xls (optioneel)
%                Default wordt het eerste tabblad gelezen.
%                (Voor oude Daisy-versies het tabblad 'Export').
%
%   Als een struct als invoer wordt gebruikt in combinatie met de optionele
%   parameters 'NumFields' en/of 'Sheet', dan worden de optionele waarden
%   alleen gebruikt als deze niet reeds in de struct zijn gedefinieerd.
%
% Output
%    trf         Struct met n-tekstvelden en een veld 'total' met het aantal
%                vlietuigbewegingen
rawhdr = [];
    % Defaults
    if (nargin == 1)
        NumFields = 'total';    % 'total' converteren naar numerieke waarden
    end
    if (nargin <= 2)
        Sheet = 1;              % lees het eerste sheet
    end
      
    % Struct invoer?
    if isstruct(Trf_file)
        filename = Trf_file.filename;
        if isfield(Trf_file, 'sheet'); Sheet = Trf_file.sheet; end
        if isfield(Trf_file, 'numfields'); NumFields = Trf_file.numfields; end
    else
        filename = Trf_file;
    end
    
    % Excel file of tekstinvoer?
    if (strcmpi(filename(end-3:end),'.xls')) || (strcmpi(filename(end-4:end),'.xlsx'))
        try
            [~,~,raw] = xlsread(filename, Sheet);
        catch
            % Probeer nog eens met 'basic', dit voor oudere Daisy versie's
            disp('xlsread: basic mode') % debug
            [~,~,raw] = xlsread(filename, Sheet,'','basic'); 
        end
        
        % Lees de header
        raw
        hdr = strrep(raw(1,:),'d_',''); % verwijder 'd_' in de fieldnames
        raw(1,:) = [];

        %TODO functie strip header gebruiken ???
        hdr = strip_hdr(hdr);

        % Verwijder lege cellen (aan het eind)
        fh = @(x) all(isnan(x(:)));
        notempty = ~all(cellfun(fh, raw),2);

        % Converteer cell array naar struct met cells
        trf = struct;
        for i=1:numel(hdr)
            dat = raw(notempty, i);

            % Converteer numerieke waarden
            if all(cellfun(@isnumeric, dat))
                trf.(hdr{i}) = cell2mat(dat);
            elseif ismember(hdr{i}, cellstr(NumFields))
                % trf.(hdr{i}) = str2double(dat);
                trf.(hdr{i}) = reshape(sscanf(sprintf('%s#', dat{:}), '%g#'), size(dat));
            else
                trf.(hdr{i}) = dat;
            end
        end
    else
        trf = read_text(filename, NumFields);
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