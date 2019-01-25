function [V_struct] = GPcalc_inpasbaarvolume(Lden_dir, Lden_noise, Lnight_dir, Lnight_noise, Lden_scale, Lnight_scale, Verkeersvolume)
% Lees de grids in de opgegeven directory en bereken het inpasbaar
% verkeersvolume binnen de gelijkwaardigheidscriteria voor Lden
%
% input
%  Lden_dir               directory met de Lden-grids
%  Lnight_dir             directory met de Lnight-grids
%  Lden_noise             Lden-noise als regular expression
%  Lnight_noise           Lnight-noise als regular expression
%  Lden_scale             Lden schaalfactor voor GA verkeer
%  Lnight_scale           Lnight schaalfactor voor GA verkeer
%
% output
%  V_struct.volume        Inpasbaar volume binnen alle criteria

%% Files van de noise
Lden_dat   = GetFiles(Lden_dir,   Lden_noise);
Lnight_dat = GetFiles(Lnight_dir, Lnight_noise);

%% Individuele meteojaren
Lden_grids   = GetFiles(Lden_dat,   '^*[yY]\d{4}[_.].*');
Lnight_grids = GetFiles(Lnight_dat, '^*[yY]\d{4}[_.].*');

% Meteojaren
my = regexp(Lden_grids, '[yY](\d{4})','tokens', 'once');
V_struct.myears = str2double(vertcat(my{:}));

%% Grid inclusief meteotoeslag
pattern = strcat('mm'); % Veranderd door MA. Alleen op mm zoeken, voldoende voor mm files en robuster indien jaren afwijken.
Lden_grid_mm   = GetFiles(Lden_dat,   pattern);
Lnight_grid_mm = GetFiles(Lnight_dat, pattern);

%% Initialisatie van de schaling
%gwc_goal = [11900 11000 180500 49000]; %empirisch model
gwc_goal = [12200 11100 180000 49500]; disp('grenzen gecorrigeerd empirisch model:');
%gwc_goal = [12200 11400 181500 51500]; disp('grenzen hybride model:');

disp(['GWC-grenzen: WDEN58: ' num2str(gwc_goal(1)) ', WNIGHT48: ' num2str(gwc_goal(2)) ', EGHDEN48: ' num2str(gwc_goal(3)) ', ESLVSNIGHT40: ' num2str(gwc_goal(4))])

disp('Inpasbaar volume handelsverkeer')
disp(' ')
disp('    volume  %gwc  %vol')
disp('---------- ----- -----')


%parameter om te zoeken naar het maximale volume
search_depth = 5;
search_width = 2;
volume_low_ini  = 450000;
volume_high_ini = 600000;

gwc_low = gelijkwaardigheid(Lden_grid_mm, Lnight_grid_mm, Lden_scale*volume_low_ini/Verkeersvolume, Lnight_scale*volume_low_ini/Verkeersvolume);
gwc_high = gelijkwaardigheid(Lden_grid_mm, Lnight_grid_mm, Lden_scale*volume_high_ini/Verkeersvolume, Lnight_scale*volume_high_ini/Verkeersvolume);

%volume low en high moeten de grenzen aangeven. Low mag dus niet
%overschrijden, high moet minimaal één overschrijden.
if any(gwc_low>gwc_goal)
    gwc_goal 
    gwc_low
    error('Variable volume_low is set to optimistic. Please decrease value in order to prevent an immediate violation.')
end

if all(gwc_high<gwc_goal)
    gwc_goal 
    gwc_high
    error('Variable volume_high is set to pessimistic. Please increase value in order to obtain a (desired) violation of at least one criteria.')
end

%% start searching for optimal value DEN
volume_high = volume_high_ini;
volume_low = volume_low_ini;

for i_depth=1:search_depth
    d = volume_high-volume_low;
    step = d/(search_width+1);
    volumes = round(volume_low+step*[1:search_width]);
    
    for i_width=1:search_width
        gwc_score= gelijkwaardigheid(Lden_grid_mm, Lnight_grid_mm, Lden_scale*volumes(i_width)/Verkeersvolume, Lnight_scale*volumes(i_width)/Verkeersvolume);
        overschrijding(i_width) = any(gwc_score>gwc_goal);
        utilization = max(gwc_score./gwc_goal);
        fprintf('%10.0f %5.3f %5.3f   \n', volumes(i_width), utilization, Lden_scale*volumes(i_width)/Verkeersvolume);
    end
    
    %er zijn nu drie mogelijkheden. Of alle tussenliggende volumes
    %overschrijden, of ze overschrijden allemaal niet, of een deel
    %overschrijdt. Als alles overschrijdt, neem x_low en het eerste
    %tussenvolume. Als niks overschrijdt, neem het laatste volume en
    %x_high. Als er een deel overschrijdt, neem dan het laatste volueme
    %wat niet overscrhijdt en het eerste volume wat wel overschrijdt.
    if all(overschrijding)
        volume_high = volumes(1);
    elseif ~any(overschrijding)
        volume_low = volumes(end);
    else
        volume_low = volumes(find(overschrijding,1)-1);
        volume_high = volumes(find(overschrijding,1));
    end
end
V_struct.gwc_score = gelijkwaardigheid(Lden_grid_mm, Lnight_grid_mm, Lden_scale*volume_low/Verkeersvolume, Lnight_scale*volume_low/Verkeersvolume);
V_struct.volume = volume_low;

fprintf('\n')