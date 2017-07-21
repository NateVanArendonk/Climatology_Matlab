% JDF 
%
% MHW, meters
%
% Standard_Parallel: 45.833333
% Standard_Parallel: 47.333333
% Longitude_of_Central_Meridian: -120.500000
% Latitude_of_Projection_Origin: 45.333333
% False_Easting: 1640416.666667
% False_Northing: 0.000000
% 
% Abscissa_Resolution: 84.384639
% Ordinate_Resolution: 84.384639
%
% Geodetic_Model:
% Horizontal_Datum_Name: North American Datum of 1983
% Ellipsoid_Name: Geodetic Reference System 80
% Semi-major_Axis: 6378137.000000
% Denominator_of_Flattening_Ratio: 298.257222
%
% Projection    STATEPLANE
% Fipszone      4602
% Datum         NAD83
% Spheroid      GRS80
% Units         FEET
% Zunits        METERS
% Xshift        0.0
% Yshift        0.0

clearvars

% 3-meter resolution
xyz = ascii2xyz('Strait_of_Juan_de_Fuca_DEM_951/sjdf_506ft.asc');

my_zone = '4602';
my_unit = 'sf'; %'sf'

x = xyz(:,1);
y = xyz(:,2);
z = xyz(:,3);


%Downsample and grid
N = 1;
dx = 150*3.28084;  % feet

x = xyz(1:N:end,1);
y = xyz(1:N:end,2);
z = xyz(1:N:end,3);

X = min(x):dx:max(x);
Y = min(y):dx:max(y);

[X, Y] = meshgrid(X,Y);

tic
Z = griddata(x,y,z,X,Y);
toc


% Convert from state plane to lat/lon
[Lon,Lat] = sp_proj(my_zone,'inverse',X(:),Y(:),my_unit);

Lat = reshape(Lat,size(X));
Lon = reshape(Lon,size(X));

save('JDF_dem_150m.mat','X','Y','Lat','Lon','Z')

figure
pcolor(Lon,Lat,Z)
shading flat
hold on
contour(Lon,Lat,Z,[0 0],'k')
colorbar
%caxis([-100 0])
%colormap(bone)
colormap(demcmap(Z,1000))

%% Transform to UTM

[x_utm, y_utm] = deg2utm(Lat(:),Lon(:));
x_utm = reshape(x_utm,size(Lat));
y_utm = reshape(y_utm,size(Lat));

figure
pcolor(x_utm,y_utm,Z)
shading flat
hold on
contour(x_utm,y_utm,Z,[0 0],'k')
colorbar
%caxis([-100 0])
%colormap(bone)
colormap(demcmap(Z,1000))


%% Make Grid in UTM for D3D
%   JDF Channel and Basin
% xll = 3.6e5;
% yll = 5.3e6;
% xrr = 5.4e5;
% yrr = 5.4e6;
%   Just Basin
xll = 4.4e5;
yll = 5.32e6;
xrr = 5.3e5;
yrr = 5.38e6;
dx = 500; %meters

myx = xll:dx:xrr;
myy = yll:dx:yrr;

[myX, myY] = meshgrid(myx,myy);

myZ = griddata(x_utm,y_utm,Z,myX,myY);

figure

%%
test = myZ;
test(test>3) = -999;

clf
pcolor(myX,myY,test)
shading flat
hold on
contour(myX,myY,myZ,[0 0],'k')
colorbar
%caxis([-100 0])
%colormap(bone)
colormap(demcmap(test,1000))

%% Make D3D grid
% Answer Y to negate points (D3D expects depth, not elevtation)
% Answer 9 to extend
addpath 'C:\openearthtools\matlab\applications\delft3d_matlab'

proj_name = 'jdf_500m';

wlgrid('write','Filename',proj_name,'X',myX','Y',myY','AutoEnclosure')
wldep('write',sprintf('%s.dep',proj_name),myZ')
























