function out = COOPS_get_tide_predictions(station,dates,interval)
%COOPS_Wind_Get  Gets COOPS Wind Data from web (http://tidesandcurrents.noaa.gov/index.shtml).
%
%   OUT = COOPS_WIND_GET(station,DATES) gets the wind data for STATION from 
%   (or between and including) DATE(S) where STATION is an NOS id
%   number and DATE(S) is/are Matlab datenum(s) or a year or '*' 
%   (get everything available).
%
%   Input:
%     STATION = num (ex.  station = 8760922)
%     DATE(S) = datenum | [datenum1 datenum2] | year | '*';
%     INTERVAL = 'hourly' (default) | or: 'six minute'
%   Output:
%     OUT = structure:
%           station = BUOY
%           longitude = longitude
%           latitude = latitude
%           time = time
%           temp = temperature (in C)
%     
%
% Dave Thompson (dthompson@usgs.gov)
% edited by Ian Miller (immiller@uw.edu) 25 March 2016
%
%%

% All stations are listed here.
%url = 'http://tidesandcurrents.noaa.gov/station_retrieve.shtml?type=Historic%20Tide%20Data&state=All%20Stations&id1=';
out.name=[];
out.station = station;
station = num2str(station);
if length(dates)==1 % Get one year.
   dates = [datenum(dates,1,1) datenum(dates,12,31)];
end
bdate = datestr(dates(1),'yyyymmdd');
edate = datestr(dates(2),'yyyymmdd');

% Check interval.
if ~exist('interval','var')
   interval = 'hourly';
end

int = {'six minute','6';'hourly','h'};
id = find(strcmp(interval,int(:,1)));
if ~isempty(id)
   int = int{id,2};
else
   disp([9,'Bad interval',10])
   return
end
out.interval = interval;

unit = 'metric';
out.units = 'metric';

timezone = 'GMT';   %GMT
out.timezone = 'gmt';

%% read data

url = ['https://tidesandcurrents.noaa.gov/api/datagetter?product=predictions&application=NOS.COOPS.TAC.WL&begin_date=',bdate,...
   '&end_date=',edate,'&datum=MLLW&station=',station,'&time_zone=',timezone,'&units=',unit,'&interval=',int,'&format=json'];

%http://tidesandcurrents.noaa.gov/api/datagetter?product=predictions&application=NOS.COOPS.TAC.WL&begin_date=19960101&end_date=19970101&datum=MLLW&station=9447130&time_zone=GMT&units=metric&interval=6&format=csv
%http://tidesandcurrents.noaa.gov/api/datagetter?product=predictions&application=NOS.COOPS.TAC.WL&begin_date=19960101&end_date=19961231&datum=MLLW&station=9447130&time_zone=GMT&units=metric&interval=6&format=json


sprintf('Loading %s',url)
   
[tmp,status]=urlread(url);


if status==1

    data=parse_json(tmp);

    if isfield(data,'error')
        out.time=[];
        out.temp=[];
        'No data for that time period.  Moving on.'
    
    else
        
        %assign latitude and longitude of station using metadata returned by NOAA
%         out.latitude=data.metadata.lat;
%         out.longitude=data.metadata.lon;
%         out.name=data.metadata.name;

        % parse data strings
        out.wl = NaN(1,length(data.predictions));
        out.time = NaN(1,length(data.predictions));
        for i=1:length(data.predictions)

            tempdat=data.predictions{i};

            dt=datenum(tempdat.t);
            wl=str2num(tempdat.v);
            
            out.time(i)=dt;
            
            
            %store wind speed to structure
            if ~isempty(wl)
                out.wl(i)=wl;
            else
                out.wl(i)=NaN;
            end            
            clear temp dt wl
        end
    end
elseif status==0
     out.time=[];
     out.wl=[];
     %out.dir=[];
     %out.gus=[];
    'Download Failed!  Moving on.'
end

return
