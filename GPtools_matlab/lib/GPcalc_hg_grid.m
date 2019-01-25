function HG = GPcalc_hg(grid, scale, nx, ny, details)
% Bereken de Hoeveelheid Geluid (HG).
%
% Input
%   grid      geluidgrid
%   scale     schaalfactor (optioneel)
%   nx        aantal punten in x-ricting (optioneel)
%   ny        aantal punten in y-ricting (optioneel)
%   details   resultaten bepalen voor oplopende gridgrootte in x-richting (optioneel)
%
% Output
%   hg        hoeveelheid geluid, totaal of cummulatief in x-richting
%             (array met lengte nx)

%% Zet defaults voor optionele parameters
if(nargin < 2), scale = 1; end             % geen opschaling
if(nargin < 3), nx = size(grid,2); end       % aantal punten in x-richting
if(nargin < 4), ny = size(grid,1); end       % aantal punten in y-richting
if(nargin < 5), details = 'noDetails'; end % geen details

% Debug
fprintf('Aantal punten in x-,y-richting: %2.0f, %2.0f\n', nx, ny);

%% Conversie naar hindersommen en schaalfactor toepassen
hs = 10.^(grid/10) * scale;

%% Bereken energetisch gemiddelde geluidbelasting
if strcmpi(details, 'details')
    for i=1:nx
        hs_sum(i) = sum(hs(1:ny,i));
        HG(i) = 10*log10(sum(hs_sum(1:i))/(ny*i));
    end
else
    HG = 10*log10(sum(hs(:))/(nx*ny));
end