%% Scatterplot wndspd, slp, wnddir

clearvars

%first load in the data
dir_nm = '../../hourly_data/gap_hourly/';
%dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
station_name = 'Bellingham Air';
station_nm = 'bham_airport';
%file_nm = 'whidbey_nas_hourly'; % you will have to change this variable for each station
load_file = strcat(dir_nm,station_nm, '_hourly');
load(load_file)
clear dir_nm file_nm load_file
wnddir = wnddir';



%% Plot 
%slp = slp/100; %only for obs data

clf
scatter(wndspd, slp, 5*ones(size(slp)), wnddir)
colormap(phasemap(100))
colorbar
xlabel('Wind Speed [m/s]')
ylabel('Sea Level Pressure [mbar]')

ylim([(min(slp)-10) 1050])
%xlim([0 25])

%% Save the Plot

cd('../../Matlab_Figures/scatter')

outname = sprintf('scatter_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

cd('../../matlab/Climatology')




