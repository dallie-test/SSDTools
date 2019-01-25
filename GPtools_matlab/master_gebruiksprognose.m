% debug
clc;clear all;close all; % MA.

global Verkeer_scale
dbstop if error
tic

%extern
addpath('lib')
addpath('external\teltool NLR\')
addpath('external\grid operations\')
addpath('external\SVG')

% oude resultaten gebruiken (false) of opnieuw rekenen (true)?
forcecalc = true;

%als er met de nieuwe meteotoeslagmethode (maxiumum) van de representatieve
%jaren, dan hoort deze op true en wordt het grid overschreven. Anders
%blijft het oude grid (waarbij meteotoeslag met baangebruik wordt bepaald) 
%staan. 
nieuwe_meteotoeslagmethode = true;
representatieve_jaren_lden = setdiff(1971:2010,[1972,1976,1981,1990,1994,1996,2000,2003])';
representatieve_jaren_lnight = setdiff(1971:2010,[1973,1979,1985,1989,1994,1995,1996,2002])';

% nieuwe GA methode gebruikt GA verkeer uit 2015 geschaald naar gemiddeld
% weer.
nieuwe_GAmethode = false;

% directory's
scenario_dir = '001 Hybride\';

if nieuwe_GAmethode
    orig_prog_dir   = [pwd '\..\prognose\' scenario_dir];
    scenario_dir    = [scenario_dir 'Nieuwe GA methode\'];
end

prognose_dir  = [pwd '\..\prognose\' scenario_dir];
svgt_dir      = [pwd '\sjablonen\'];
out_dir       = [pwd '\..\results\' scenario_dir];

%output dir
mkdir(out_dir);

%uitvoer naar Excel
if nieuwe_GAmethode
    add = ' GA';
    try
        rmdir(prognose_dir(1:end-1),'s');
    end
    copyfile(orig_prog_dir,prognose_dir);    
else
    add = '';
end

xls_output = [out_dir 'GP2017 tabellen.xls']; 
copyfile([svgt_dir 'sjabloon.xls'], xls_output);

%sub-dir voor figuren
out_dir = [out_dir 'svg\'];
mkdir(out_dir);

% achtergrond en scripts kopieeren
copyfile([svgt_dir 'Schiphol_RD900dpi.png'], out_dir);
copyfile(which('svg2png.sh'), out_dir);
copyfile(which('svg2pdf.sh'), out_dir);

%% bepaal het aantal dagen per seizoen in het gebruiksjaar
year = 2017;
Gebruiksjaar = GPcalc_gebruiksjaar(year);

%% totaal aan volume bepalen
traffic = read_traffic([prognose_dir ls([prognose_dir 'traffic*- mean.txt'])]);
verkeer = sum(traffic.total);

%% inlezen grids, stats berekenen en berekenen gelijkwaardigheidsdata tabel 4.1 en figuur 5.3 t/m figuur 5.6
Lden_noise   = 'GP2017 - Lden.*';
Lnight_noise = 'GP2017 - Lnight.*';

% Nieuwe methode voor GA verkeer.
if nieuwe_GAmethode
   % Dir met GA grids
   GAgriddir = [pwd '\..\prognose\GA 2015'];
   
   % Schaal factoren voor nieuwe GA methode zijn 1.000 tenzij
   % verkeersopschaling.
   Lden_scale   = 1.000;    % Schaalfactor Lden
   Lnight_scale = 1.000;    % Schaalfactor Lnight
   
   % Melding in scherm
   disp('!!! LET OP: hardcoded schaalfactor voor DEN volume naar 492k is aanwezig. !!!');
   disp('    Toepassen nieuwe GA methode');
   
   % Run nieuwe GA berekening
   Lden_noise = GPcalc_nieuw_GA(GAgriddir,Lden_noise,prognose_dir,verkeer,year,Lden_scale);    
else
    % Oude methode: opschalen dag met 2.5%.
    fprintf('\n%s\n','Toepassen van 2.5% schaling op etmaal grid geluidbelasting i.v.m. GA');
    Lden_scale   = 1.025; % GA scale (oude methode);
    Lnight_scale = 1.000; % Schaalfactor Lnight
end

% Nieuwe meteo voor het eerst toegepast in GP2016.
if nieuwe_meteotoeslagmethode
    GPcalc_nieuw_meteotoeslaggrid(prognose_dir,Lden_noise,representatieve_jaren_lden);
    GPcalc_nieuw_meteotoeslaggrid(prognose_dir,Lnight_noise,representatieve_jaren_lnight);
end

if ~forcecalc
    if exist('GPresults.mat', 'file')
        load('GPresults.mat')
    end
end
savemat = false;

if forcecalc || ~exist('Lden_multigrid', 'var')
    Lden_multigrid   = GPcalc_gridimport(prognose_dir, Lden_noise, Lden_scale,representatieve_jaren_lden);
    savemat = true;
end

if forcecalc || ~exist('Lnight_multigrid', 'var')
    Lnight_multigrid = GPcalc_gridimport(prognose_dir, Lnight_noise, Lnight_scale,representatieve_jaren_lnight);
    savemat = true;
end

if forcecalc || ~exist('gwc', 'var')
    gwc = GPcalc_gelijkwaardigheid(prognose_dir, Lden_noise, prognose_dir, Lnight_noise, Lden_scale, Lnight_scale,'spline');
    savemat = true;
else
    % Opgeslagen resultaten printen
    disp('Gelijkwaardigheidscriteria')
    disp(' ')
    disp('        mm     w58den       w48n    eh48den      sv40n')
    disp('---------- ---------- ---------- ---------- ----------')
    fprintf('  incl. mm %10.0f %10.0f %10.0f %10.0f\n', gwc.w58den,gwc.w48n, gwc.eh48den,gwc.sv40n)
    disp(' ')
end

%% data tabel 4.1
sheet = 'gwc';
GPtab_gelijkwaardigheid(gwc, xls_output, sheet);

if forcecalc || ~exist('Vgwc', 'var')
    Vgwc = GPcalc_inpasbaarvolume(prognose_dir, Lden_noise, prognose_dir, Lnight_noise, Lden_scale, Lnight_scale, verkeer);
    %bepaling HG
    traffic     = [prognose_dir ls([prognose_dir 'traffic*- mean.txt'])];
    HG_FILE_DEN = strcat([prognose_dir ls([prognose_dir '*_HG_DEN.txt'])]);
    
    if (size(HG_FILE_DEN,1)==0)
        HG_DEN = GPcalc_hg_traffic(traffic, Lden_scale);
    elseif (size(HG_FILE_DEN,1)==1)
        HG_fid = fopen(HG_FILE_DEN);
        HG_DEN = textscan(HG_fid,'%f');
        fclose(HG_fid);
        HG_DEN = HG_DEN{1} + 10*log10(Lden_scale);
    else
        error('more than one HG found');
    end
        
    HG_FILE_NIGHT = strcat([prognose_dir ls([prognose_dir '*_HG_NIGHT.txt'])]);
    
    if (size(HG_FILE_NIGHT,1)==0)
        HG_NIGHT = GPcalc_hg_traffic(traffic, Lnight_scale,true) - 10.0 + 10*log10(24/8);
    elseif (size(HG_FILE_NIGHT,1)==1)
        HG_fid = fopen(HG_FILE_NIGHT);
        HG_NIGHT = textscan(HG_fid,'%f');
        fclose(HG_fid);
        HG_NIGHT = HG_NIGHT{1} + 10*log10(Lnight_scale) - 10.0 + 10*log10(24/8);
    else
        error('more than one HG found');
    end
    
    MHG_DEN = HG_DEN + 10*log10(Vgwc.volume/verkeer)
    warning('HG_night nog bepaald op basis van schaalfactor DEN, nog aanpassen!')
    MHG_NIGHT = HG_NIGHT + 10*log10(Vgwc.volume/verkeer)
    
    savemat = true;
else 
    % Opgeslagen resultaten printen
    %TODO: controleren of dit nog werkt
%     disp('Inpasbaar volume handelsverkeer')
%     disp(' ')
%     disp('    w58den   xHV  xTot      eh48den   xHV  xTot')
%     disp('---------- ----- -----   ---------- ----- -----')
%     fprintf('%10.0f %5.3f %5.3f   ', Vgwc.w58den.vtb, Vgwc.w58den.scale, Vgwc.w58den.scale*Lden_scale)
%     fprintf('%10.0f %5.3f %5.3f\n', Vgwc.eh48den.vtb, Vgwc.eh48den.scale, Vgwc.eh48den.scale*Lden_scale)
    disp(' ')
end

if savemat % de nieuw berekende resultaten opslaan
    save('GPresults.mat', 'Lden_multigrid', 'Lnight_multigrid', 'gwc', 'Vgwc')
end

%% figuur 5.1 en 5.2
Lden_svg   = [out_dir 'gp' num2str(year) ' Fig 5.1 Lden sigma' add '.svg'];
Lnight_svg = [out_dir 'gp' num2str(year) ' Fig 5.2 Lnight sigma' add '.svg'];

plot2svg(Lden_multigrid,   [svgt_dir 'Lden_sigma.svgt'],   Lden_svg);
plot2svg(Lnight_multigrid, [svgt_dir 'Lnight_sigma.svgt'], Lnight_svg);

%% bijlage 2 flood-plot's

% %TODO: plotten van de clusterkaarten is nu zeer inefficient, de contouren
% %worden voor ieder cluster opnieuw berekend.
%
% Idee: maak de contouren aan in een bestand dat bij de deelkaarten
%       wordt ingelezen als SVG/image
 
% Lden
sjabloon = GetFiles(svgt_dir, '^Lden_fill.*\.svgt');
GPfig_floodplots(Lden_multigrid, sjabloon, out_dir);
 
% Lnight
sjabloon = GetFiles(svgt_dir, '^Lnight_fill.*\.svgt');
GPfig_floodplots(Lnight_multigrid, sjabloon, out_dir);

%% Maak verschil met vorige GP
% inlezen grids vorige GP (hybride)
Lden_GPprev   = read_envira('K:\D-CD\SSD\(b) CAP-EC\01 Kernactiviteiten\OP-Declaratie\2016\Berekeningen\prognose\GP2016 hybride 001\gp2016 LDEN 001 1971-2014.dat');
Lnight_GPprev = read_envira('K:\D-CD\SSD\(b) CAP-EC\01 Kernactiviteiten\OP-Declaratie\2016\Berekeningen\prognose\GP2016 hybride 001\gp2016 LNIGHT 001 1971-2014.dat');

% toevoegen aan multigrid en bereken verschil
Lden_multigrid.realisatie   = Lden_GPprev.dat;
Lnight_multigrid.realisatie = Lnight_GPprev.dat;

Lden_multigrid.delta   = Lden_multigrid.mean   - Lden_GPprev.dat;
Lnight_multigrid.delta = Lnight_multigrid.mean - Lnight_GPprev.dat;

Lden_svg   = [out_dir 'GP2017 vs GP2016 Lden' add '.svg'];
Lnight_svg = [out_dir 'GP2017 vs GP2016 Lnight.svg'];

plot2svg(Lden_multigrid,   [svgt_dir 'Lden_evaluatie.svgt'],   Lden_svg);
plot2svg(Lnight_multigrid, [svgt_dir 'Lnight_evaluatie.svgt'], Lnight_svg);

Lden_svg   = [out_dir 'GP2017 Lden - delta' add '.svg'];
Lnight_svg = [out_dir 'GP2017 Lnight - delta.svg'];

plot2svg(Lden_multigrid,   [svgt_dir 'Lden_delta_MER.svgt'],   Lden_svg);
plot2svg(Lnight_multigrid, [svgt_dir 'Lnight_delta_MER.svgt'], Lnight_svg);

%% indien beschikbaar, maak verschil met onderhoudssituatie
Lden_GPprev   = read_envira('K:\D-CD\SSD\(b) CAP-EC\01 Kernactiviteiten\OP-Declaratie\2017\Berekeningen\prognose\001 hybride\GP2017 - LDEN 1971-2015.dat');
Lnight_GPprev = read_envira('K:\D-CD\SSD\(b) CAP-EC\01 Kernactiviteiten\OP-Declaratie\2017\Berekeningen\prognose\001 hybride\GP2017 - LNIGHT 1971-2015.dat');

% toevoegen aan multigrid en bereken verschil
Lden_multigrid.realisatie   = Lden_GPprev.dat;
Lnight_multigrid.realisatie = Lnight_GPprev.dat;

Lden_multigrid.delta   = Lden_multigrid.mean   - Lden_GPprev.dat;
Lnight_multigrid.delta = Lnight_multigrid.mean - Lnight_GPprev.dat;

Lden_svg   = [out_dir 'GP2017 nominaal vs verstoord Lden' add '.svg'];
Lnight_svg = [out_dir 'GP2017 nominaal vs verstoord Lnight.svg'];

plot2svg(Lden_multigrid,   [svgt_dir 'Lden_evaluatie.svgt'],   Lden_svg);
plot2svg(Lnight_multigrid, [svgt_dir 'Lnight_evaluatie.svgt'], Lnight_svg);

Lden_svg   = [out_dir 'GP2017 nominaal vs verstoord Lden - delta' add '.svg'];
Lnight_svg = [out_dir 'GP2017 nominaal vs verstoord Lnight - delta.svg'];

plot2svg(Lden_multigrid,   [svgt_dir 'Lden_delta_MER.svgt'],   Lden_svg);
plot2svg(Lnight_multigrid, [svgt_dir 'Lnight_delta_MER.svgt'], Lnight_svg);

%% tabel 3.2
traffic = [prognose_dir ls([prognose_dir 'traffic*- pref.txt'])];
sheet   = 'preferenties';

% Empirisch model loopt hier vaast aangezien baancombinaties niet bekend
% zijn, nog fixen. MA.
GPtab_preferenties(traffic, 'Baancombinaties.txt', xls_output, sheet);

%% figuur 3.3
traffic     = [prognose_dir ls([prognose_dir 'traffic*- years.txt'])];
period      = 'D|E|N';
aantal_rwys = 7;
sjabloon    = [svgt_dir 'FigBaangebruik.svgt'];
output_file = [out_dir 'gp' num2str(year) ' Fig 3.3 baangebruik etmaal.svg'];

GPfig_baangebruik(traffic, period, aantal_rwys, sjabloon, output_file);

%bijbehorende tabel 3.3
sheet       = 'baangebruik (etmaal)';
GPtab_baangebruik(traffic, period, xls_output, sheet);

%% figuur 3.4
traffic     = [prognose_dir ls([prognose_dir 'traffic*- years.txt'])];
period      = 'N';
aantal_rwys = 4;
sjabloon    = [svgt_dir 'FigBaangebruik.svgt'];
output_file = [out_dir 'gp' num2str(year) ' Fig 3.4 baangebruik nacht.svg'];

GPfig_baangebruik(traffic, period, aantal_rwys, sjabloon, output_file);

%bijbehorende tabel 3.3
sheet       = 'baangebruik (nacht)';
GPtab_baangebruik(traffic, period, xls_output, sheet);
 
%% figuur 2.3
traffic     = [prognose_dir ls([prognose_dir 'traffic*- mean.txt'])];
sjabloon    = [svgt_dir 'FigVlootsamenstelling.svgt'];
output_file = [out_dir 'gp' num2str(year) ' Fig 2.3 vlootsamenstelling.svg'];

GPfig_vlootsamenstelling(traffic, sjabloon, output_file);
copyfile('Vliegtuigjes', [out_dir 'Vliegtuigjes']);
% 
%% figuur 2.4
traffic     = [prognose_dir ls([prognose_dir 'traffic*- mean.txt'])];
sjabloon    = [svgt_dir 'FigSectorisatie.svgt'];
output_file = [out_dir 'gp' num2str(year) ' Fig 2.4 sectorverdeling.svg'];

GPfig_sectorisatie(traffic, output_file, sjabloon, 'RouteSector.txt')

%% figuur 2.2

% Empirisch model loopt hier vaast aangezien winter/zomer niet meekomen in
% export, nog fixen. MA.

winter_traffic = [prognose_dir ls([prognose_dir 'traffic*winter*.txt'])];
zomer_traffic  = [prognose_dir ls([prognose_dir 'traffic*zomer*.txt'])];
sjabloon       = [svgt_dir 'FigEtmaalverdeling.svgt'];
output_file    = [out_dir 'gp' num2str(year) ' Fig 2.2 etmaal seizoen.svg'];

GPfig_etmaalverdeling(winter_traffic, zomer_traffic, Gebruiksjaar.winter.dagen, Gebruiksjaar.zomer.dagen, sjabloon, output_file);

%bijbehorende tabel 2.2
sheet = 'etmaalverdeling';
GPtab_etmaalverdeling({winter_traffic, zomer_traffic}, 'seizoen', {'winter', 'zomer'}, xls_output, sheet);

%% Historie
history = 'history.xlsx';

%% Het verkeer in het scenario
prognose.year         = [year-1, year];
prognose.verkeer      = [470841, verkeer];
prognose.verkeer_min  = [470841, 483954];
prognose.verkeer_max  = [470841, 500000];

%% figuur 2.1 - verkeersvolume
sjabloon    = [svgt_dir 'FigVolume.svgt'];
output_file = [out_dir 'gp' num2str(year) ' Fig 2.1 volume.svg'];

GPfig_historisch_perspectief(history, prognose, sjabloon, output_file);

%% Verwachte milieueffecten, spreiding over meteojaren 
prognose_gwc      = gwc.my;        
prognose_gwc.year = year;

%% figuur 5.3 - aantal woningen etmaal
sjabloon    = [svgt_dir 'FigWoningen_Lden.svgt'];
output_file = [out_dir 'gp' num2str(year) ' Fig 5.3 woningen Lden' add '.svg'];

GPfig_historisch_perspectief(history, prognose_gwc, sjabloon, output_file);

%% figuur 5.4 - gehinderden
sjabloon    = [svgt_dir 'FigGehinderden_Lden.svgt'];
output_file = [out_dir 'gp' num2str(year) ' Fig 5.4 gehinderden Lden' add '.svg'];

GPfig_historisch_perspectief(history, prognose_gwc, sjabloon, output_file);

%% figuur 5.5 - woningen nacht
sjabloon    = [svgt_dir 'FigWoningen_Lnight.svgt'];
output_file = [out_dir 'gp' num2str(year) ' Fig 5.5 woningen Lnight.svg'];

GPfig_historisch_perspectief(history, prognose_gwc, sjabloon, output_file);

%% figuur 5.6 - slaapverstoring
sjabloon    = [svgt_dir 'FigSlaapverstoorden_Lnight.svgt'];
output_file = [out_dir 'gp' num2str(year) ' Fig 5.6 slaapverstoorden Lnight.svg'];

GPfig_historisch_perspectief(history, prognose_gwc, sjabloon, output_file);

%% piekenpatroon/verkeersverdeling

% Empirisch model loopt hier vaast aangezien winter/zomer niet meekomen in
% export, nog fixen. MA.

slond_cap      = '\slond capaciteit.xls';
sjabloon       = [svgt_dir 'FigVerkeersverdeling.svgt'];

% winter
winter_traffic = [prognose_dir ls([prognose_dir 'traffic*winter*.txt'])];
winter_periods = [prognose_dir ls([prognose_dir 'periods*winter*.xls'])];
output_file    = [out_dir 'gp' num2str(year) ' verkeersverdeling - winter.svg'];

GPfig_verkeersverdeling(winter_traffic, winter_periods, slond_cap, Gebruiksjaar.winter.dagen, sjabloon, output_file);

%winter - piekenpatroon berekend obv traffic
output_file    = [out_dir 'gp' num2str(year) ' verkeersverdeling berekend - winter.svg'];

GPfig_verkeersverdeling(winter_traffic, 0.95, slond_cap, Gebruiksjaar.winter.dagen, sjabloon, output_file);

% zomer
zomer_traffic  = [prognose_dir ls([prognose_dir 'traffic*zomer*.txt'])];
zomer_periods  = [prognose_dir ls([prognose_dir 'periods*zomer*.xls'])];
output_file    = [out_dir 'gp' num2str(year) ' verkeersverdeling - zomer.svg'];

GPfig_verkeersverdeling(zomer_traffic, zomer_periods, slond_cap, Gebruiksjaar.zomer.dagen, sjabloon, output_file);

output_file    = [out_dir 'gp' num2str(year) ' verkeersverdeling berekend - zomer.svg'];

GPfig_verkeersverdeling(zomer_traffic, 0.95, slond_cap, Gebruiksjaar.zomer.dagen, sjabloon, output_file);
%% klaar
toc

disp(['Calculations done. Please go to the <a href="matlab:dos(''explorer.exe /e, ' out_dir ', &'');">output directory</a> for results.'])