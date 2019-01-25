function EvalSVG(SVGin, SVGout, s)
% Deze functie berekent het resultaat van de Matlab-code in Tagtekst
%
% Tagtekst is een string en bevat Matlab-code en optioneel een format
% string. De volgende varianten voor Tagtekst zijn toegestaan
%   s.x(1)*10
%   "s.x(1)*10"
%   code="s.x(1)*10"
%   code="s.x(1)*10" format="%7.0f"
%   (optioneel: spaties rond de =)
%
% Het resultaat is een string in het opgegeven format, zie help sprintf.
% Als format ontbreekt wordt '7.2f' als default gebruikt.
%
% De structure s wordt bij de aanroep van deze functie gedefinieerd en
% kan in het code deel van Tagtekst als variabele worden gebruikt.
% -------------------------------------------------------------------------


    % Lees SVG sjabloon
    SVG=fileread(SVGin);

    % Zoek en vergang <Matlab>...</Matlab> door het resultaat van de matlab-code
    hEvalTag=@EvalTag; %Gebruik een function handle anders wordt de lokale functie niet gevonden
    SVGres=regexprep(SVG,'<Matlab>\s?(.*?)\s?</Matlab>','${hEvalTag($1)}');

    % Schrijf naar SVG
    dlmwrite(SVGout, SVGres, 'delimiter', '');
    
    function Answer = EvalTag(Tagtext)
    % Bereken de Matlab-code en pas format toe
    
        % code="1+2" of "1+2" als code= ontbreekt
        c=regexp(Tagtext,'code\s?=\s?"([^"]*?)"|^"?([^"]*)"?$','tokens');
        c=char(c{1}); 

        % Bereken Matlab-code met eval
        e = eval(c);
        if iscellstr(e) % cellstr gaat fout met sprintf
            e =  char(e);
        end
        
        % format='%7.2f' zie help sprintf
        f=regexp(Tagtext,'format\s?=\s?"([^"]*?)"','tokens');
        
        % Bij ontbreken format string default gebruiken
        if isempty(f)
            if isnumeric(e)
                f='%4.2f';
            else
                f='%s';
            end
        else
            f=char(f{1});
        end

        % Pas format toe
        Answer=sprintf(f, e);
    end
end