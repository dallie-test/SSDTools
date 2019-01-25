function [result] = gelijkwaardigheid(Lden_grid, Lnight_grid, Lden_scale, Lnight_scale, Splining, Regime)
% Bereken de gelijkwaardigheidscriteria voor de grids met opgegeven schaalfactor.
% Dit is een wrapper-functie voor geluidstellingen.m en de tel-tools van Ramon
%
% input
%  Lden_grid     Daisy-Lden-grids (file of struct)
%  Lnight_dir    Daisy-Lnight-grids (file of struct)
%  Lden_scale    Lden schaalfactor
%  Lnight_scale  Lnight schaalfactor
%  Splining      (optioneel) String 'spline' of 'nospline'
%                spline   - NLR algoritme voor 'smooth' contouren
%                nospline - zonder splining obv de tool van Ramon 
%  Regime        vector met selectie van de uitvoer [0 0 1 0] is allen
%                gehinderden
% output
%  result        vector met:
%                aantal woninen binnen 58 dB(A) Lden
%                aantal woninen binnen 48 dB(A) Lnight
%                aantal ernstig gehinderden binnen 48 dB(A)Lden
%                aantal ernstig slaapverstoorden binnen 40 dB(A) Lnight

%% Default alle resultaten
if(nargin < 6)
    Regime = [1 1 1 1];
end

%% Inlezen file of gebruik struct
if isstruct(Lden_grid)
    Lden_struct   = Lden_grid;
    Lnight_struct = Lnight_grid;
else
    if Regime(1) || Regime(3)
        Lden_struct   = read_envira(Lden_grid);
    end
    if Regime(2) || Regime(4)
        Lnight_struct = read_envira(Lnight_grid);
    end
end

%% Schaalfactor toepassen
if Regime(1) || Regime(3)
    Lden_struct.dat   = Lden_struct.dat   + 10*log10(Lden_scale);
    Lden_struct.scale = Lden_scale;
end
if Regime(2) || Regime(4)
    Lnight_struct.dat   = Lnight_struct.dat + 10*log10(Lnight_scale);
    Lnight_struct.scale = Lnight_scale;
end

if(nargin < 5) || strcmp(Splining, 'spline')
    if Regime(1) || Regime(3)
        write_enviraformat('Lden_grid.dat',    Lden_struct)
    end
    if Regime(2) || Regime(4)
        write_enviraformat('Lnight_grid.dat',Lnight_struct)
    end
        
    % Init
    pwd_dir = [pwd '\'];
    function_dir = fileparts(which('geluidstellingen.m'));

    I3 = {[function_dir '\Woningbestand_1367102_RIVM_WBS2008_situatie2005_20070510.mat']
          [function_dir '\Personenbestand_1367102_RIVM_WBS2008_situatie2005_20070510.mat']};

    % Voer tellingen uit
    result = [0 0 0 0];
    if Regime(1)
        [O1 dum dum dum] = geluidstellingen([pwd_dir 'Lden_grid.dat'],  58,   I3,[1 0 0 0]);
        result(1) = O1(1);
    end
    if Regime(2)
        [dum O2 dum dum] = geluidstellingen([pwd_dir 'Lnight_grid.dat'],48,   I3,[0 1 0 0]);
        result(2) = O2(1);
    end
    if Regime(3)
        [dum dum O3 dum] = geluidstellingen([pwd_dir 'Lden_grid.dat'],  48:65,I3,[0 0 1 0]);
        result(3) = sum(O3(:,1));
    end
    if Regime(4)
        [dum dum dum O4] = geluidstellingen([pwd_dir 'Lnight_grid.dat'],40:57,I3,[0 0 0 1]);
        result(4) = sum(O4(:,1));
    end
else
    % Voor tellingen uit zonder splining met de tool van Ramon
    opencontourerror = 3; % geeft een warning bij niet sluitende contouren
    result = [0 0 0 0];
    if Regime(1)
        result(1) = huizenlden(Lden_struct.dat, opencontourerror);
    end
    if Regime(2)
        result(2) = huizenlnight(Lnight_struct.dat, opencontourerror);
    end
    if Regime(3)
        result(3) = gehinderdenlden(Lden_struct.dat, opencontourerror);
    end
    if Regime(4)
        result(4) = slaapverstoordenlnight(Lnight_struct.dat, opencontourerror);
    end
end    
