%% 
% Code to iterate through the raw data and convert to hourly data and store
% in the correct folder
clearvars


%cd('../../');
%folder_nm = 'Downloaded Raw Data';
dir_loc = '../../Downloaded Raw Data';
%d = dir([folder_nm, '/*.mat']);  % grabs all the files ending in .mat
d = dir([dir_loc, '/*.mat']);
%cd('Downloaded Raw Data')


% loop through each 
for n = 1:length(d)
    file_nm = d(n).name;
    FormatData_TEST(file_nm)
end

    




%cd('../Matlab/Matlab_Structure')

