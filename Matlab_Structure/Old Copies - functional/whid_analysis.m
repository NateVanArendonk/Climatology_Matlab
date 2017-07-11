clearvars %clear variables
clf %clear any plots

%seans code
%W.windspd = whidbey_2017_2009.SPD*0.44704; %Convert from mph to m/s
%W.winddir = whidbey_2017_2009.DIR;
%W.pres = whidbey_2017_2009.SLP;


%%Unit conversions
% to see units of original data go to ftp://ftp.ncdc.noaa.gov/pub/data/noaa/ish-abbreviated.txt
station_data.wndspd = station_data.wndspd * 0.44704; %Convert from mph to m/s
station_data.wndmaxspd = station_data.wndmaxspd * 0.44704; %Converts from mph to m/s for wind gusts
station_data.slp = station_data.slp * 100; %Convert from mb to Pa for pressure
station_data.stp = station_data.stp * 100; %Converts from mb to Pa for station pressure
station_data.airtemp = (station_data.airtemp - 32) * (5/9); %Converts from F to C
station_data.dewp = (station_data.dewp - 32) * (5/9); %Converts from F to C
station_data.alt - station_data.alt * 0.0254; %Converts from inches to meters for altimeter
station_data.pcp01 = station_data.pcp01 * 2.54; %Converts inches to cm for precip. data
station_data.pcp06 = station_data.pcp06 * 2.54; %Converts inches to cm for precip. data
station_data.pcp24 = station_data.pcp24 * 2.54; %Converts inches to cm for precip. data



%clf



%% Sort by date
[~, I] = sort(station_data.time,'ascend');
%sort the time vector in ascending order
station_data.time = station_data.time(I);

station_data.wndspd = station_data.wndspd(I);
w.winddir = W.winddir(I);
W.pres = W.pres(I);


%% Remove NaNs
nan_inds = find(isnan(W.time) | isnan(W.windspd) | isnan(W.winddir) | isnan(W.pres));
length(nan_inds)

W.time(nan_inds) = [];
W.windspd(nan_inds) = [];
W.winddir(nan_inds) = [];
W.pres(nan_inds) = [];


%% Interp

B.time = datenum(1950,1,1):(1/24):datenum(2017,3,29);
B.windspd = interp1(W.time,W.windspd,B.time,'linear');

clf
plot(W.time,W.windspd,'*')
hold on
plot(B.time,B.windspd)

%%





















return
%%
clf
plot(W.time,whidbey_2017_2009.SPD*0.44704)
datetick('x')
xlim([datenum(2016,3,1) datenum(2016,4,1)])


W.windspd = whidbey_2017_2009.SPD*0.44704; %Convert from mph to m/s
W.winddir = whidbey_2017_2009.DIR;
W.pres = whidbey_2017_2009.SLP;

W.station= [];
W.wvht= [];
W.dpd= [];
W.apd= [];
W.mwvd= [];
W.wavepower= [];
W.gust= [];
W.airtemp= [];
W.watertemp=[];

%% Remove NaNs
nan_inds = find(isnan(W.time) | isnan(W.windspd) | isnan(W.winddir) | isnan(W.pres));
sum(nan_inds)

W.time(nan_inds) = [];
W.windspd(nan_inds) = [];
W.winddir(nan_inds) = [];
W.pres(nan_inds) = [];




%% Switch Wind direction 
% from coming from, to going to
W.winddir = W.winddir+180;
W.winddir(W.winddir>360) = W.winddir(W.winddir>360)-360;
W.winddir(W.winddir>360) = W.winddir(W.winddir>360)-360;



%% Remove duplicates (110 duplicate time values)

% [C,ia,ic] = unique(W.time);
% %%
% [n, bin] = histc(W.time, unique(W.time));
% multiple = find(n > 1);
% index    = find(ismember(bin, multiple));


%% Save
save('Whidbey2009_2017.mat','-struct','W');