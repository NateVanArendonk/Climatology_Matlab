%% Code to interp data but leave gaps

%% Sort by date
%load('/Users/andrewmcauliffe/Desktop/Downloaded Raw Data/whidbey.mat');
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
station_data.airtemp = station_data.airtemp(I);
station_data.dewp = station_data.dewp(I);
station_data.slp = station_data.slp(I);
station_data.alt = station_data.alt(I);
station_data.stp = station_data.stp(I);



%% Interp 

%find NaNs in wind speed structure and remove them 
nan_inds.wndspd = find(isnan(station_data.wndspd));
if length(nan_inds.wndspd) > 0
    station_data.wndspd(nan_inds.wndspd) = [];
    station_data.time(nan_inds.wndspd) = [];
end
%find indicies of unique values for Interp, gets rid of dups 
[~, II] = unique(station_data.time);

st_yr = year(station_data.time(1));
st_mo = month(station_data.time(1));
st_day = day(station_data.time(1));

end_yr = year(station_data.time(end));
end_mo = month(station_data.time(end));
end_day = day(station_data.time(end));

% Create time vector
B.time = datenum(st_yr, st_mo, st_day):(1/24):datenum(end_yr, end_mo, end_day);
% Interp gaps up to specified threshold of hours
hr_thresh = 6;
B.wndspd = interpShortGap(station_data.time(II), station_data.wndspd(II), B.time, hr_thresh);

%% Find NaNs in Wind Direction and Remove them
% Wind Direction has 990 when there is no recordable wind so its another
% NaN value and must be removed

station_data.time = station_data.time_copy;
nan_inds.wnddir = find(isnan(station_data.wnddir) | station_data.wnddir == 990);
if length(nan_inds.wnddir) > 0
    station_data.wnddir(nan_inds.wnddir) = [];
    station_data.time(nan_inds.wnddir) = [];
end

%find indicies of unique values for Interp
[~, II] = unique(station_data.time);
B.wnddir = interpShortGap(station_data.time(II), station_data.wnddir(II), B.time, hr_thresh);

%% Find NaNs in Sea Level Pressure and Remove them

station_data.time = station_data.time_copy;
nan_inds.slp = find(isnan(station_data.slp));

if length(nan_inds.slp) ~= length(station_data.slp) 
    station_data.slp(nan_inds.slp) = [];
    station_data.time(nan_inds.slp) = [];
%find indicies of unique values for Interp
    [~, II] = unique(station_data.time);
    B.slp = interpShortGap(station_data.time(II), station_data.slp(II), B.time, hr_thresh);
    clear II
elseif length(nan_inds.slp) == length(station_data.slp)
    fprintf('No Values for sea level pressure')
    B.slp = 0;
end

