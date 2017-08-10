%% QAQC


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
    file_load = strcat(dir_nm, file_nm);
    load(file_load)
    
    
    figure(1)
    plot(time, wnddir, '*')
    datetick()

    figure(2) 
    plot(time, wndspd)
    datetick()
    
    
    close(figure(1))
    close(figure(2))
end

% % % % clearvars
% % % % 
% % % % file_nm = 'boeing_king.mat'; % change this to the location of interest
% % % % file_loc = '../../Downloaded Raw Data/';
% % % % file_load = strcat(file_loc, file_nm);
% % % % 
% % % % %load in the data
% % % % load(file_load)
% % % % clear stn_nm file_loc file_load

%% 

figure(1)
plot(time, wnddir, '*')

figure(2) 
plot(time, wndspd)

%%

