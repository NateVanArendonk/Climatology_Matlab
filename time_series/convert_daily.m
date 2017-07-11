%% Get daily mean values, max values 
%Load in data

tic

load('/Users/andrewmcauliffe/Desktop/Matlab/Matlab_Structure/downloaded station data/Whidbey_hourly.mat')

%% Get rid of NaNs
% First 9 values are NaNs
wndspd(isnan(wndspd))=0;
slp(isnan(slp))=0;
wnddir(isnan(wnddir))=0;
airtemp(isnan(airtemp))=0;
dewp(isnan(dewp))=0;
%% Get daily, monthly, and yearly time vectors

%Number of months between begin date and end date
total_months = months(time(1),time(end));

%Create a yearly Vector
yr_vec = year(time(1)):year(time(end));  

%make a monthly time vector
mo_vec = datenum(year(time(1)),month(time(1)),15):(365.25/12):datenum(year(time(end)),month(time(end)),15);
%mo_vec=month(mo_vec); %convert to months

%Initialze some empty vectors to house the new data
total_pts = zeros((length(yr_vec)*12),1); 
mo_mean = NaN(length(total_pts),1);
mo_wnddir_mean = mo_mean;
mo_wnddir_weighted = mo_mean;
