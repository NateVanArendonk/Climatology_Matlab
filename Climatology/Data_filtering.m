%% Script to delete outliers in data
clearvars
file_nm = 'saturna'; % change this to the location of interest
dir_nm = '../../hourly_data/gap_hourly/station_choice/';
% %dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
file_load = strcat(dir_nm, file_nm, '_hourly.mat');
% 
% 
% %load in the data
load(file_load)
% clear stn_nm dir_nm file_load file_nm
