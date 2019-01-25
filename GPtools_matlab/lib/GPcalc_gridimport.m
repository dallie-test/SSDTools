function [multigrid] = GPcalc_gridimport (grid_dir, noise, scale, mmyears)
% Lees de grids in de opgegeven directory
%
% input
%  grid_dir   directory met de Daisy-grids
%  noise      te gebruiken noise als regular expression
%  scale      schaalfactor
%  mmyears    (optioneel) jaren waarvoor de meteotoeslag wordt bepaald
%             default wordt het grid met 'mm' niet berekend maar ingelezen 
%
%             Dit gaat niet goed (mmyear). Indien voor hybride model
%             bijvoorbeeld 1971-2015 wordt opgegeven, dan wordt mm berekend
%             over die periode terwijl dit 1971-2010 moet zijn. MA.
%
% outpuit
%  multigrid  TODO beschrijving toevoegen

%% Files van de noise
dat_files = GetFiles(grid_dir, noise);

%% Individuele meteojaren
grids = GetFiles(dat_files, '^*[yY]\d{4}[_.].*');
multigrid = read_envira_multi(grids);

% Meteojaren
my = regexp(grids, '[yY](\d{4})','tokens', 'once');
multigrid.myears = str2double(vertcat(my{:}));

% Bepaal grid met gemiddelde, bovengrens en ondergrens
multigrid = mean_multi(multigrid);
multigrid = std_multi(multigrid);
multigrid = betrouwbaarheid_multi(multigrid, 2.5758); % 99,5% TODO: hoe bereken je deze factor?

%% Grid inclusief meteotoeslag
if (nargin==3)
    pattern = strcat(my{1}, '-', my{end}, 'mm');
    grid_mm = GetFiles(dat_files, pattern);

    mm = read_envira(grid_mm);
    multigrid.mm = mm.dat;
else
    i = ismember(multigrid.myears, mmyears);
    multigrid.mm = squeeze(max(multigrid.dat(i,:,:),[],1));
    multigrid.mmyears = mmyears;
end

% Schaalfactor toepassen
multigrid = scale_multi(multigrid, scale);
