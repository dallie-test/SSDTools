function [multigrid_struct]=betrouwbaarheid_multi(multigrid_struct, factor)
% Voeg betrouwbaarheidsinterval toe aan multigrid structure
%
% input
%   multigrid_struct  multigrid structure zoals ingelezen met
%                     read_envira_multi
%   factor            op std t.o.v. van mean: x = mean +/- factor x std

%% start routine

%TODO check of mean en std bestaan
multigrid_struct.dhi = multigrid_struct.mean + factor * multigrid_struct.std;
multigrid_struct.dlo = multigrid_struct.mean - factor * multigrid_struct.std;

