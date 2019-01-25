function GPfig_baangebruik_nieuw(TrafficFile, period, rwys, sjabloon, output_file)
% Maak een figuur met het baangebruik (gp2013, figuur 3.3 en 3.4)
%
% input
%   TrafficFile   xls of tab-gescheiden text met minimaal d_lt, d_runway, d_schedul en total
%   period        de te plotten periode als regular expression:  bijvoorbeeld 'D|E|N' of 'N'
%   rwys          (aantal) te plotten runways
%   sjabloon      SVG sjabloon
%   output_file   SVG output


    if ~ischar(TrafficFile)
        error('TODO: deze functie accepteert maar één traffic')
    end

    % Lees traffic: d_lt, d_runway, d_schedule, total 
    trf = read_traffic(TrafficFile);
    
    %% DEN-bepaling, let op alle uren + 1 zodat 0 uur het eerste uur wordt
    HH = reshape(sscanf(sprintf('%2s#', trf.schedule{:}), '%g#'), size(trf.schedule));
    den = {'N';'N';'N';'N';'N';'N';'EM';'D';'D';'D';'D';'D';'D';'D';'D';'D';'D';'D';'D';'E';'E';'E';'E' ;'N'};
    trf.den = den(HH + 1);

    %% Maak indices
    
    % Maak index voor starts en landingen
    iT = strcmp(trf.lt, 'T');
    iL = ~iT;
    
    % Maak index voor den
    [~,iden] = ismember(trf.den, {'D','E','EM','N'}); 
    
    %% Agregeer per runway en maak plot struct
    rwy = unique(trf.runway); % start én landingsbanen
    
    for r=1:numel(rwy)
        irwy = strcmp(trf.runway, rwy(r));
        
        % Aantal starts en landingen
        plot.T(r) = sum(trf.total(iT & irwy));
        plot.L(r) = sum(trf.total(iL & irwy));
        
        % den
        for d=1:4
            plot.T_den(d,r) = sum(trf.total(iden==d & iT & irwy));
            plot.L_den(d,r) = sum(trf.total(iden==d & iL & irwy));
        end
    end
    
    % Ongesorteerd
    plot.T_runway = rwy;
    plot.L_runway = rwy;
    
    % Te plotten banen
    if isnumeric(rwys)
        % Sorteer op aflopend baangebruik voor Landingen en Starts afzonderlijk
        [~, sT] = sort(plot.T, 'descend');
        [~, sL] = sort(plot.L, 'descend');
    
        % Check aantal gebruikte rwys < aantal_rwys
        sT = sT(1:min(rwys, end));
        sL = sL(1:min(rwys, end));
    else
        %TODO: Er kunnen meer banen zijn opgegeven dan gebruikt
        %      dit levert nullen op in sT, sL
        [~, sT] = ismember(rwys.T, plot.T_runway);
        [~, sL] = ismember(rwys.L, plot.L_runway);
    end

    plot.T_runway_sort = rwy(sT);
    plot.L_runway_sort = rwy(sL);

    plot.T_den_sort =  plot.T_den(:,sT);
    plot.L_den_sort =  plot.L_den(:,sL);
        
    %% Output naar SVG
    plot2svg(plot, sjabloon,output_file);
end