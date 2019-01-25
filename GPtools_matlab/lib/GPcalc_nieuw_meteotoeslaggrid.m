function [ output_args ] = GPcalc_nieuw_meteotoeslaggrid(prognose_dir,Noise_pattern,representatieve_jaren)
%GPcalc_nieuw_meteotoeslaggrid Overschrijft grid met meteotoeslag door
%berekend grid met nieuwe methode.

%locate meteo margin file
mm_file = GetFiles(prognose_dir,strcat([Noise_pattern 'mm.dat']));
mm_file_exists = true;

if size(mm_file,1)>1
    error('more than one file found with meteo margin');
elseif size(mm_file,1)==0
    %no mm-file present (probably empirical calculation). Create one. 
    mm_file_exists = false;
    mm_file{1} = strcat([prognose_dir Noise_pattern(1:end-2) ' 1971-2010mm.dat']);
    mean_file = strcat([prognose_dir Noise_pattern(1:end-2) ' 1971-2010.dat']); %TODO: checken of ook echt deze jaren zijn aangetroffen
end

%locate year files
year_files = {};
for i_year=1:size(representatieve_jaren,1)
    year_file = GetFiles(prognose_dir,strcat([Noise_pattern 'y' num2str(representatieve_jaren(i_year))]));
    if size(year_file,1)~=1
        error(['not exactly one file found for year ' num2str(representatieve_jaren(i_year))]);
    end
    year_files{i_year} = year_file{1};
    envira_information = read_envira(year_files{i_year});
    year_grids(:,:,i_year) = envira_information.dat;
end

%calculate new noise grid
meteotoeslag_grid = max(year_grids,[],3);


%if there was an old file, backup it
if mm_file_exists
    mm_envira_information = read_envira(mm_file);

    %rename old meteo margin file
    movefile(mm_file{1},strcat([mm_file{1}(1:end-6) 'oudetoeslag.dat']));
else
    %guess mm envira information by last read grid
    mm_envira_information = envira_information;
    %write mean file, based on all years
    all_grids = GetFiles(prognose_dir,strcat([Noise_pattern 'y']));
    for i_year=1:size(all_grids,1)
        %fistly, read all files
        envira_information = read_envira(all_grids{i_year});
        year_grids(:,:,i_year) = envira_information.dat;        
    end
    %finally, write files
    mean_grid = mean(year_grids,3);
    write_enviraformat(mean_file,mean_grid,mm_envira_information.hdr.nx,mm_envira_information.hdr.ny,mm_envira_information.hdr.Xonder,mm_envira_information.hdr.Yonder,mm_envira_information.hdr.Xstap,mm_envira_information.hdr.Ystap,mm_envira_information.hdr.eenheid);
end

%name and write output file
write_enviraformat(mm_file{1},meteotoeslag_grid,mm_envira_information.hdr.nx,mm_envira_information.hdr.ny,mm_envira_information.hdr.Xonder,mm_envira_information.hdr.Yonder,mm_envira_information.hdr.Xstap,mm_envira_information.hdr.Ystap,mm_envira_information.hdr.eenheid);
end