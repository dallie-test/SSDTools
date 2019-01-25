function GPfig_verkeersverdeling(TrafficFile, PeriodsFile_or_Threshold, SlondCapFile, Dagen_of_JaarInfo, Sjabloon, OutputFile, Filter)
% Maak een figuur met de etmaalverdeling van een gemiddelde zomer- en winterdag (gp2013, figuur 2.2)
%
% input
%   TrafficFile                xls of tab-gescheiden text met minimaal d_lt,  d_schedule, total
%   PeriodsFile_or_Threshold   Daisy periods table (xls of tab-gescheiden text) of
%                              capaciteitsdrempel; SLOND wordt bepaald obv
%                              verkeersaanbod en capaciteit icm de opgegeven drempel
%   SlondCapFile               xls of tab-gescheiden text met slond, Lcap, Tcap
%   Dagen_of_JaarInfo          aantal dagen van het traffic of struct met jaarinfo, zie GPcalc_gebruiksjaar
%   Sjabloon                   SVG sjabloon
%   OutputFile                 SVG output
%   Filter                     struct met filter en aggregatie, bijvoorbeeld:
%                              Filter.field  = 'seizoen';
%                              Filter.values = 'zomer';
%                              Filter.bin = 10   aggregeer per 10-minutenblok
%                              Filter.taxi = 10  taxitijd

    % Zet defaults voor optionele parameters
    if (nargin < 7) || ~isfield(Filter, 'bin')
        Filter.bin = 20;
    end
    if (nargin < 7) || ~isfield(Filter, 'taxi')
        Filter.taxi = 0;
    end

    % Lees traffic: d_lt, d_schedule, total 
    trf = read_traffic(TrafficFile);

    % Aantal dagen in het traffic
    if isnumeric(Dagen_of_JaarInfo)
        dagen = Dagen_of_JaarInfo;
    else
        if isfield(Filter, 'field') && strcmp(Filter.field, 'Datum')
            %TODO check of de dagen in het traffic zitten
            d1 = datenum(num2str(Filter.values(1)),'yyyymmdd');
            d2 = datenum(num2str(Filter.values(end)),'yyyymmdd');
            dagen = d2 - d1 + 1;
        elseif isfield(Filter, 'field') && strcmp(Filter.field, 'seizoen')
            dagen = Dagen_of_JaarInfo.(Filter.values).dagen;            
        else
            dagen = Dagen_of_JaarInfo.winter.dagen + Dagen_of_JaarInfo.zomer.dagen;
        end 
    end

    % Lees periods table
    if isnumeric(PeriodsFile_or_Threshold)
        AutoPeriods = true;
        cap_drempel = PeriodsFile_or_Threshold;
    else
        AutoPeriods = false;
        pTab = read_traffic(PeriodsFile_or_Threshold);
    
        % Sorteer op tijd: de xls van Daisy is niet per definitie oplopend
        [~, index] = sort(pTab.t_begin);
        period = regexprep(pTab.period(index), ',.*$', '');
    end
    
    % Lees SLOND table 
    cap = read_traffic(SlondCapFile, {'Tcap','Lcap'});
    ncap = numel(cap.slond);
    
    % Correctie voor taxitijd
    % De tijd in Matlab is een getal tussen 0 en 1
    trf.taxi = (strcmp(trf.lt, 'T') .* Filter.taxi - strcmp(trf.lt, 'L') .* Filter.taxi)/24/60;
    baantijd = mod(rem(datenum(trf.schedule, 'HH:MM'),1) + trf.taxi, 1)*24*60;
    
    % Voeg x-minutenblok toe round(*1000/1000) vanwege afrondingsverschillen)
    trf.blok = fix(round(baantijd/Filter.bin*1000)/1000)+1;
      
    % X-as tijd labels
    bins = 24*60/Filter.bin;
    plot.time = cellstr(datestr(0:1/bins:1-1/bins, 'HH:MM'));

    % Maak index voor naderingsprofiel: Cda, 3000 ft, 2000 ft
    if isfield(trf,'proc')
        icda  = strcmp(trf.proc, '1009') | strcmp(trf.proc, '1209') | strcmp(trf.proc, '1900');
        i3000 = strcmp(trf.proc, '1001') | strcmp(trf.proc, '1201');
        i2000 = strcmp(trf.proc, '1000') | strcmp(trf.proc, '1200');
    end
    
    % Maak index voor netwerksegment
    if isfield(trf,'segment')
        for s=1:5
            iSegm(:,s) = strcmp(trf.segment, num2str(s));
        end
    end
        
    % Maak index voor starts en landingen
    iT = strcmp(trf.lt, 'T');
    iL = ~iT;
    
    % Maak index voor slond capaciteit
    %               icap: 1   2   3   4   5                
    [~,icap] = ismember({'S','L','O','N','D'}, cap.slond); 

    % Filter traffic
    if isfield(Filter, 'field');
        if isnumeric(Filter.values)
            cellValues = arrayfun(@num2str, Filter.values, 'UniformOutput', false);
        else
            cellValues = cellstr(Filter.values);
        end
        f = ismember(trf.(Filter.field), cellValues);
    else
        f = true;
    end

    % Agregeer per x-minuten blok en maak plot struct
    for b=1:bins 
        ibin = (trf.blok == b) & f;
        
        % Aantal starts en landingen
        plot.T(b) = sum(trf.total(iT & ibin))/dagen;
        plot.L(b) = sum(trf.total(iL & ibin))/dagen;

        % Segment
        if isfield(trf,'segment')
            for s=1:5
                plot.Tsegment(s,b) = sum(trf.total(iSegm(:,s) & iT & ibin))/dagen;
                plot.Lsegment(s,b) = sum(trf.total(iSegm(:,s) & iL & ibin))/dagen;
            end
        end

        % Naderingsprofiel
        if isfield(trf,'proc')
            plot.proc(1,b) = 100 * sum(trf.total(icda  & ibin))/dagen / plot.L(b);
            plot.proc(2,b) = 100 * sum(trf.total(i3000 & ibin))/dagen / plot.L(b);
            plot.proc(3,b) = 100 * sum(trf.total(i2000 & ibin))/dagen / plot.L(b);
        end
        
        if AutoPeriods
            % SLOND obv verkeersaanbod
            if b <= 6*60/Filter.bin || b > 23*60/Filter.bin || (isfield(trf,'proc') && plot.proc(1,b) > 50) % obv het perc cda's
                period(b) = {'N'};
            elseif plot.T(b) <= cap.Tcap(icap(3))/(60/Filter.bin)*cap_drempel && plot.L(b) <= cap.Lcap(icap(3))/(60/Filter.bin)*cap_drempel
                period(b) = {'O'};
            elseif plot.T(b) <= cap.Tcap(icap(2))/(60/Filter.bin)*cap_drempel
                period(b) = {'L'};
            elseif plot.L(b) <= cap.Lcap(icap(1))/(60/Filter.bin)*cap_drempel
                period(b) = {'S'};
            else
                period(b) = {'D'};
            end 
        end
            
        % Capaciteit obv period S, L, O, N, D etc.
        iperiod = strcmp(period(b), cap.slond);
        plot.Tcap(1:ncap,b) = cap.Tcap/(60/Filter.bin) .* iperiod;
        plot.Lcap(1:ncap,b) = cap.Lcap/(60/Filter.bin) .* iperiod;
    end
    
    % Output naar SVG
    plot2svg(plot, Sjabloon, OutputFile);
end