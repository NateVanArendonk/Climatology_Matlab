%% Script to calculate statistics of data 
file_nm = 'whidbey_hourly.mat'; % change this to the location of interest
file_loc = '/Users/andrewmcauliffe/Desktop/hourly_data/';
file_load = strcat(file_loc, file_nm);

%load in the data
load(file_load)
clear stn_nm file_loc file_load file_nm


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

% NEED to add this to the code to print to the command window
% 
% fprintf('Obs Max Wind Speed %4.2f m/s \n',(max(O.wndspd)))
% fprintf('NNRP Max Wind Speed %4.2f m/s \n',(max(N.wndspd_10m)))
% fprintf('HRDPS Max Wind Speed %4.2f m/s \n',(max(H.wndspd_10m(:,3))))

