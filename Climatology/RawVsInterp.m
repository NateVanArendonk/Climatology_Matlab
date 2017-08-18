% Compare Raw vs Interp. data

%% Load Raw Data

clearvars

%first load in the data
dir_nm = '../../Downloaded Raw Data/';
%dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
station_name = 'Bellingham Airport';
station_nm = 'van_airport';
%file_nm = 'whidbey_nas_hourly'; % you will have to change this variable for each station
load_file = strcat(dir_nm,station_nm);
load(load_file)
clear dir_nm file_nm load_file
%wnddir = wnddir';

station_data.wndspd = 0.44704 * station_data.wndspd; % convert to m/s
%%
%sort the time vector in ascending order from oldest date to current data
[~, I] = sort(station_data.time,'ascend');
station_data.time = station_data.time(I);
station_data.time_copy = station_data.time;

% Change entire structure to go from oldest to current date
station_data.usaf = station_data.usaf(I);
station_data.wban = station_data.wban(I);
station_data.yr = station_data.yr(I);
station_data.mo = station_data.mo(I);
station_data.da = station_data.da(I);
station_data.hr = station_data.hr(I);
station_data.mn = station_data.mn(I);
station_data.wnddir = station_data.wnddir(I);
station_data.wndspd = station_data.wndspd(I);
%station_data.wndmaxspd = station_data.wndmaxspd(I);
station_data.airtemp = station_data.airtemp(I);
station_data.dewp = station_data.dewp(I);
station_data.slp = station_data.slp(I);
station_data.alt = station_data.alt(I);
station_data.stp = station_data.stp(I);
% station_data.pcp01 = station_data.pcp01(I);
% station_data.pcp06 = station_data.pcp06(I);
% station_data.pcp24 = station_data.pcp24(I);


%% Load Hourly Data

%first load in the data
dir_nm = '../../hourly_data/';
station_name = 'Bellingham Airport';
station_nm = 'van_airport';
%file_nm = 'whidbey_nas_hourly'; % you will have to change this variable for each station
load_file = strcat(dir_nm,station_nm, '_hourly');
load(load_file)
clear dir_nm file_nm load_file
%wnddir = wnddir';

%%

subplot(2,1,1)
plot(station_data.time, station_data.wndspd)
datetick()

subplot(2,1,2)
plot(time, wndspd)
datetick()