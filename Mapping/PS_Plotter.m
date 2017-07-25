%% Make a map of Puget Sound

latlim = ([45 51]);
lonlim = ([-130 -121]);
load coastlines

worldmap(latlim, lonlim)
plotm(coastlat, coastlon)

%geoshow('landareas.shp', 'FaceColor', [0.15 0.5 0.15])
