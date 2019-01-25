function write_enviraformat(filenaam, grid_or_struct, NX, NY, Xonder, Yonder, Xstap, Ystap, eenheid)
% Schrijf geluidsgrid weg met een header in Enviraformaat.
%
% Input
%   Filenaam        filenaam (inclusief directory)
%   grid_or_struct  Grid of struct (zie read_envira)
%   NX              Deze en volgende variabelen worden alleen
%   NY              gebruikt als er een grid is meegegeven
%   Xonder
%   Yonder
%   Xstap
%   Ystap
%   eenheid

% Geen struct? 
if(nargin > 2)
    hdr.tekst           = {'Dit bestand is gecreerd met matlabfunctie write_enviraformat', '', ''}; % eerste drie regels
    hdr.datum           = {datestr(now, 'dd-mmm-yyyy')};  
    hdr.tijd            = {datestr(now, 'HH:MM:SS')};  
    hdr.eenheid         = eenheid;
    hdr.grondinvloed    = {'99'};
    % "tellingen"         skip, heeft geen functie meer 
    hdr.demping_landing = 99.99;
    hdr.demping_start   = 99.99;
    hdr.mindba          = 99.99;
    hdr.tijdstap        = 99.99;
    hdr.nx              = NX;
    hdr.Xstap           = Xstap;
    hdr.Xonder          = Xonder;
    hdr.Xboven          = hdr.Xonder + (hdr.nx - 1) * hdr.Xstap;
    hdr.ny              = NY;
    hdr.Ystap           = Ystap;
    hdr.Yonder          = Yonder;
    hdr.Yboven          = hdr.Yonder + (hdr.nx - 1) * hdr.Xstap;
    hdr.Yboven          = hdr.Yonder + (hdr.ny - 1) * hdr.Ystap;
    hdr.nvlb            = 9999;
    hdr.neff            = 9999;
    hdr.nlos            = 9999;
    hdr.nweg            = 0;
    
    grid                = grid_or_struct;
else
    hdr                 = grid_or_struct.hdr;
    grid                = grid_or_struct.dat;
end
    
%uitlezen van relevante headerinformatie
fid=fopen(filenaam,'w');

fprintf(fid,'%s\n',                    hdr.tekst{1});
fprintf(fid,'%s\n',                    hdr.tekst{2});
fprintf(fid,'%s\n',                    hdr.tekst{3});
fprintf(fid,'%s %s\n',                 hdr.datum{:}, hdr.tijd{:});
fprintf(fid,'EENHEID %s\n',            hdr.eenheid{:});
fprintf(fid,'GRONDINVLOED %s\n',       hdr.grondinvloed{:});
fprintf(fid,'TELLINGEN\n');
fprintf(fid,'DEMPING-LANDING %6.2f\n', hdr.demping_landing);
fprintf(fid,'DEMPING-START %6.2f\n',   hdr.demping_start);
fprintf(fid,'MINDBA %6.2f\n',          hdr.mindba);
fprintf(fid,'TIJDSTAP %6.2f\n',        hdr.tijdstap);
fprintf(fid,'X-ONDER %9.0f\n',         hdr.Xonder);
fprintf(fid,'X-BOVEN %9.0f\n',         hdr.Xboven);
fprintf(fid,'X-STAP %9.0f\n',          hdr.Xstap);
fprintf(fid,'NX    %6.0f\n',           hdr.nx);
fprintf(fid,'Y-ONDER %9.0f\n',         hdr.Yonder);
fprintf(fid,'Y-BOVEN %9.0f\n',         hdr.Yboven);
fprintf(fid,'Y-STAP %9.0f\n',          hdr.Ystap);
fprintf(fid,'NY    %6.0f\n',           hdr.ny);
fprintf(fid,'NVLB %9.0f\n',            hdr.nvlb);
fprintf(fid,'NEFF %9.0f\n',            hdr.neff);
fprintf(fid,'NLOS %9.0f\n',            hdr.nlos);
fprintf(fid,'NWEG %9.0f\n',            hdr.nweg);

for cnt=1:hdr.ny
    roi=grid(cnt,:);
    writable1=[];
    for cnt2=1:floor(hdr.nx/10)
      writable1=[writable1;roi(1+10*(cnt2-1):10*cnt2)];
    end;

    fprintf(fid, '%13.6E%13.6E%13.6E%13.6E%13.6E%13.6E%13.6E%13.6E%13.6E%13.6E\n',transpose(writable1));
    
    %wegschrijven van het restant
    writable2=roi(10*cnt2+1:length(roi));
    stringformat=[];
    for cnt3=1:(length(writable2)-1)
        stringformat=[stringformat '%13.6E'];
    end;
    if cnt~=hdr.ny
      stringformat=[stringformat '%13.6E\n'];
    else 
        stringformat=[stringformat '%13.6E'];
    end;
    
    fprintf(fid, stringformat, transpose(writable2));
    
end;
fclose(fid);