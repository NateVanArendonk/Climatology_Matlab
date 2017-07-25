%% 
% Code to iterate through the hourly data and run refinebyparameter and
% plotdistribution codes
clearvars

dir_nm = '../../hourly_data/';
  % grabs all the files ending in .mat
d = dir([dir_nm, '/*.mat']);



% loop through each 
for n = 1:length(d)
    file_nm = d(n).name;
    [pathstr, name, ext] = fileparts(file_nm);  % seperates file name and extension and such 
    station_nm = regexprep(name, '_hourly', ''); % Gets rid of '_hourly' from the name
    PlotDistributions
end