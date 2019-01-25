function [multigrid_struct]=scale_multi(multigrid_struct, factor, dat)
% Add scale factor to grid structure
%
% input
%   multigrid_struct  multigrid structure zoals ingelezen met
%                     read_envira_multi
%   dat               (optioneel) namen van de noisegrids

%Zet defaults voor ontbrekende parameters
if(nargin < 3)
    dat = {'dat', 'mean', 'std', 'dhi', 'dlo', 'mm'};
end

if ~isfield(multigrid_struct, 'scale')
    multigrid_struct.scale = 1;
end

%% start routine
for i=1:numel(dat)
    if isfield(multigrid_struct, dat(i))
        multigrid_struct.(dat{i}) = multigrid_struct.(dat{i}) + 10*log10(factor);
    end
end

% Metadata
multigrid_struct.scale = multigrid_struct.scale * factor;
   