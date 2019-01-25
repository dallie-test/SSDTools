function[new_pattern]=GPcalc_nieuw_GA(GAgriddir,Noise_pattern,prognose_dir,verkeer,year,Lden_scale)

% Basis idee is om GA verkeer aan alle .dat files toe te voegen. Alle
% bewerkingen zijn daarna nog uit te voeren.

dat_files = GetFiles(prognose_dir,strcat([Noise_pattern '.dat']));

% Laat oude toeslag file onaangetast, verwijder mm file. Deze wordt opnieuw
% samengesteld.
for i=1:size(dat_files,1)
    if ~isempty(strfind(dat_files{i,1},'oudetoeslag.dat'))
        dat_files{i,1} = [];
    end
    if ~isempty(strfind(dat_files{i,1},'mm.dat'))
        delete(dat_files{i,1});
        dat_files{i,1} = [];
    end
end

% LDEN results 04/22/heli
ResLDEN04   = [GAgriddir '\Result_Lden_Baan-04'];
ResLDEN22   = [GAgriddir '\Result_Lden_Baan-22'];
ResLDENheli = [GAgriddir '\Result_Lden_Helis'];

B04     = read_envira(ResLDEN04);
B22     = read_envira(ResLDEN22);
B00H    = read_envira(ResLDENheli);

% Gemiddelde wind (excl extreem weer jaren) = 42% Noord, 58% Zuidelijk. 
% 2015 was, zelfde methode, 36% Noord, 64% Zuid. Correctie nodig.
Correctie_04    = 42/36;
Correctie_22    = 58/64;
Correctie_heli  = 1;
Correctie_tot   = 1/Lden_scale; % Lden_scale wordt naderhand in code nogmaals toegepast. Moet niet gelden voor GA, allen voor HV, dus hierbij vooruit corrigeren.

Temp_GA(1:143,1:143) = Correctie_tot.*(Correctie_heli.*10.^(B00H.dat./10)+Correctie_22.*10.^(B22.dat./10)+Correctie_04.*10.^(B04.dat./10));

% Alles op basis van GP2015.
% Er zijn 9594 bewegingen in GA grid. Er missen dan nog 2373 bewegingen op
% hoofdbanen stelsel. Dat moet met Lden grid geschaald worden. Overigens is
% 85% van de 2373 een VVC klasse 1/X of 2/X, zeer licht verkeer... Mogelijk
% in de toekomst dus het aantal van 2373 halveren (afname van 3 dB, i.e.
% lijkt redelijk ivm lichte VVC).
scale_lden = 1 + 2373/verkeer;

%locate year files, add GA, scale original grid, write file _inclGA
year_files = {};
all_years = 1971:year-2;
for i_year=1:length(all_years)
    % Hard-coded wat we verwachten.
    year_file = {[prognose_dir strcat([Noise_pattern(1:end-2) ' y' num2str(all_years(i_year)) '.dat'])]};
    
    % Read grid
    envira_information  = read_envira(year_file{1});
    Temp_HV             = envira_information.dat;
    
    % Construct total grid
    grid = 10*log10(scale_lden.*10.^(Temp_HV./10)+Temp_GA);
    
    % Write resulting file
    cur_file    = year_file{1};    
    new_file    = [cur_file(1:end-9) 'incl_GA ' cur_file(end-8:end)]; 
    new_pattern = [Noise_pattern(1:end-2) ' incl_GA' Noise_pattern(end-1:end)];
    write_enviraformat(new_file,grid,envira_information.hdr.nx,envira_information.hdr.ny,envira_information.hdr.Xonder,envira_information.hdr.Yonder,envira_information.hdr.Xstap,envira_information.hdr.Ystap,envira_information.hdr.eenheid);

end
