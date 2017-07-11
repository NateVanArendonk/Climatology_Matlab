%% Convert to correct format
% This converts a single file of long data into lowercase format per
% research plan

temp = struct();
temp.usaf = station_data.USAF;
temp.wban = station_data.WBAN;
temp.yr = station_data.YR;
temp.mo = station_data.MO;
temp.da = station_data.DA;
temp.hr = station_data.HR;
temp.mn = station_data.MN;
temp.wnddir = station_data.DIR;
temp.wndspd = station_data.SPD;
temp.wndmaxspd = station_data.GUS;
temp.airtemp = station_data.TEMP;
temp.dewp = station_data.DEWP;
temp.slp = station_data.SLP;
temp.alt = station_data.ALT;
temp.stp = station_data.STP;
temp.pcp01 = station_data.PCP01;
temp.pcp06 = station_data.PCP06;
temp.pcp24 = station_data.PCP24;

station_data = temp

clear temp
%create date time vector for data
station_data.time = datenum(station_data.yr, station_data.mo,...
    station_data.da, station_data.hr, station_data.mn, 30);

%%
%station_data.wndmaxspd = str2double(station_data.wndmaxspd(:,1));
%station_data.pcp06 = str2double(station_data.pcp06(:,1));
%station_data.pcp24 = str2double(station_data.pcp24(:,1));

