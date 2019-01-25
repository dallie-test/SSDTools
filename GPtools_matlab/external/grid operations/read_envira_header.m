function [hdr]=read_envira_header(filenaam_or_fid)
% Lees de header van een envira file
%
% Deze functie heeft als input een filenaam (inclusief directory) in string
% formaat

%% Open file of gebruik fid
if isfloat(filenaam_or_fid) % dan is het dus een fid 
    fid       = filenaam_or_fid;
    %filenaam  = fopen(fid);
    closefile = false;
else
    fid       = fopen(filenaam_or_fid);
    %filenaam  = filenaam_or_fid;
    closefile = true;
end
 
%% uitlezen van headerinformatie (eerste 24 regels)
 
 % Eertse 4 regels zijn tekst (niet meer gebruikt?)
 % 1 identificatie: 40 char
 % 2 vliegveldnaam: 40 char
 % 3 periode-aanduiding: 80 char
for i=1:3
    hdr.tekst{i} = fgetl(fid);
end

% Lees de rest van de header
header =textscan(fid,'%s %s',20);

hdr.datum           = header{1}(1);  
hdr.tijd            = header{2}(1);  
hdr.eenheid         = header{2}(2);
hdr.grondinvloed    = header{2}(3);
% "tellingen"       = header{1}(4);              % skip, heeft geen functie meer 
hdr.demping_landing = str2double(header{2}(5));
hdr.demping_start   = str2double(header{2}(6));
hdr.mindba          = str2double(header{2}(7));
hdr.tijdstap        = str2double(header{2}(8));
hdr.Xonder          = str2double(header{2}(9));
hdr.Xboven          = str2double(header{2}(10)); % Onbetrouwbaar door Mathlab-functie Write_Envira: wordt hieronder overschreven
hdr.Xstap           = str2double(header{2}(11));
hdr.nx              = str2double(header{2}(12));
hdr.Yonder          = str2double(header{2}(13));
hdr.Yboven          = str2double(header{2}(14)); % Onbetrouwbaar door Mathlab-functie Write_Envira: wordt hieronder overschreven
hdr.Ystap           = str2double(header{2}(15));
hdr.ny              = str2double(header{2}(16));
hdr.nvlb            = str2double(header{2}(17));
hdr.neff            = str2double(header{2}(18));
hdr.nlos            = str2double(header{2}(19));
hdr.nweg            = str2double(header{2}(20));

hdr.Xboven = hdr.Xonder + (hdr.nx - 1) * hdr.Xstap;
hdr.Yboven = hdr.Yonder + (hdr.ny - 1) * hdr.Ystap;
 
%% Afsluiten 
if closefile
    fclose(fid);
end