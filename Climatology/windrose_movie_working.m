%% Code to create a wind rose diagram from hourly time series data
clearvars

file_nm = 'bham_airport_hourly.mat'; % change this to the location of interest
file_loc = '../../hourly_data/gap_hourly/';
file_load = strcat(file_loc, file_nm);

%load in the data
load(file_load)
clear stn_nm file_loc file_load

yr_vec = year(time(1)):1:year(time(end));


%% Plot the Wind Rose
data_type = 'NDBC';
station_nm = 'Bham_Airport';  %Change this depending on station
options.nDirections = 36;  % most stations show sub-5 degree binning
%sta_num = [1 2 3 4 5];
options.vWinds = [0 5 10 15 20 25]; %Specify the wind speeds that you want to appear on the windrose
options.AngleNorth = 0;
options.AngleEast = 90;
options.labels = {'North (360°)','South (180°)','East (90°)','West (270°)'};
options.TitleString = [];
%options.axes = ax;
%inds_w = (~isnan(O.wnddir) & ~isnan(O.wndspd));
%[figure_handle,count,speeds,directions,Table] = WindRose(wnddir,wndspd,options);
%title('Obs - ', station_nm)
%suptitle('Paine Field')


%%
nframe=length(yr_vec);
mov(1:nframe)= struct('cdata',[],'colormap',[]);
set(gca,'nextplot','replacechildren')
for k=1:nframe
    inds = find(year(time) == yr_vec(k));
    [figure_handle,count,speeds,directions,Table] = WindRose(wnddir(inds),wndspd(inds),options);
    mov(k)=getframe(gcf);
end
movie2avi(mov, '1moviename.avi', 'compression', 'None');