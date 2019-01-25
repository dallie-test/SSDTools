function GPfig_sectorisatie(traffic_file, output_file, sjabloon, conversion_file)
% Maak een figuur met de sectorverdeling
%
% input
%   traffic_file     xls of tab-gescheiden text met minimaal d_lt, d_route en total
%   sjabloon         SVG sjabloon
%   output_file      SVG output
%   conversion_file  tabel met route en sector


%% Inlezen data en sector koppelen obv de route

    % Importeer traffic: d_lt,d_route,total
      % Direct inlezen van de xls gaat niet daarom in Excel converteren naar
      % tab-gescheiden tekst.
    if size(traffic_file,2)==2
        % Lees traffic: ac_cat,	total 
        Trf{1} = read_traffic(traffic_file{1});
        Trf{2} = read_traffic(traffic_file{2});
        n_Trf = 2;
    else
        % Lees traffic: ac_cat,	total 
        Trf{1} = read_traffic(traffic_file);
        n_Trf = 1;
    end

    onbekende_routes = {};

    % Importeer tabel met sectorindeling van routes: route, sector
    tab = read_traffic(conversion_file);
    for i_Trf=1:n_Trf
        tabDaisy = Trf{i_Trf};
        
        % Zoek sector op in 'tab'; Join datasets obv van de routenaam
        [route,~,r] = unique(tabDaisy.route);      % unique data
        
        [gevonden, i] = ismember(route, tab.route); 
        sector(gevonden)  = tab.sector(i(gevonden));
        
        % Onbekende routes
        onbekende_routes  = unique([onbekende_routes, route(~gevonden)]);
        sector(~gevonden) = {'onbekend'};
        
        % Vul volledige traffic
        tabDaisy.sector = sector(r);
        
        % Aggregeer op sector
        sectorL(i_Trf).naam={'ARTIP', 'RIVER', 'SUGOL'};
        [gevonden, i] = ismember(tabDaisy.sector, sectorL(i_Trf).naam);
        sectorL(i_Trf).total = accumarray(i(gevonden)', tabDaisy.total(gevonden));
        sectorL(i_Trf).p = sectorL(i_Trf).total/sum(sectorL(i_Trf).total);

        sectorT(i_Trf).naam = {'1', '2', '3', '4', '5'};
        [gevonden, i] = ismember(tabDaisy.sector, sectorT(i_Trf).naam);
        sectorT(i_Trf).total = accumarray(i(gevonden)', tabDaisy.total(gevonden));
        sectorT(i_Trf).p = sectorT(i_Trf).total/sum(sectorT(i_Trf).total);
    end
    
    %raporteer onbekende routes
    if isempty(onbekende_routes)
        disp('alle routes zijn gedekt in GPfig_sectorisatie');
    else
        warning('The following routes have not been found');
        fprintf('''%s''\n', onbekende_routes{:});
    end
    
    
%% OUTPUT SVG

    % Lees SVG sjabloon
    SVG = fileread(sjabloon);

    % Invoegen data Starts
    rotatie=[320; 25; 100; 165; 220];
    datanums=[rotatie,sectorT(1).p*700,-sectorT(1).p*700];
    data=sprintf('\t\t\t\t<g transform="rotate(%03d)"> <path d="m30,0 l 0,10 %6.2f,8 -3,12 25,-30 -25,-30 3,12 %7.2f,8 0,10 Z" /> </g>\n',datanums);
    SVG = strrep(SVG, '<!-- data starts -->', data);

    % data labels
    for i=1:length(sectorT(1).naam),
        SVG = strrep(SVG, ['sectorT.R(',num2str(i), ')'], sprintf('%3.2f', sectorT(1).p(i)*700)); % lengte van de pijl
        SVG = strrep(SVG, ['sectorT.p(',num2str(i), ')'], sprintf('%2.0f', sectorT(1).p(i)*100));
        if (n_Trf==2)
            SVG = strrep(SVG, ['sectorT2.p(',num2str(i), ')'], sprintf('%2.0f', sectorT(2).p(i)*100));
        end
    end

    % Invoegen data Landingen
    rotatie=[350; 130; 195];
    datanums=[rotatie,sectorL(1).p*700,-sectorL(1).p*700];
    data=sprintf('\t\t\t\t<g transform="rotate(%03d)"> <path d="m20,0 l 20,22 -2,-12 %6.2f,10 -2,-20 2,-20 %7.2f,10 2,-12 -20,22 Z" /> </g>\n',datanums);
    SVG = strrep(SVG, '<!-- data landingen -->', data);

    % data labels
    for i=1:length(sectorL(1).naam),
        SVG = strrep(SVG, ['sectorL.R(',num2str(i), ')'], sprintf('%3.2f', sectorL(1).p(i)*700)); % lengte van de pijl
        SVG = strrep(SVG, ['sectorL.p(',num2str(i), ')'], sprintf('%2.0f', sectorL(1).p(i)*100));
        if (n_Trf==2)
            SVG = strrep(SVG, ['sectorL2.p(',num2str(i), ')'], sprintf('%2.0f', sectorL(2).p(i)*100));
        end
    end

    % aanmaken nieuwe SVG
    % dlmwrite blijkt super traag te zijn, onderstaande alternatief is veel sneller.
    
    %dlmwrite(output_file, SVG, 'delimiter', '');
    fid = fopen(output_file, 'w' );
    fprintf( fid, '%s\n', SVG);
    fclose( fid );
end
