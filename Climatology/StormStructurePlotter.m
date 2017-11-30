% Code to make a large structure of storms and generate heat maps 

clearvars

dir_nm = '../../hourly_data/gap_hourly/';
  % grabs all the files ending in .mat
d = dir([dir_nm, '/*.mat']);

master = struct();  % Create master storm structure to populate with data

% loop through each 
for n = 1:length(d)
    file_nm = d(n).name;
    [pathstr, name, ext] = fileparts(file_nm);  % seperates file name and extension and such 
    station_nm = regexprep(name, '_hourly', ''); % Gets rid of '_hourly' from the name
    Storms
    master.(station_nm) = storms;
end