%% Make a map of Puget Sound
clf
clearvars
%axesm('mercator','MapLatLimit',[47 49],'MapLonLimit',[-125 -122])

load('/Users/natevanarendonk/Desktop/Delft_Working/MatlabGrids/Salish500/WA_dem.mat')
contour(Lon, Lat, Z, [0 0])
 
load('/Users/natevanarendonk/Desktop/hourly_data/whidbey_nas_hourly.mat')
