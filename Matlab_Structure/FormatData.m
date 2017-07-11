%% Script to convert data to correct format (units) for analysis

% Note, this script should only be ran for data that is a full time series,
% not one that needs to be combined. 


%THIS SCRIPT RUNS convert_hourly script and ScalewindPowerLaw
clearvars
% load the data
load('/Users/andrewmcauliffe/Desktop/Downloaded Raw Data/victoria_bc.mat');
%% Housekeeping stuff - This is done in structure combine as well
% Convert cells to double 
%station_data.wndmaxspd = str2double(station_data.wndmaxspd(:,1));
%station_data.stp = str2double(station_data.stp(:,1));


%% Variables that change every time

elevation = 70;
station_name = 'victoria_bc';
scaled_height = 10; 
surface_type = 'land';


%% Convert to correct format
temp = station_data;
clear station_data

station_data.usaf = temp.USAF;
station_data.wban = temp.WBAN;
station_data.yr = temp.YR;
station_data.mo = temp.MO;
station_data.da = temp.DA;
station_data.hr = temp.HR;
station_data.mn = temp.MN;
station_data.wnddir = temp.DIR;
station_data.wndspd = temp.SPD;
%station_data.wndmaxspd = temp.GUS;
station_data.airtemp = temp.TEMP;
station_data.dewp = temp.DEWP;
station_data.slp = temp.SLP;
station_data.alt = temp.ALT;
station_data.stp = temp.STP;

clear temp


%% Code to make datenum from dates in station_data
station_data.dtnum = [];

for i = 1:length(station_data.yr)
    station_data.dtnum(end+1) = datenum(station_data.yr(i), station_data.mo(i), station_data.da(i), station_data.hr(i), station_data.mn(i), 30);
end


clear i j 

station_data.time = datenum(station_data.yr, station_data.mo,...
    station_data.da, station_data.hr, station_data.mn, 30);

station_data.time = station_data.time';
station_data.dtnum = station_data.dtnum';



%% Unit conversion
% to see units of original data go to ftp://ftp.ncdc.noaa.gov/pub/data/noaa/ish-abbreviated.txt

station_data.wndspd = station_data.wndspd * 0.44704; %Convert from mph to m/s
%station_data.wndmaxspd = station_data.wndmaxspd * 0.44704; %Converts from mph to m/s for wind gusts
station_data.slp = station_data.slp * 100; %Convert from mb to Pa for pressure
station_data.stp = station_data.stp * 100; %Converts from mb to Pa for station pressure
station_data.airtemp = (station_data.airtemp - 32) * (5/9); %Converts from F to C
station_data.dewp = (station_data.dewp - 32) * (5/9); %Converts from F to C
station_data.alt = station_data.alt * 0.0254; %Converts from inches to meters for altimeter
%station_data.pcp01 = station_data.pcp01 * 2.54; %Converts inches to cm for precip. data
%station_data.pcp06 = station_data.pcp06 * 2.54; %Converts inches to cm for precip. data
%station_data.pcp24 = station_data.pcp24 * 2.54; %Converts inches to cm for precip. data


%% Transpose the data horizontally to vertical configuration 
station_data.usaf = station_data.usaf';
station_data.wban = station_data.wban';
station_data.yr = station_data.yr';
station_data.mo = station_data.mo';
station_data.da = station_data.da';
station_data.hr = station_data.hr';
station_data.mn = station_data.mn';
station_data.wnddir = station_data.wnddir';
station_data.wndspd = station_data.wndspd';
%station_data.wndmaxspd = station_data.wndmaxspd';
station_data.airtemp = station_data.airtemp';
station_data.dewp = station_data.dewp';
station_data.slp = station_data.slp';
station_data.alt = station_data.alt';
station_data.stp = station_data.stp';

%% Run other scripts
convert_hourly;
scaleWindPowerLaw(station_data.wndspd, elevation, scaled_height, surface_type);
clear ans elevation I nan_inds scaled_height station_data surface_type

%% Save Data
outname = sprintf('%s_hourly',station_name);

save(outname,'-struct','B');