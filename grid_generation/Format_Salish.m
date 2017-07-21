% Salish Model
%--------------- For Nates Purposes--------------------
% elevation: Meters
% units: Lat Long
% Datum: MLLW - NAVD 88
% Spatial Reference System: EPSG::4269
% 3 arc-seconds ~ 90 m resolution
% Spatial Reference is to CORNER CORNER CORNER
clearvars



% Import the Data
xyz = ascii2xyz('pnw_dem/nw_pacific_crm_v1.asc');


my_zone = '4269'; %? 
my_unit = 'sf'; %'sf'  %?

x = xyz(:,1);   % Grabs all the x's
y = xyz(:,2);   % Grabs all the y's
z = xyz(:,3);   % Grabs all the z's

% Refine samples to eliminate unneeded locations because xyz is for the
% entire state of WA


bound = (x >= -125 & x <= -122 & y >= 47);  %x, y, z indicies of interest

% Grab samples of x,y,z that are within bounded box
x = x(bound);
y = y(bound);
z = z(bound);




%Downsample and grid
% Arc Seconds - Each degree is subdivided into 60 minutes -> 60 seconds
N = 1;
dx = diff(x);
dx = dx(1);
%dx = 92.5926; %Need to figure  this out

% dx refers to change in x so that is the change in values in x direction
% thus refering to longitude lines

% ~111,111 meters per latitude, so 111,111/60min/60sec = 30.8642
% with this being a 3-arc second resolution multiply this by 3
%dx is there for equal to 92.5926 

% x = xyz(1:N:end,1);
% y = xyz(1:N:end,2);
% z = xyz(1:N:end,3);

X = min(x):dx:max(x);
Y = min(y):dx:max(y);

[X, Y] = meshgrid(X,Y);

tic
Z = griddata(x,y,z,X,Y);  % with full data set, takes 6 minutes to run %This takes 17 minutes to run
toc
%85 seconds


% Convert from state plane to lat/lon
%[Lon,Lat] = sp_proj(my_zone,'inverse',X(:),Y(:),my_unit);

%Lat = reshape(Lat,size(X));
%Lon = reshape(Lon,size(X));
Lat = Y;
Lon = X;

Lat = reshape(Lat,size(X));
Lon = reshape(Lon,size(X));


save('WA_dem.mat','X','Y','Lat','Lon','Z')


%imagesc, look in to this

figure
pcolor(Lon,Lat,Z)
shading flat
hold on
contour(Lon,Lat,Z,[0 0],'k')
colorbar
%caxis([-100 0])
%colormap(bone)
%colormap(demcmap(Z,1000)) % Don't Have mapping toolbox

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
%colormap(demcmap(Z,1000))  % Don't have Mapping Toolbox
% This makes the land and ocean look pretty, get from Sean when needed


%% Make Grid in UTM for D3D
%   JDF Channel and Basin
% xll = 3.6e5;
% yll = 5.3e6;
% xrr = 5.4e5;
% yrr = 5.4e6;
%   Just Basin
xll = 3.5e5; % I picked these numbers based off of their position and how I wanted to generate the grid
yll = 5.2e6;
xrr = 5.6e+5;
yrr = 5.43e+6;
dx = 500; %meters

myx = xll:dx:xrr;
myy = yll:dx:yrr;

[myX, myY] = meshgrid(myx,myy);

myZ = griddata(x_utm,y_utm,Z,myX,myY);

figure
pcolor(myX,myY,myZ)
shading flat
hold on
contour(myX,myY,myZ,[0 0],'k')

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
%colormap(demcmap(test,1000))

%% Make D3D grid
% Answer Y to negate points (D3D expects depth, not elevtation)
% Answer 9 to extend
addpath 'C:\openearthtools\matlab\applications\delft3d_matlab'

proj_name = 'salish_500m';

wlgrid('write','Filename',proj_name,'X',myX','Y',myY','AutoEnclosure')
wldep('write',sprintf('%s.dep',proj_name),myZ')
























