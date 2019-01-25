function write_tape2_hdr(Hdr, dB, Tape2Hdr)
% Schrijf een tape2 header naar het bestand Tape2Hdr

% Input
%   Hdr             Grid.hdr (zie read_envira)
%   dB              dB-waarden van de contouren
%   Tape2Hdr        Naam van het tape2-header-bestand
  
%% Schrijf de header weg    
fid = fopen(Tape2Hdr, 'w' );

fprintf(fid,'%s\n', Hdr.tekst{1});
fprintf(fid,'%s\n', Hdr.tekst{2});
% Negeer de derde tekstregel

fprintf(fid, 'Eenheid: %s\n', Hdr.eenheid{:});
fprintf(fid, 'Contourwaarden: %2.0f t/m %2.0f %s\n', dB(1), dB(end), Hdr.eenheid{:});
fprintf(fid, 'X-ondergrens : %6.0f\n', Hdr.Xonder);
fprintf(fid, 'Y-ondergrens : %6.0f\n', Hdr.Yonder);
fprintf(fid, 'ref.punt   : X=%3.0f, Y=%3.0f\n', Hdr.Xonder, Hdr.Yonder);
fprintf(fid, '\n');

fclose( fid );  