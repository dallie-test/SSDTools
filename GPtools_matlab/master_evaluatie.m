disp('Berekening kan out of memory raken. In dat geval: herstart MATLAB en sluit niet noodzakelijke applicaties af');
tic;
% debug
dbstop if error

%extern
addpath('lib')
addpath('external\teltool NLR\')
addpath('external\grid operations\')
addpath('external\SVG')

% directory's
% realisatie_dir = [pwd '\..\realisatie\'];
% prognose_dir   = [pwd '\..\prognose\001 Hybride\'];
% svgt_dir       = [pwd '\sjablonen\'];
% out_dir        = [pwd '\..\002 results\evaluatie\'];


realisatie_dir = [pwd '\..\..\berekeningen\realisatie\'];
prognose_dir   = [pwd '\..\evaluatie\GP2017 verkeer + US0624\'];
svgt_dir       = [pwd '\sjablonen\'];
out_dir        = [pwd '\..\results\'];


%output dir
mkdir(out_dir);

% Excel output
xls_output = [out_dir 'GP2017 tabellen.xls'];
copyfile([svgt_dir 'sjabloon_evaluatie.xls'], xls_output);

%sub-dir voor figuren
out_dir = [out_dir 'svg\'];
mkdir(out_dir);

% achtergrond en scripts kopieeren
copyfile([svgt_dir 'Schiphol_RD900dpi.png'], out_dir);
copyfile(which('svg2png.sh'), out_dir);
copyfile(which('svg2pdf.sh'), out_dir);
% -----------------------------------------------------------------------
year = 2017;
seizoensinfo = GPcalc_gebruiksjaar(year);

%% Berekenen gelijkwaardigheidscritera
disp(' ')
disp(' ')
disp('Gelijkwaardigheidscritera')
disp(' ')

% Prognose
load('GPresults.mat', 'gwc');
gwc_prognose = gwc;
clear gwc

sheet = 'gwc (GP)';
GPtab_gelijkwaardigheid(gwc_prognose, xls_output, sheet);

% Realisatie
Lden_realisatie   = [realisatie_dir 'Result_grotergrid'];
Lnight_realisatie = [realisatie_dir 'Result_Lnight_EHAM_2017'];

gwct = gelijkwaardigheid(Lden_realisatie, Lnight_realisatie, 1, 1);

%TODO: structure aanmaken in de functie gelijkwaardigheid
% Maak structure
gwc.myears  = year; 
gwc.w58den  = gwct(1);
gwc.w48n    = gwct(2);
gwc.eh48den = gwct(3);
gwc.sv40n   = gwct(4);

% Resultaten printen
disp('    w58den       w48n    eh48den      sv40n')
disp('---------- ---------- ---------- ----------')
fprintf('%10.0f %10.0f %10.0f %10.0f\n', gwc.w58den,gwc.w48n, gwc.eh48den,gwc.sv40n)
disp(' ')
    
% Uitvoer naar Excel
sheet = 'gwc';
GPtab_gelijkwaardigheid(gwc, xls_output, sheet);

%% Converteer NLR-traffic
NLR_traffic          = [realisatie_dir '20171107_Traffic_2017.txt'];
NLR_correctie_factor = [realisatie_dir '20171107_correction_2017.txt'];

filter.aggregation = {'d_myear' 'seizoen' 'd_den' 'd_schedule:m10' 'd_lt' 'd_runway' 'd_route' 'd_ac_cat' 'd_proc'};
filter.field  = 'Nature';
filter.values = {'FC','FF','FL','FP','PC','PF','PL','PP'};
filter.result = {'HV','GA'};

disp('traffic converteren')
%TODO: Inlezen van een traffic vanuit een xlsx gaat niet goed! 
%      Dit is een memory probleem. Lijkt niet oplosbaar.
%      Work-arround: Gebruik tab-gescheiden tekst ipv xls
traffic_realisatie = GPcalc_convert_nlr_traffic(NLR_traffic, NLR_correctie_factor, seizoensinfo, filter);
disp('traffic converteren done')

%% Bereken het HG

%TODO: NADP2 zit nog niet in de HG-database; wacht op Daisy implementatie van HG
% [HV_traffic_realisatie, GA_traffic_realisatie] = GPcalc_convert_nlr_traffic(NLR_traffic, NLR_correctie_factor, seizoensinfo, filter);

% traffic_prognose = [prognose_dir ls([prognose_dir 'traffic*- mean.xls'])];
% Lden_scale       = 1.025;      % GA schaalfactor Lden 
% Lnight_scale     = 1.000;      % GA schaalfactor Lnight
% 
% % prognose
% HGden_prognose   = GPcalc_hg_traffic(traffic_prognose, Lden_scale);
% HGnight_prognose = GPcalc_hg_traffic(traffic_prognose, Lnight_scale,true);
% 
% % realisatie
% traffic            = {HV_traffic_realisatie, GA_traffic_realisatie};
% Lden_scale         = 1;      % geen schaling Lden 
% Lnight_scale       = 1;      % geen schaling Lnight
% HGden_realisatie   = GPcalc_hg_traffic(traffic, Lden_scale);
% HGnight_realisatie = GPcalc_hg_traffic(traffic, Lnight_scale,true);

%% Baangebruik - Etmaal
traffic_prognose = [prognose_dir ls([prognose_dir 'traffic*- years.txt'])];

traffic     = {traffic_prognose , traffic_realisatie};
period      = 'D|E|N';
aantal_rwys = 7;
sjabloon    = [svgt_dir 'FigBaangebruik_evaluatie.svgt'];
output_file = [out_dir 'Fig_3_2_Baangebruik_etmaal_gj2017.svg'];

GPfig_baangebruik(traffic, period, aantal_rwys, sjabloon, output_file);

%% Baangebruik - Nacht
traffic     = {traffic_prognose , traffic_realisatie};
period      = 'N';
aantal_rwys = 6;
sjabloon    = [svgt_dir 'FigBaangebruik_evaluatie.svgt'];
output_file = [out_dir 'Fig_3_3_Baangebruik_nacht_gj2017.svg'];

GPfig_baangebruik(traffic, period, aantal_rwys, sjabloon, output_file);

%% Vlootsamenstelling
traffic_prognose = [prognose_dir ls([prognose_dir 'traffic*- mean.txt'])];
traffic     = {traffic_prognose , traffic_realisatie};
sjabloon    = [svgt_dir 'FigVlootsamenstelling_evaluatie.svgt'];
output_file = [out_dir 'Fig_2_2_Vlootsamenstelling_gj2017.svg'];

GPfig_vlootsamenstelling(traffic, sjabloon, output_file);
copyfile('Vliegtuigjes', [out_dir 'Vliegtuigjes']);

% %% Etmaalverdeling
% 
% % prognose
% winter_traffic = [prognose_dir ls([prognose_dir 'traffic*winter*.txt'])];
% zomer_traffic  = [prognose_dir ls([prognose_dir 'traffic*zomer*.txt'])];
% sheet = 'etmaalverdeling (GP)';
% GPtab_etmaalverdeling({winter_traffic, zomer_traffic}, 'seizoen', {'winter', 'zomer'}, xls_output, sheet);
% 
% % realisatie
% sheet = 'etmaalverdeling';
% GPtab_etmaalverdeling(traffic_realisatie, 'seizoen', '', xls_output, sheet);

%% Sectorverdeling
traffic     = {traffic_prognose , traffic_realisatie};
sjabloon    = [svgt_dir 'FigSectorisatie_evaluatie.svgt'];
output_file = [out_dir 'Fig_2_3_Sectorverdeling_gj2017.svg'];

GPfig_sectorisatie(traffic, output_file, sjabloon, 'RouteSector.txt')

%% Prognose van het verkeer
prognose.year         = year;
prognose.verkeer      = 492100;
prognose.verkeer_min  = 483954;
prognose.verkeer_max  = 500000;  

%% Historie
%TODO: Vanuit deze m-code de xls aanvullen met tellingen uit de realisatie

history = 'history.xlsx';

%% Historisch perspectief - Verkeersvolume
sjabloon    = [svgt_dir 'FigVolume_evaluatie.svgt'];
output_file = [out_dir 'gj' num2str(year) ' Fig 2.1 Verkeersvolume.svg'];

GPfig_historisch_perspectief(history, prognose, sjabloon, output_file);

%% Verwachte milieueffecten, spreiding over meteojaren
%TODO moet dit zo ingewikkeld?
gwc_prognose      = gwc_prognose.my;        
gwc_prognose.year = year;

%% Historisch perspectief - Woningen Lden
sjabloon    = [svgt_dir 'FigWoningen_Lden_evaluatie.svgt'];
output_file = [out_dir 'gj' num2str(year) ' Fig 4.3 Woningen Lden.svg'];

GPfig_historisch_perspectief(history, gwc_prognose, sjabloon, output_file);

%% Historisch perspectief - Gehinderden Lden
sjabloon    = 'sjablonen\FigGehinderden_Lden_evaluatie.svgt';
output_file = [out_dir  'gj' num2str(year) ' Fig 4.4 Gehinderden Lden.svg'];

GPfig_historisch_perspectief(history, gwc_prognose, sjabloon, output_file);

%% Historisch perspectief - Woningen Lnight
sjabloon    = 'sjablonen\FigWoningen_Lnight_evaluatie.svgt';
output_file = [out_dir 'gj' num2str(year) ' Fig 4.5 Woningen Lnight.svg'];

GPfig_historisch_perspectief(history, gwc_prognose, sjabloon, output_file);

%% Historisch perspectief - Slaapverstoorden Lnight
sjabloon    = 'sjablonen\FigSlaapverstoorden_Lnight_evaluatie.svgt';
output_file = [out_dir  'gj' num2str(year) ' Fig 4.6 Slaapverstoorden Lnight.svg'];

GPfig_historisch_perspectief(history, gwc_prognose, sjabloon, output_file);

%% Geluidscontouren - PROGNOSE
%  inlezen grids

Lden_scale   = 1.025;      % schaalfactor Lden 
Lnight_scale = 1.000;      % schaalfactor Lnight

Lden_noise   = 'GP2017 001 Lden *';
Lnight_noise = 'GP2017 001 Lnight *';

Lden_mmyears   = setdiff(1971:2010,[1972,1976,1981,1990,1994,1996,2000,2003])';
Lnight_mmyears = setdiff(1971:2010,[1973,1979,1985,1989,1994,1995,1996,2002])';

Lden_multigrid   = GPcalc_gridimport(prognose_dir, Lden_noise,   Lden_scale,   Lden_mmyears);
Lnight_multigrid = GPcalc_gridimport(prognose_dir, Lnight_noise, Lnight_scale, Lnight_mmyears);

%% Geluidscontouren - Realisatie

% inlezen grids
Lden_realisatie   = read_envira([realisatie_dir '\Result_Lden_EHAM_2017']);
Lnight_realisatie = read_envira([realisatie_dir '\Result_Lnight_EHAM_2017']);

% toevoegen aan multigrid en bereken verschil
Lden_multigrid.realisatie   = Lden_realisatie.dat;
Lnight_multigrid.realisatie = Lnight_realisatie.dat;

Lden_multigrid.delta   = Lden_realisatie.dat -  Lden_multigrid.mean;
Lnight_multigrid.delta = Lnight_realisatie.dat -  Lnight_multigrid.mean ;

%% contouren
Lden_svg   = [out_dir 'GP2017 Evaluatie Lden.svg'];
Lnight_svg = [out_dir 'GP2017 Evaluatie Lnight.svg'];

plot2svg(Lden_multigrid,   [svgt_dir 'Lden_evaluatie.svgt'],   Lden_svg);
plot2svg(Lnight_multigrid, [svgt_dir 'Lnight_evaluatie.svgt'], Lnight_svg);

%% delta-plot
Lden_svg   = [out_dir 'GP2017 Evaluatie Lden - delta.svg'];
Lnight_svg = [out_dir 'GP2017 Evaluatie Lnight - delta.svg'];

plot2svg(Lden_multigrid,   [svgt_dir 'Lden_evaluatie_delta.svgt'],   Lden_svg);
plot2svg(Lnight_multigrid, [svgt_dir 'Lnight_evaluatie_delta.svgt'], Lnight_svg);

% %% Piekenpatroon/verkeersverdeling
% slond_cap   = 'slond capaciteit.xls';
% sjabloon    = [svgt_dir 'FigVerkeersverdeling.svgt'];
% 
% filter.field  = 'seizoen';
% filter.bin    = 20;
% 
% % winter
% periods       = [prognose_dir 'periods gp2017 001 winter.xls'];
% filter.values = 'winter';
% output_file = [out_dir 'gj2017 verkeersverdeling - winter.svg'];
% 
% GPfig_verkeersverdeling(traffic_realisatie, periods , slond_cap, seizoensinfo, sjabloon, output_file, filter);
% 
% % zomer
% periods       = [prognose_dir 'periods gp2017 001 zomer.xls'];
% filter.values = 'zomer';
% output_file = [out_dir 'gj2017 verkeersverdeling - zomer.svg'];
% 
% GPfig_verkeersverdeling(traffic_realisatie, periods , slond_cap, seizoensinfo, sjabloon, output_file, filter);

%% windroos

% polairegrafiek
KNMIdata = [realisatie_dir 'knmi_2011-2020.txt'];
sjabloon = [svgt_dir 'FigWindroos.svgt'];

% gebruiksjaar 2017
dagen = 20131101:20171031;
output_file = [out_dir 'gj2017 windroos.svg'];
GPfig_windroos(KNMIdata, dagen, sjabloon, output_file);

% KNMI data sinds 1971
KNMIdata = [realisatie_dir 'knmi_1971-2020.txt'];

% meteo in de prognose
jaren = 1971:2015;
output_file = [out_dir '1971-2012 windroos.svg'];
GPfig_windroos(KNMIdata, jaren, sjabloon, output_file);

% meteo in de grenswaarde: set07
jaren = [1973,1974,1982,1984,1987,1989,1993,1994,2003,2004];
output_file = [out_dir 'set07 windroos.svg'];
GPfig_windroos(KNMIdata, jaren, sjabloon, output_file);

%% Klaar
toc;
disp(['Calculations done. Please go to the <a href="matlab:dos(''explorer.exe /e, ' out_dir ', &'');">output directory</a> for results.'])