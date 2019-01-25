function [multigrid_struct]=read_envira_multi(filenaam)
% read_envira makes a grid structure for one ore more envira files
%
% input:
%   enviragrid      filename(s) of an envira grid file in a cell array
%
% Opmerking:
% om het resultaat gelijk te houden aan read_enviraformat van het NLR
% wordt de matrix getransformeerd. Eigenlijk raar want het resultaat
% is dan: dat(y,x) met dimensies (ny,nx).

%% Lees files
% ... multigrid
Nfiles = size(filenaam,1);
filenaam
for i=1:Nfiles
    [grid_struct] = read_envira(filenaam{i});

    % dim multigrid, zou sneller moeten zijn
    if i==1 
        multigrid=zeros(Nfiles,grid_struct.hdr.ny, grid_struct.hdr.nx);
    end
    
    multigrid(i,:,:)= grid_struct.dat;
end

% Maak een structure
multigrid_struct.hdr = grid_struct.hdr;
multigrid_struct.dat = multigrid;