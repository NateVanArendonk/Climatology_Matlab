%% This code is for generating distribution plots of the data
%distribution plots will be for wind speed and pressure
%Types of plots
% - Hist for full data - done
% - Hist by direction of speed - done
% - Bar graph of speed by month - done

%---------------Note----------------------
%Run RefineByParameter first before running this code
RefineByParameter
%% Plot distributions for full data

station_nm = 'Whidbey_NAS';

figure
subplot(3,1,1)
histogram(wnddir,36) %bin every 10 degrees
xlabel('Wind Direction (degrees)')
ylabel('Frequency')
title('Wind Direction - degrees')

subplot(3,1,2)
histogram(wndspd, 30)  %30 is just an arbitrary number, play around
xlabel('Wind Speed (m/s)')
ylabel('Frequency')
title('Wind Speed - m/s')
text(15, 70000, ['Data Coverage: ' num2str(coverage) ' years'])
text(15, 50000, ['Maximum Wind Speed: ' num2str(max_wnd) ' m/s'])
text(15, 30000, ['Minimum Pressure: ' num2str(min_slp) ' millibars'])

subplot(3,1,3)
histogram(slp,100) 
title('Pressure - millibars')
xlabel('Pressure (mb)')
ylabel('Frequency')

cd('../../Distributions/hists')
%gtext('test')

%Save the figure
outname = sprintf('FullDataDistributions_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
%mtit(hFig,'Test');  Use this for overall title if you want
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)


%% Now to plot distributions of wind speed by wind direction

figure 
subplot(3,1,1)
histogram(south.wndspd, 30)
xlabel('Wind Speed (m/s)')
ylabel('Frequency')
s = sprintf('Wind Speeds - South (90%c - 191.25%c)', char(176), char(176));
title(s)
%title('Wind Speeds - South (90%c - 191.25%c)', char(176), char(176))

subplot(3,1,2)
histogram(north.wndspd, 30)
xlabel('Wind Speed (m/s)')
ylabel('Frequency')
n = sprintf('Wind Speeds - North ( > 270%c & < 11.25%c)', char(176), char(176));
title(n)

subplot(3,1,3)
histogram(west.wndspd, 30)
xlabel('Wind Speed (m/s)')
ylabel('Frequency')
w = sprintf('Wind Speeds - West (258.75%c - 281.25%c)', char(176), char(176));
title(w)

cd('../histByDirection')
%Save the figure
outname = sprintf('WindsByDirection_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
%mtit(hFig,'Test');  Use this for overall title if you want
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)



%% Plot distributions of wind categories by direction 

figure 
subplot(3,1,1)
histogram(light.wnddir, 36)
xlabel('Wind Direction degrees')
ylabel('Frequency')
title('Light Wind Direction (0 - 10 m/s)')

subplot(3,1,2)
histogram(breeze.wnddir, 36)
xlabel('Wind Direction degrees')
ylabel('Frequency')
title('Strong Breeze Direction (10 - 20 m/s)')

subplot(3,1,3)
histogram(gale.wnddir, 36)
xlabel('Wind Direction degrees')
ylabel('Frequency')
title('Gale Winds Direction ( > 20 m/s)')

cd('../speedByDirection')
%Save the figure
outname = sprintf('SpeedCategory_Direction_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
%mtit(hFig,'Test');  Use this for overall title if you want
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)
%% Plot distribution of wind speed categories for each direction

% figure
% subplot(3,1,1)
% histogram(northL.wnddir, 30)
% 
% subplot(3,1,2)
% histogram(northB.wnddir, 30)
% 
% subplot(3,1,3)
% histogram(northG.wnddir, 30)

%% Create box plots for wind speed by month
%boxplot(wndspd, mo_str)

figure 
subplot(2,1,1)
boxplot(wndspd, mo_str)
xlabel('Month')
ylabel('Wind Speed (m/s)')
title('Wind Speed by Month')

subplot(2,1,2)
boxplot(wnddir, mo_str)
xlabel('Month')
ylabel('Wind Direction (degrees)')
title('Wind Direction by Month')

cd('../box_plots/winds')

%Save the figure
outname = sprintf('WindsByMonth_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
%mtit(hFig,'Test');  Use this for overall title if you want
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)


%% Pressure Distributions
% 
% histogram(slp,100)
% xlabel('Pressure (millibars)')
% ylabel('Frequency')
% %histfit(slp, 100) if you want to see the the of the distribution
% title('Distribution of Atmospheric Pressure')


%% Pressure by month
boxplot(slp, mo_str)
title('Pressure by Month')
xlabel('Month')
ylabel('Pressure (millibars')

cd('../pressure')

%Save the figure
outname = sprintf('PressureByMonth_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
%mtit(hFig,'Test');  Use this for overall title if you want
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)




%% Pressure by Month with distribution

% figure 
% subplot(2,1,1)
% histogram(slp,100)
% xlabel('Pressure (millibars)')
% ylabel('Frequency')
% %histfit(slp, 100) if you want to see the the of the distribution
% title('Distribution of Atmospheric Pressure')
% 
% subplot(2,1,2)
% boxplot(slp, mo_str)
% title('Pressure by Month')
% xlabel('Month')
% ylabel('Pressure (millibars')
% 
% 

cd('../../../matlab/Climatology')

















%% Save the plot 
% outname = sprintf('WindRose_%s_%s',data_type,station_nm);
% hFig = gcf;
% hFig.PaperUnits = 'inches';
% hFig.PaperSize = [8.5 11];
% hFig.PaperPosition = [0 0 7 7];
% print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
% close(hFig)