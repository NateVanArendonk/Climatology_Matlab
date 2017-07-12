%% GEV Fit for Block Maxima

clearvars

%first load in the data
dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
station_name = 'Whidbey NAS';
station_nm = 'Whidbey_NAS';
file_nm = 'whidbey_hourly'; % you will have to change this variable for each station
load_file = strcat(dir_nm,file_nm);
load(load_file)
clear dir_nm file_nm load_file
wnddir = wnddir';


%% Find yearly max

yr_vec = year(time(1)):year(time(end)); %make a year vec
maxima = NaN(length(yr_vec),1); %create vector to house all of the block maxima
for i = 1:length(yr_vec)
    yr_ind = find(year(time) == yr_vec(i));
    %max_val = max(wndspd(yr_ind));
    maxima(i) = max(wndspd(yr_ind));
end
clear i
% Get GEV statistics about the data
[paramEsts, paramCIs] = gevfit(maxima);
%----------------Results from GEV-------------------------------
% % % kMLE = paramEsts(1);        % Shape parameter
% % % sigmaMLE = paramEsts(2);    % Scale parameter
% % % muMLE = paramEsts(3);       % Location parameter
%% Plot the GEV
x = maxima;  
nblocks = length(maxima); 
x_min = 0;
x_max = 30;
x_bin = 0.1;
hist_bin = 0.5;

% Calculate GEV Parameters
paramEsts = gevfit(x);  % grab GEV values 
xgrid = 0:x_bin:30;  % create evenly spaced grid
histgrid = x_min:hist_bin:x_max;  % create locations for bars
pdf = gevpdf(xgrid,paramEsts(1),paramEsts(2), paramEsts(3));  % create PDF from GEV parameters
cdf = 1 - gevcdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)); % create CDF from GEV PDF

%-------Note----------%
% Height on CDF refers to area under curve on PDF, and thus the probability

% Now plot the GEV with Block Maxima
myhist = histc(x,histgrid);  % counts the number of values within the binned ranges of histgrid
myhist = myhist/sum(myhist*hist_bin);
hold on
bar(histgrid,myhist,'FaceColor',[.8 .8 1])
line(xgrid,pdf);

% Plot Parameters
ax = gca;  % Play with the Axes 
ax.XLim = [10 28];

% Add GEV parameters to the plot
tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f',paramEsts(1),paramEsts(2),paramEsts(3));
text(21,0.3, tbox)

xlabel('Max Hourly Wind Speed Obs[m/s]')
ylabel('Probability')
%legend('Hourly','Six-Hr Avg.','Location','NorthEast')
box on


%% Plot Hist and GEV

%---------Old Way, Use Method Above, provides a finer resolution-----------
% uprbnd = 1.1*max(maxima); %upper bound
% lowerBnd = min(maxima)/1.1;  %lower bound
% bins = floor(lowerBnd):ceil(uprbnd);  %number of bins
% h = bar(bins,histc(maxima,bins)/length(maxima),'histc'); %plot the hist
% h.FaceColor = [.9 .9 .9]; %coloring
% ygrid = linspace(lowerBnd,uprbnd,100);  %line for GEV fit
% line(ygrid,gevpdf(ygrid,kMLE,sigmaMLE,muMLE));  %plot the line
% xlabel('Block Maximum');
% ylabel('Probability Density');
% xlim([lowerBnd uprbnd]);
% 
% 
% tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f',paramEsts(1),paramEsts(2),paramEsts(3));
% %text(ax.XLim(1)*1.01,ax.YLim(2)*.9,tbox)
% text(20,0.3, tbox)
% 
% 
%% Save the Plot
outname = sprintf('GEV_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)


%% Calculate Recurrence Interval

%-------Note-----------%
%RI = 1/Probability
%Knowing CDF and thus the probability, I can calculate the Recurrence

RI = 1./cdf;
plot(xgrid, RI)
ylim([0 100])
plot_tit = sprintf('Recurrence Interval - %s', station_nm);
title(plot_tit)
xlabel('Wind Speed[m/s]')
ylabel('Time [years]')


ax = gca;
set(gca,'XMinorTick','on')  %add minor tick marks on x-axis

box on 
grid on


%% Save the Plot
outname = sprintf('RI_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)