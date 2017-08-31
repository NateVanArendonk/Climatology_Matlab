%% Script to calculate statistics of data 
% clearvars
%file_nm = 'sentry_shoal'; % change this to the location of interest
%dir_nm = '../../hourly_data/gap_hourly/station_choice/';
% %dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
file_load = strcat(dir_nm, station_nm, '_hourly.mat');
% 
% 
% %load in the data
load(file_load)
% clear stn_nm dir_nm file_load file_nm


%% Get rid of NaN's - Don't really have to do this with nanmean
% % time_orig = time;
% % 
% % spd_n = isnan(wndspd);
% % tmp_n = isnan(airtemp);
% % slp_n = isnan(slp);
% % dir_n = isnan(wnddir);
% % 
% % wndspd(spd_n) = [];
% % time_spd = time;
% % time_spd(spd_n) = [];
% % 
% % slp(slp_n) = [];
% % time_slp = time;
% % time_slp(slp_n) = [];
% % 
% % wnddir(dir_n) = [];
% % time_dir = time;
% % time_dir(dir_n) = [];


% wndspd(isnan(wndspd))=[]; %Even after interp if there are NaN's convert to zeros
% time_spd = time(isnan(wndspd)) = [];
% airtemp(isnan(airtemp))=[];
% time_tmp = time(isnan(airtemp)) = [];
% %dewp(isnan(dewp))=[];
% slp(isnan(slp))=[];
% time_slp = time(isnan(slp)) = [];
% wnddir(isnan(wnddir))=[];
% time_dir = time(isnan(wnddir)) = [];


% % % % plot(time_spd, wndspd)
% % % % clf
% % % % plot(time_slp, slp)





%Calculate the mean
spd_mean = nanmean(wndspd);
dir_mean = nanmean(wnddir);
slp_mean = nanmean(slp);

%Calculate variance
%spd_var = var(wndspd);
%dir_var = var(wnddir);
%slp_var = var(slp);

%Calcute mode
%spd_mode = mode(wndspd);
dir_mode = mode(wnddir);
slp_mode = mode(slp);

%Calculate Speed Max and Min
spd_max = max(wndspd);
%spd_min = min(wndspd);
slp_min = min(slp);

% Calculate range of values
spd_rn = range(wndspd);
dir_rn = range(wnddir);
slp_rn = range(slp);

% Calculate length of record
record = year(time(end)) - year(time(1));

%% Print Values to the screen

fprintf('\n')
fprintf('Wind Speed Mean: %4.2f m/s \n',(spd_mean))
fprintf('Wind Direction Mean: %4.2f degrees \n',(dir_mean))
fprintf('Sea Level Pressure Mean: %4.2f mb \n',(slp_mean))
fprintf('\n') % prints empty line to space out output

%fprintf('Wind Speed Variance: %4.2f m/s \n',(spd_var))
%fprintf('Wind Direction Variance: %4.2f degrees \n',(dir_var))
%fprintf('Sea Level Pressure Variance: %4.2f mb \n',(slp_var))
%fprintf('\n')

%fprintf('Wind Speed Mode: %4.2f m/s \n',(spd_mode))
fprintf('Wind Direction Mode: %4.2f degrees \n',(dir_mode))
fprintf('Sea Level Pressure Mode: %4.2f mb \n',(slp_mode))
fprintf('\n')

fprintf('Wind Speed Range: %4.2f m/s \n',(spd_rn))
fprintf('Wind Direction Range: %4.2f degrees \n',(dir_rn))
fprintf('Sea Level Pressure Range: %4.2f mb \n',(slp_rn))
fprintf('\n')

fprintf('Wind Speed Max: %4.2f m/s \n',(spd_max))
%fprintf('Wind Speed Min: %4.2f m/s \n',(spd_min))
fprintf('Slp Min: %4.2f mbars \n',(slp_min))

fprintf('%4.2f years on record', (record))

