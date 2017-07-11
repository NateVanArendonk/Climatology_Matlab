%% Convert into a Julian Date format

%Load in the data hourly data
load('/Users/andrewmcauliffe/Desktop/Matlab/Matlab_Structure/downloaded station data/Whidbey_hourly.mat')

%Convert from datenum to date time
dt = datetime(time, 'ConvertFrom', 'datenum');


%Make a structure to house all the data
B.airtemp = airtemp;
B.dewp = dewp;
B.dt = dt;
B.slp = slp;
B.time = time;
B.wnddir = wnddir;
B.wndspd = wndspd;
B.TimeZone = 'America/Los_Angeles'; %establish timezone

%clear variables because they are now in the structure
clear airtemp dewp dt slp time wnddir wndspd

%Convert to Julian Date
format longG
B.jt = juliandate(B.dt);