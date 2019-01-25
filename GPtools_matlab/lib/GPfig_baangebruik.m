function GPfig_baangebruik(traffic_file, period, rwys, sjabloon, output_file)
% Maak een figuur met het baangebruik (gp2013, figuur 3.3 en 3.4)
%
% input
%   traffic_file  xls of tab-gescheiden text met minimaal d_lt, d_runway, d_period, d_den, d_myear en total
%   period        de te plotten periode als regular expression:  bijvoorbeeld 'D|E|N' of 'N'
%   rwys          indien structure, dan bevat dit de te plotten rwy's.
%                 indien scalair, aantal te plotten runways.
%   sjabloon      SVG sjabloon
%   output_file   SVG output

    if ischar(traffic_file)
        n_traffic = 1;
        traffic_file = {traffic_file};
    elseif iscell(traffic_file)
        if (length(traffic_file)==1 || length(traffic_file)==2)
            n_traffic = length(traffic_file);
        else
            error('Only one or two traffics are supported for variable traffic_file')
        end
    else
        error('Unknown input for variable traffic_file')
    end

    % Lees traffic(s) en bereken stats
    trf_my={}; 
    for i_traffic=1:n_traffic
        trf_my{i_traffic} = GPcalc_baangebruik(traffic_file{i_traffic}, period);
    end    
    
    % Sorteer vector op 'mean' voor Landingen en Starts afzonderlijk
    [~, index] = sort(trf_my{1}.mean, 'descend');      % sorteer op mean

    % Starts. If struct --> specifieke banen. If scalair --> aantal runways.
    if isstruct(rwys)
        CurSel = rwys.T;                            % Selectie van banen die geplot moeten worden.
        Crit1  = strcmp(trf_my{1,1}.lt,'T');        % Selectie van starts.
        Tindex = zeros(1,length(CurSel));           % Geheugen allocatie.
        for i=1:length(CurSel)                      
            Crit2 = strcmp(CurSel(i),trf_my{1,1}.runway);           % Vergelijk selectie van banen met beschikbare banen in traffic.
            Tindex(i) = sum(and(Crit1,Crit2).*(1:length(index)));   % Sla de corresponderende index op.
        end
    else
        aantal_rwys = rwys;
        Tindex = strcmp(trf_my{1}.lt(index), 'T').*index; % wat zijn de starts?
        Tindex(Tindex==0) = [];                           % filter de landingen eruit
        Tindex = Tindex(1:aantal_rwys);                   % aantal te plotten runway's
    end

    % Maak een structure voor de SVG
    plot.T_runway = trf_my{1}.runway(Tindex);
    plot.T_mean   = trf_my{1}.mean(Tindex);
    plot.T_std    = trf_my{1}.std(Tindex);
    plot.T_min    = trf_my{1}.min(Tindex);
    plot.T_max    = trf_my{1}.max(Tindex);
    
    % Tweede traffic; runways in dezelfde volgorde als traffic 1
    if n_traffic == 2
        for i=1:length(Tindex)
            currwy = trf_my{1}.runway(Tindex(i));
            Tindex2 = strcmp(currwy, trf_my{2}.runway) & strcmpi(trf_my{2}.lt,'t');
            if sum(Tindex2)==1
                plot.T_mean2(i) = trf_my{2}.mean(Tindex2);
                plot.T_std2(i)  = trf_my{2}.std(Tindex2);
                plot.T_min2(i)  = trf_my{2}.min(Tindex2);
                plot.T_max2(i)  = trf_my{2}.max(Tindex2);
            else
                plot.T_mean2(i) = 0;   % zijn dit logische waarden???
                plot.T_std2(i)  = -99;
                plot.T_min2(i)  = -99;
                plot.T_max2(i)  = -99;
            end
        end
    end
    
    % Landingen. If struct --> specifieke banen. If scalair --> aantal runways.
    if isstruct(rwys)
        CurSel = rwys.L;                            % Selectie van banen die geplot moeten worden.
        Crit1  = strcmp(trf_my{1,1}.lt,'L');        % Selectie van landingen.
        Lindex = zeros(1,length(CurSel));           % Geheugen allocatie.
        for i=1:length(CurSel)                      
            Crit2 = strcmp(CurSel(i),trf_my{1,1}.runway);           % Vergelijk selectie van banen met beschikbare banen in traffic.
            Lindex(i) = sum(and(Crit1,Crit2).*(1:length(index)));   % Sla de corresponderende index op.
        end
    else
        aantal_rwys = rwys;
        Lindex = strcmp(trf_my{1}.lt(index), 'L').*index; % wat zijn de landingen?
        Lindex(Lindex==0) = [];                           % filter de landingen eruit
        Lindex = Lindex(1:aantal_rwys);                   % aantal te plotten runway's
    end

    % Maak een structure voor de SVG
    plot.L_runway = trf_my{1}.runway(Lindex);
    plot.L_mean   = trf_my{1}.mean(Lindex);
    plot.L_std    = trf_my{1}.std(Lindex);
    plot.L_min    = trf_my{1}.min(Lindex);
    plot.L_max    = trf_my{1}.max(Lindex);
    
    % Tweede traffic; runways in dezelfde volgorde als traffic 1
    if n_traffic == 2
        for i=1:length(Lindex)
            currwy = trf_my{1}.runway(Lindex(i));
            Lindex2 = strcmp(currwy, trf_my{2}.runway) & strcmpi(trf_my{2}.lt,'l');
            if sum(Lindex2)==1
                plot.L_mean2(i) = trf_my{2}.mean(Lindex2);
                plot.L_std2(i)  = trf_my{2}.std(Lindex2);
                plot.L_min2(i)  = trf_my{2}.min(Lindex2);
                plot.L_max2(i)  = trf_my{2}.max(Lindex2);
            else
                plot.L_mean2(i) = 0;   % zijn dit logische waarden???
                plot.L_std2(i)  = -99;
                plot.L_min2(i)  = -99;
                plot.L_max2(i)  = -99;
            end
        end
    end
    
    % Output naar SVG
    plot2svg(plot, sjabloon,output_file);
end