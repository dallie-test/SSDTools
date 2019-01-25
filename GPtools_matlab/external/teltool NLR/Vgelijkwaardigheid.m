function [V alfa  Fval exitflag]=Vgelijkwaardigheid(V0,filenaam, regime) 
%Deze functie bepaald de opschaalfactor tot de grens van gelijkwaardigheid
%
%syntax:
%
%[V alfa  Fval exitflag]=Vgelijkwaardigheid(V0,filenaam, regime) 
%
%input:
% - V0: Aantal vliegtuigbewegingen etmaal in het scenario.
% - filenaam: Naam en locatie van grid bestand (envira formaat).
% - regime: {0} woningen; {1} gehinderden
%
%output:
% - V: passend volume binnen gelijkwaardigheid (12.300 woningen, 239.500 gehinderden
% - alfa: opschaalfactor
% - Fval:verschil tussen aantal woningen en de gelijkwaardigheidsnorm
% - exitflag: zie help bij functie fzero; waarde 1 is covergentie

Gelijkw_eisen=[12300 11700 239500 66500];

if regime==0
  load woningen;
  optimset('MaxIter', 100);
  [alfa,Fval,exitflag] = fzero(@(multiplier) geschaaldetellingen(multiplier,filenaam,NW,NentriesW,outputW,Gelijkw_eisen(1),regime),(480000/V0));
  V=alfa*V0;
end

if regime==1
  load personen;
  optimset('MaxIter', 100);
  [alfa,Fval,exitflag] = fzero(@(multiplier) geschaaldetellingen(multiplier,filenaam,NP,NentriesP,outputP,Gelijkw_eisen(3),regime),(550000/V0));
  V=alfa*V0;
end
end
 %% definitie functie  geschaalde tellingen
 
 function zerosearch=geschaaldetellingen(multiplier,filenaam,N,Nentries,output,maxnum,regime)
if regime==0
  [multigrid succescode]=multiply_enviraresults(multiplier,cellstr(filenaam), 'temptellingen.dat');
  if isreal(multigrid)
       alltelgehinderden = huizenlden(multigrid,3);
  else
       alltelgehinderden=sum(sum(N));
  end
  zerosearch=alltelgehinderden-maxnum;
end
if regime==1
  [multigrid succescode]=multiply_enviraresults(multiplier,cellstr(filenaam), 'temptellingen.dat');
  if isreal(multigrid)
    alltelgehinderden = gehinderdenlden(multigrid,3);
  else
       alltelgehinderden=sum(sum(N));
  end
  
  zerosearch=alltelgehinderden-maxnum;
end
 end
 %%
