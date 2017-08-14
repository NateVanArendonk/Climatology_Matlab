%% Code to create a wind rose diagram from hourly time series data
clearvars

file_nm = 'bham_airport_hourly.mat'; % change this to the location of interest
file_loc = '../../hourly_data/gap_hourly/';
file_load = strcat(file_loc, file_nm);

%load in the data
load(file_load)
clear stn_nm file_loc file_load


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
[figure_handle,count,speeds,directions,Table] = WindRose(wnddir,wndspd,options);
%title('Obs - ', station_nm)
%suptitle('Paine Field')


%% Save the wind rose 
cd('../../Matlab_Figures/Windrose')
outname = sprintf('WindRose_%s_%s',data_type,station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)
cd('../../Matlab/Matlab_windRose')

