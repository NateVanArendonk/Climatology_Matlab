function [ Station ] = readStationMeta( fname )
%[ Station ] = readStationMeta( fname )
%   fname = locatoin and name of WeatherStationMeta.csv
% Columns: Index	Long Name	Short name	NDBC	ERDAPP	USAF	WBAN	lat	lon	Pressure_gauge_elevation_from_MSL	Anemometer_Height_above_surface_[m]	Type	NDBC Link	Other Link	Data Access	Date Start	Date End
%   Columns are derived as:
%     Station.longName = data{2};
%     Station.shortName = data{3};
%     Station.ndbc = data{4};
%     Station.erddap = data{5};
%     Station.usaf = data{6};
%     Station.wban = data{7};
%     Station.lat = data{8};
%     Station.lon = data{9};
%     Station.presHeight = data{10};
%     Station.windHeight = data{11};
%     Station.instrType = data{12};
%     Station.ndbcLink = data{13};
%     Station.otherLink = data{14};
%     Station.dataAccess = data{15};
%     Station.dateStart = data{16};
%     Station.dateEnd = data{17};

fid = fopen(fname);
data = textscan(fid,'%d %s %s %s %s %s %s %f %f %f %f %s %s %s %s %s %s','HeaderLines',1,'Delimiter',',');
fclose(fid);
Station.index = data{1};
Station.longName = data{2};
Station.shortName = data{3};
Station.ndbc = data{4};
Station.erddap = data{5};
Station.usaf = data{6};
Station.wban = data{7};
Station.lat = data{8};
Station.lon = data{9};
Station.presHeight = data{10};
Station.windHeight = data{11};
Station.instrType = data{12};
Station.ndbcLink = data{13};
Station.otherLink = data{14};
Station.dataAccess = data{15};
Station.dateStart = data{16};
Station.dateEnd = data{17};

end

