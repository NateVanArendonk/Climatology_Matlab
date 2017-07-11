%clear 
clf
%% Sort by date
load('/Users/andrewmcauliffe/Desktop/Downloaded Raw Data/boeing_king.mat');
[~, I] = sort(station_data.time,'ascend');
%sort the time vector in ascending order from oldest date to current data
station_data.time = station_data.time(I);
station_data.time_copy = station_data.time;

%% Change entire structure to go from oldest to current date
station_data.usaf = station_data.usaf(I);
station_data.wban = station_data.wban(I);
station_data.yr = station_data.yr(I);
station_data.mo = station_data.mo(I);
station_data.da = station_data.da(I);
station_data.hr = station_data.hr(I);
station_data.mn = station_data.mn(I);
station_data.wnddir = station_data.wnddir(I);
station_data.wndspd = station_data.wndspd(I);
station_data.wndmaxspd = station_data.wndmaxspd(I);
station_data.airtemp = station_data.airtemp(I);
station_data.dewp = station_data.dewp(I);
station_data.slp = station_data.slp(I);
station_data.alt = station_data.alt(I);
station_data.stp = station_data.stp(I);
% station_data.pcp01 = station_data.pcp01(I);
% station_data.pcp06 = station_data.pcp06(I);
% station_data.pcp24 = station_data.pcp24(I);
station_data.wndgus = station_data.wndmaxspd;


%% Remove NaNs and Dups 
%nan_inds = find(isnan(station_data.time) | isnan(station_data.wndspd)...
    %| isnan(station_data.wnddir) | isnan(station_data.slp));
%length(nan_inds);
%gets rid of all NaN values at NaN indicies 
%station_data.time(nan_inds) = [];
%station_data.wndspd(nan_inds) = [];
%station_data.wnddir(nan_inds) = [];
%station_data.slp(nan_inds) = [];

%find NaNs in wind speed structure and remove them 
nan_inds.wndspd = find(isnan(station_data.wndspd));
station_data.wndspd(nan_inds.wndspd) = [];
station_data.time(nan_inds.wndspd) = [];
%find indicies of unique values for Interp, gets rid of dups 
[~, II] = unique(station_data.time);
%Interp
B.time = datenum(1945,4,1):(1/24):datenum(2017,3,29);  %Whidbey
%B.time = datenum(1941,10,1):(1/24):datenum(2016,12,31); %Paine
B.wndspd = interp1(station_data.time(II),station_data.wndspd(II),B.time,'linear');
clear II


% Plot interp vs observed
plot(station_data.time, station_data.wndspd, '*')
hold on
plot(B.time, B.wndspd)
datetick()
ylabel('windspeed')

%% Find NaNs in Wind Direction and Remove them
% Wind Direction has 990 when there is no recordable wind so its another
% NaN value and must be removed
clf
station_data.time = station_data.time_copy;
nan_inds.wnddir = find(isnan(station_data.wnddir) | station_data.wnddir == 990);
station_data.wnddir(nan_inds.wnddir) = [];
station_data.time(nan_inds.wnddir) = [];

%find indicies of unique values for Interp
[~, II] = unique(station_data.time);
B.wnddir = interp1(station_data.time(II), station_data.wnddir(II), B.time, 'linear');
clear II JJ

%Plot interp vs observed
plot(station_data.time, station_data.wnddir, '*')
hold on
plot(B.time, B.wnddir)
datetick()
ylabel('wind direction')

%% Find NaNs in Air Temp and Remove them 
clf
station_data.time = station_data.time_copy;
nan_inds.airtemp = find(isnan(station_data.airtemp));
station_data.airtemp(nan_inds.airtemp) = [];
station_data.time(nan_inds.airtemp) = [];
%find indicies of unique values for Interp
[~, II] = unique(station_data.time);
B.airtemp = interp1(station_data.time(II), station_data.airtemp(II), B.time, 'linear');
clear II
%Plot interp vs observed
plot(station_data.time, station_data.airtemp, '*')
hold on
plot(B.time, B.airtemp)
datetick()
ylabel('air temp')

%% Find NaNs in Dew Point and Remove them
clf
station_data.time = station_data.time_copy;
nan_inds.dewp = find(isnan(station_data.dewp));
station_data.dewp(nan_inds.dewp) = [];
station_data.time(nan_inds.dewp) = [];
%find indicies of unique values for Interp
[~, II] = unique(station_data.time);
B.dewp = interp1(station_data.time(II), station_data.dewp(II), B.time, 'linear');
clear II

%Plot interp vs observed
plot(station_data.time, station_data.dewp, '*')
hold on
plot(B.time, B.dewp)
datetick()
ylabel('dew point')

%% Find NaNs in Sea Level Pressure and Remove them
clf
station_data.time = station_data.time_copy;
nan_inds.slp = find(isnan(station_data.slp));
station_data.slp(nan_inds.slp) = [];
station_data.time(nan_inds.slp) = [];
%find indicies of unique values for Interp
[~, II] = unique(station_data.time);
B.slp = interp1(station_data.time(II), station_data.slp(II), B.time, 'linear');
clear II

%Plot interp vs observed
plot(station_data.time, station_data.slp, '*')
hold on
plot(B.time, B.slp)
datetick()
ylabel('sea level pressure')

%% Find NaNs in Station Pressure and Remove them 
%Big Data gap with this parameter
clf
station_data.time = station_data.time_copy;
nan_inds.stp = find(isnan(station_data.stp));
station_data.stp(nan_inds.stp) = [];
station_data.time(nan_inds.stp) = [];
%find indicies of unique values for Interp
[~, II] = unique(station_data.time);
B.stp = interp1(station_data.time(II), station_data.stp(II), B.time, 'linear');
clear II

%Plot interp vs observed
plot(station_data.time, station_data.stp, '*')
hold on
plot(B.time, B.stp)
datetick()
ylabel('station pressure')

B.time = B.time';
B.wndspd = B.wndspd';
B.wnddir = B.wnddir;
B.airtemp = B.airtemp';
B.dewp = B.dewp';
B.slp = B.slp';
B.stp = B.stp';


% 
% %Plot interp vs observed
% plot(station_data.time, station_data.wndspd, '*')
% hold on
% plot(B.time, B.wndspd)
% datetick()

%% Save Data
save('boeing_king_hourly','-struct','B');