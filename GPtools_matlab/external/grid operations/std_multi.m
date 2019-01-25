function [multigrid_struct]=std_multi(multigrid_struct)
% Add standard deviation grid to grid structure
%
% input
%   multigrid_struct  multigrid structure zoals ingelezen met
%                     read_envira_multi

%% start routine
y=std(multigrid_struct.dat,0,1);
multigrid_struct.std(:,:)=y(1,:,:);
