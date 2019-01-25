function[scaled_prognose_dir] = GPcalc_opschalen(prognose_dir,Verkeer_scale_den,Verkeer_scale_de,Verkeer_scale_n)
% MA.

CurDir = pwd;
scaled_prognose_dir = [prognose_dir(1:end-1) ' scaled\'];

if isdir(scaled_prognose_dir)==1
    % Opgeschaalde dir bestaat. Check of schaalfactoren veranderd zijn.
    name = [scaled_prognose_dir 'Schaalfactoren.txt'];  
    temp = read_text(name);
    
    % Bepaal verschil
    schaal_inplace = str2num(cell2mat(temp.value)); %#ok<ST2NM>
    schaal_current = [Verkeer_scale_den;Verkeer_scale_de;Verkeer_scale_n];
    delta = schaal_inplace - schaal_current;
    
    % Indien schaal meer dan tienduizendste afwijkt, opnieuw schalen.
    if sum(abs(delta)>1e-4)>0
        rmdir(scaled_prognose_dir);
        copyfile(prognose_dir,scaled_prognose_dir);
    else
        % Geen schaling meer nodig, terug naar aanroepende functie.
        return;
    end 
else
    % Opgeschaalde dir bestaat nog niet, aanmaken door kopieren
    % oorspronkelijk scenario.
    copyfile(prognose_dir,scaled_prognose_dir);
end

% Lees bestanden in geschaalde dir in.
cd(scaled_prognose_dir);
temp = dir;
temp = struct2cell(temp);
files = temp(1,:)';
cd(CurDir);

% Add directory name to files, make this reference files2
for i=1:length(files)
    files2{i,1} = [scaled_prognose_dir files{i}]; %#ok<AGROW>
end

% Per default indien schaal factor den is opgegeven dan geen seperate de of
% n schaling toepassen.
if Verkeer_scale_den>1
    disp('Scaling factors related to only D,E or N are disregarded. Only the DEN factor is used.');
    Verkeer_scale_de = 1;
    Verkeer_scale_n  = 1;
end

% Meta informatie file met schaling maken
meta_fid = fopen([scaled_prognose_dir 'Schaalfactoren.txt'],'wt+');
fprintf(meta_fid,'Schaalfactor\tvalue\n');
fprintf(meta_fid,'DEN\t%f\n',Verkeer_scale_den);
fprintf(meta_fid,'DE\t%f\n',Verkeer_scale_de);
fprintf(meta_fid,'N\t%f\n',Verkeer_scale_n);
fclose(meta_fid);

%% First update the HG scaling

% Read in den
ID_den = strfind(files,'HG_DEN');
ID_den = ~cellfun(@isempty, ID_den);
HG_DEN_file = files2(ID_den);
HG_DEN_fid = fopen(HG_DEN_file{1});
HG_DEN = textscan(HG_DEN_fid,'%f');
fclose(HG_DEN_fid);
Hsom_den = 10.^(HG_DEN{1}./10);

%Read in night
ID_n = strfind(files,'HG_NIGHT');
ID_n = ~cellfun(@isempty, ID_n);
HG_NIGHT_file = files2(ID_n);
HG_NIGHT_fid = fopen(HG_NIGHT_file{1});
HG_NIGHT = textscan(HG_NIGHT_fid,'%f');
fclose(HG_NIGHT_fid);
Hsom_n = 10.^(HG_NIGHT{1}./10);

% Scaling
Hsom_den = Verkeer_scale_de.*(Hsom_den-Hsom_n)+Verkeer_scale_n.*Hsom_n;
HG_NIGHT = 10*log10(Verkeer_scale_n.*Hsom_n);
HG_DEN   = 10*log10(Verkeer_scale_den.*Hsom_den);

% Write files
HG_DEN_fid = fopen(HG_DEN_file{1},'wt+');
fprintf(HG_DEN_fid,'%.5f',HG_DEN);
fclose(HG_DEN_fid);

HG_NIGHT_fid = fopen(HG_NIGHT_file{1},'wt+');
fprintf(HG_NIGHT_fid,'%.5f',HG_NIGHT);
fclose(HG_NIGHT_fid);

%% Update the traffic files

ID_traffic = strfind(files,'traffic');
ID_traffic = ~cellfun(@isempty, ID_traffic);
traffic_files = files2(ID_traffic);

for i=1:length(traffic_files)
    trf = read_traffic(traffic_files{i});
    
    % Check if den identifier is available
    if isfield(trf,'den')
        ID_D = strcmp(trf.den,'D');
        ID_E = strcmp(trf.den,'E');
        ID_N = strcmp(trf.den,'N');
        ID_DE = ID_D | ID_E;
    else
        fprintf('Cannot scale %s since there is no DEN identifier\n',traffic_files{i});
        continue;
    end
    
    % Scale traffic
    total = trf.total.*Verkeer_scale_den;
    total(ID_DE) = total(ID_DE).*Verkeer_scale_de;
    total(ID_N) = total(ID_N).*Verkeer_scale_n;
    
    % Print update information
    delete(traffic_files{i});
    trf_fid = fopen(traffic_files{i},'wt+');
    
    % Hdr names
    fnames   = fieldnames(trf);  
    numfield = length(fnames);
    for j=1:numfield-1
        fprintf(trf_fid,'%s\t',fnames{j});
    end
    fprintf(trf_fid,'%s\n',fnames{j+1});
    
    % Restructure traffic file
    clear data
    for j=1:numfield-1
        data(:,j) = eval(['trf.' fnames{j}]);
    end
    data = [data num2cell(total)];
    
    % Print data
    for j=1:length(total)
        fprintf(trf_fid,[repmat('%s\t',1,numfield-1) '%.8f\n'],data{j,:});
    end
    fclose(trf_fid);
    
end

%% Schaal geluidsgrids
