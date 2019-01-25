function [grid_struct]=read_envira(filenaam)
% read_envira makes a grid structure for ONE envira files
%
% input:
%   enviragrid      filename of an envira grid file
%
% Opmerking:
% om het resultaat gelijk te houden aan read_enviraformat van het NLR
% wordt de matrix getransformeerd. Eigenlijk raar want het resultaat
% is dan: dat(y,x) met dimensies (ny,nx).

%% Lees file

% Open file
if isstruct(filenaam)
    % dit is al een struct!
    grid_struct = filenaam;
    return
elseif iscell(filenaam);
    fid=fopen(filenaam{:});
else
    fid=fopen(filenaam);
end

% Header info
[hdr] = read_envira_header(fid);
    
% Noisedata
dat = textscan(fid, '%f', hdr.nx*hdr.ny);
dat = reshape(cell2mat(dat), hdr.nx, hdr.ny)';

% Maak een structure
grid_struct.hdr = hdr;
grid_struct.dat = dat;

% Close
fclose(fid);