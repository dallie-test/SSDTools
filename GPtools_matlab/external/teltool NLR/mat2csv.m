clear all; close all; clc;

%%

fileList = dir('*.mat');

%%
for ii  = 1:length(fileList)
    % load data
    FileData = load(fileList(ii).name);
    
    % print data
    output_file = [fileList(ii).name(1:end-3) 'csv'];
    FID = fopen(output_file,'W');
    struct2csv(FileData,FID)
    fclose(FID)
    
end