function [grid_struct]=noisegrid(Multigrid, datName)
% Maak een noisegrid structure met een hdr en dat
%
% input
%   Multigrid       multigrid structure zoals ingelezen met
%                   read_envira_multi
%   datName         veldnaam van het noisegrid

%% start routine
if isstruct(Multigrid.(datName))
    grid_struct.hdr = Multigrid.(datName).hdr;
    grid_struct.dat = Multigrid.(datName).dat;
else
    grid_struct.hdr = Multigrid.hdr;
    grid_struct.dat = Multigrid.(datName);
end
    