clearvars
fid = '../../Matlab_Random/testXYZ1.txt';
xyz = dlmread(fid, ' ');
clear fid



x = xyz(:,1);   % Grabs all the x's
y = xyz(:,2);   % Grabs all the y's
z = xyz(:,3);   % Grabs all the z's

bound = (x >= -125.5 & x <= -122 & y >= 47);  %x, y, z indicies of interest

% Grab samples of x,y,z that are within bounded box
x = x(bound);
y = y(bound);
z = z(bound);


%%
X = x;
Y = y;


Lon = unique(X);  % find unique values of Longitude
Lat = unique(Y);  % find unique values of Latitude


[X, Y] = meshgrid(Lon, Lat);
Z = griddata(x,y,z,X,Y);

% Xi = arrayfun( @(x) find(Lon==x), X );  % Still confused on how this works 
% Yi = arrayfun( @(y) find(Lat==y), Y );
% Li = Yi + (Xi-1) * numel(Lat);
% XYZ = nan(numel(Lat), numel(Lon));
% XYZ( Li ) = z;
% Z = XYZ;
% surf(Lon, Lat, Z)
% 
% 
% %clear bound Li Xi Yi
% 
% 
% 
% na_ind = find(isnan(Z));
% Z(na_ind) = 999;
% 
% 
figure
pcolor(Z)
shading flat
hold on
contour(Lon,Lat,Z,[0 0],'k')
colorbar
caxis([-100 0])
colormap(bone)
colormap(demcmap(Z,1000)) 
% 



