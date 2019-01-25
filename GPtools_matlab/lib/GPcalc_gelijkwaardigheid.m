function [gwc_struct] = GPcalc_gelijkwaardigheid(Lden_dir, Lden_noise, Lnight_dir, Lnight_noise, Lden_scale, Lnight_scale, Methode)
% Lees de grids in de opgegeven directory en bereken de gelijkwaardigheidscriteria
%
% input
%  Lden_dir      directory met de Lden-grids
%  Lnight_dir    directory met de Lnight-grids
%  Lden_noise    Lden-noise als regular expression
%  Lnight_noise  Lnight-noise als regular expression
%  Lden_scale    Lden schaalfactor
%  Lnight_scale  Lnight schaalfactor
%  Methode       (Optioneel) spline, nospline of mixed (default)
%
% output
%  gwc           gwc.w58den  aantal woninen binnen 58 dB(A) Lden
%                gwc.eh48den aantal ernstig gehinderden binnen 48 dB(A)Lden
%                gwc.w48n    aantal woninen binnen 48 dB(A) Lnight
%                gwc.sv40n   aantal ernstig slaapverstoorden binnen 40 dB(A) Lnight
%
%                gwc.my.w58den   idem maar dan voor individuele meteojaren en
%                                dus exclusief meteotoeslag en berekend met
%                                'nospline'
%                gwc.my.eh48den  idem
%                gwc.my.w48n     idem
%                gwc.my.sv40n    idem

%% Optioneel: Methode
if (nargin == 6)
    Methode = 'mixed';
end

switch Methode
    case 'spline'
        mm_Methode = 'spline';
        y_Methode  = 'spline';
    case 'nospline'
        mm_Methode = 'nospline';
        y_Methode  = 'nospline';
    case 'mixed'
        mm_Methode = 'spline';
        y_Methode  = 'nospline';
end
    
%% Files van de noise
Lden_dat   = GetFiles(Lden_dir,   Lden_noise);
Lnight_dat = GetFiles(Lnight_dir, Lnight_noise);

%% Individuele meteojaren
Lden_grids   = GetFiles(Lden_dat,   '^*[yY]\d{4}[_.].*');
Lnight_grids = GetFiles(Lnight_dat, '^*[yY]\d{4}[_.].*');

% Meteojaren
my = regexp(Lden_grids, '[yY](\d{4})','tokens', 'once');
gwc_struct.myears = str2double(vertcat(my{:}));

%% Grid inclusief meteotoeslag
pattern = strcat('mm'); % Veranderd door MA. Alleen op mm zoeken, voldoende voor mm files en robuster indien jaren afwijken.
Lden_grid_mm   = GetFiles(Lden_dat,   pattern);
Lnight_grid_mm = GetFiles(Lnight_dat, pattern);

%% Tellingen
disp('Voer tellingen uit op Lden en Lnight grids')
disp(' ')
disp('   mm/year     w58den       w48n    eh48den      sv40n')
disp('---------- ---------- ---------- ---------- ----------')

gwc_mm = gelijkwaardigheid(Lden_grid_mm, Lnight_grid_mm, Lden_scale, Lnight_scale, mm_Methode);
fprintf('  incl. mm %10.0f %10.0f %10.0f %10.0f\n', gwc_mm)

for i=1:numel(Lden_grids)
    gwc_my(i,:) = gelijkwaardigheid(Lden_grids{i}, Lnight_grids{i}, Lden_scale, Lnight_scale, y_Methode);
    fprintf('%10.0f %10.0f %10.0f %10.0f %10.0f\n', gwc_struct.myears(i), gwc_my(i,:))
end

%% Maak structure
gwc_struct.w58den     = gwc_mm(1);
gwc_struct.w48n       = gwc_mm(2);
gwc_struct.eh48den    = gwc_mm(3);
gwc_struct.sv40n      = gwc_mm(4);

gwc_struct.my.w58den  = gwc_my(:,1);
gwc_struct.my.w48n    = gwc_my(:,2);
gwc_struct.my.eh48den = gwc_my(:,3);
gwc_struct.my.sv40n   = gwc_my(:,4);

