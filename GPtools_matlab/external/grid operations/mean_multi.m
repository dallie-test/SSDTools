function [multigrid_struct]=mean_multi(multigrid_struct)
% Add mean grid to grid structure
%
% input
%   multigrid_struct  multigrid structire zoals ingelezen met
%                     read_envira_multi

%% start routine
y=mean(multigrid_struct.dat,1);
multigrid_struct.mean(:,:)=y(1,:,:);
