function [Volume Scale Fval exitflag]=VmaxHuizen(Lden_grid, V0) 
%Deze functie bepaald de opschaalfactor tot de grens van gelijkwaardigheid
%
%syntax:
%
%[Volume Scale Fval exitflag] = VmaxHuizen(Lden_grid, V0)  
%
%input:
%  Lden_grid     Daisy-Lden-grid (file of struct)
%  V0            (Optioneel) aantal vliegtuigbewegingen etmaal in het scenario.
%                Wordt V0 niet meegegeven dan wordt het volume uit het Lden_grid gebruikt.
%
%output:
%  Volume        Passend volume binnen gelijkwaardigheid
%  Scale         Maximale schaalfactor
%  Fval          verschil tussen aantal woningen en de gelijkwaardigheidsnorm
%  exitflag      zie help bij functie fzero; waarde 1 is covergentie

%% Inlezen file of gebruik struct
if isstruct(Lden_grid) %TODO struct invoer is niet getest
    Lden_struct = Lden_grid;
else
    Lden_struct = read_envira(Lden_grid);
end

%% V0
if(nargin < 2)
    V0 = Lden_struct.hdr.nvlb;
end

%% Bepaal het maximum verkeersvolume
optimset('MaxIter', 100);
[Scale, Fval, exitflag] = fzero(@(multiplier) geschaaldeTellingenHuizenLden(multiplier,Lden_struct.dat,3),(480000/V0));
Volume = Scale * V0;

