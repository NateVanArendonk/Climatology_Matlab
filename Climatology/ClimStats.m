%% Script to calculate statistics of data 
clearvars
file_nm = 'sentry_shoal'; % change this to the location of interest
dir_nm = '../../hourly_data/';
%dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
file_load = strcat(dir_nm, file_nm, '_hourly.mat');


%load in the data
load(file_load)
clear stn_nm dir_nm file_load file_nm


%% Get rid of NaN's
wndspd(isnan(wndspd))=[]; %Even after interp if there are NaN's convert to zeros
airtemp(isnan(airtemp))=[];
dewp(isnan(dewp))=[];
slp(isnan(slp))=[];
wnddir(isnan(wnddir))=[];

%Calculate the mean
spd_mean = mean(wndspd);
dir_mean = mean(wnddir);
slp_mean = mean(slp);

%Calculate variance
spd_var = var(wndspd);
dir_var = var(wnddir);
slp_var = var(slp);

%Calcute mode
spd_mode = mode(wndspd);
dir_mode = mode(wnddir);
slp_mode = mode(slp);

%Calculate Speed Max and Min
spd_max = max(wndspd);
spd_min = min(wndspd);

%% Print Values to the screen

fprintf('\n')
fprintf('Wind Speed Mean: %4.2f m/s \n',(spd_mean))
fprintf('Wind Direction Mean: %4.2f degrees \n',(dir_mean))
fprintf('Sea Level Pressure Mean: %4.2f mb \n',(slp_mean))
fprintf('\n') % prints empty line to space out output

fprintf('Wind Speed Variance: %4.2f m/s \n',(spd_var))
%fprintf('Wind Direction Variance: %4.2f degrees \n',(dir_var))
fprintf('Sea Level Pressure Variance: %4.2f mb \n',(slp_var))
fprintf('\n')

fprintf('Wind Speed Mode: %4.2f m/s \n',(spd_mode))
fprintf('Wind Direction Mode: %4.2f degrees \n',(dir_mode))
fprintf('Sea Level Pressure Mode: %4.2f mb \n',(slp_mode))
fprintf('\n')

fprintf('Wind Speed Max: %4.2f m/s \n',(spd_max))
fprintf('Wind Speed Min: %4.2f m/s \n',(spd_min))




