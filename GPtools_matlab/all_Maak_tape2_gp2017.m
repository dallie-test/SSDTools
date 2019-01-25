% debug
dbstop if error

%extern
addpath('lib')
addpath('external\teltool NLR\')
addpath('external\grid operations\')
addpath('external\SVG')

% init
all_dat = [];

svgt_dir       = [pwd '\sjablonen\'];

Scenario.Name = {
                 '001 Empirisch'                 
                 };
% Schaalfactoren
Lden_scale   = 1.025;
Lnight_scale = 1.000;

Lden_noise   = 'GP2017 - Lden.*';
Lnight_noise = 'GP2017 - Lnight.*';

for s=1:numel(Scenario.Name)
    scenario       = Scenario.Name{s};
    prognose_dir   = [pwd '\..\prognose\' scenario '\'];
    
    %output dir
    out_dir = [pwd '\..\results\' scenario '\'];
    mkdir(out_dir);
    
    %% Gridimport incl. Meteotoeslag
    Lden_mmyears   = setdiff(1971:2010,[1972,1976,1981,1990,1994,1996,2000,2003])';
    Lden_multigrid   = GPcalc_gridimport(prognose_dir, Lden_noise, Lden_scale, Lden_mmyears);

    Lnight_mmyears = setdiff(1971:2010,[1973,1979,1985,1989,1994,1995,1996,2002])';
    Lnight_multigrid = GPcalc_gridimport(prognose_dir, Lnight_noise, Lnight_scale, Lnight_mmyears);
    
    %% Maak tape2-bestand met contouren
    Lden_multigrid.mmyears   = Lden_mmyears;
    Lnight_multigrid.mmyears = Lnight_mmyears;

    % Inclusief mm
    Lden_mm   = noisegrid(Lden_multigrid, 'mm');
    Lnight_mm = noisegrid(Lnight_multigrid, 'mm');
    ContourPunten(Lden_mm,   [46:71], 'tape2', [out_dir scenario '_Lden'   '_mm.tape2']);
    ContourPunten(Lnight_mm, [38:65], 'tape2', [out_dir scenario '_Lnight' '_mm.tape2']);

    % Mean
    Lden_mean   = noisegrid(Lden_multigrid, 'mean');
    Lnight_mean = noisegrid(Lnight_multigrid, 'mean');
    ContourPunten(Lden_mean,   [46:71], 'tape2', [out_dir scenario '_Lden'   '_mean.tape2']);
    ContourPunten(Lnight_mean, [38:65], 'tape2', [out_dir scenario '_Lnight' '_mean.tape2']);

    % plotje
    plot2svg(Lden_multigrid, [svgt_dir 'Lden_sigma.svgt'], [out_dir scenario '_Lden.svg']);
    
    %% Gelijkwaardigheidscriteria
    % scale=1 want mm is reeds geschaald!
    gwc  = gelijkwaardigheid(Lden_mm, Lnight_mm, 1, 1);
    dat = [{scenario}, 'mm', num2cell(Lden_scale), num2cell(Lnight_scale), num2cell(gwc(1)), num2cell(gwc(3)), num2cell(gwc(2)), num2cell(gwc(4));];

    all_dat = [all_dat; dat];
end

% %uitvoer naar Excel
% xls_output = [pwd '\..\results\20160815 MER vs 510k.xls'];
% xls_sheet = 'MER_vs_510k';
% 
% hdr = {'scenario', 'scale', 'Lden_scale', 'Lnight_scale', 'w58den', 'eh48den', 'w48n', 'sv40n'};
% xlswrite(xls_output ,[hdr; all_dat] , xls_sheet, 'A1');