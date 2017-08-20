%% GEV Fit for Block Maxima

clearvars

%first load in the data
dir_nm = '../../hourly_data/';
%dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
station_name = 'SeaTac';
station_nm = 'seatac';
%file_nm = 'whidbey_nas_hourly'; % you will have to change this variable for each station
load_file = strcat(dir_nm,station_nm, '_hourly');
load(load_file)
clear dir_nm file_nm load_file
wnddir = wnddir';


% for NDBC data get rid of 'hourly' in load_file 
% Also add the following line after wnddir = wndir';
            % wndspd = wndspd_obs;


%% Find yearly max

yr_vec = year(time(1)):year(time(end)); %make a year vec
maxima = NaN(length(yr_vec),1); %create vector to house all of the block maxima
for i = 1:length(yr_vec)
    yr_ind = find(year(time) == yr_vec(i));
    % If there is more than 50% of the hours missing for that year, I will
    % skip it
    if length(yr_ind) < 8760 * .5
        continue
    else
    %max_val = max(wndspd(yr_ind));
        maxima(i) = max(wndspd(yr_ind));
    end
end

nan_ind = isnan(maxima); % Find any nans and get rid of them
maxima(nan_ind) = [];

del_ind = find(maxima < 10);   % find indices less than 10, likely indicating poor data coverage or a large data gap
maxima(del_ind) = []; % get rid of data
yr_vec(del_ind) = []; % get rid of year from year vec

max_del = find(maxima > 35);
maxima(max_del) = [];


clear j yr_ind

% Get GEV statistics about the data
[paramEsts, paramCIs] = gevfit(maxima);
%----------------Results from GEV-------------------------------
% % % kMLE = paramEsts(1);        % Shape parameter
% % % sigmaMLE = paramEsts(2);    % Scale parameter
% % % muMLE = paramEsts(3);       % Location parameter
%% Plot the GEV
% I tinkered with GEV_Test and found a plot that I like better than current
% version below
% Modified from example from link below
%https://www.mathworks.com/help/stats/examples/modelling-data-with-the-generalized-extreme-value-distribution.html
clf
%lowerBnd = paramEsts(3)-paramEsts(2)./paramEsts(1);
lowerBnd = 0;
x = maxima;  
xmax = 1.1*max(x);
bins = floor(lowerBnd):ceil(xmax);

% plot the hist with GEV line
subplot(2,2,[1 3])
h = bar(bins,histc(x,bins)/length(x),'histc');
h.FaceColor = [.8 .8 .8];
xgrid = linspace(lowerBnd,xmax,100);
line(xgrid,gevpdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)));
xlim([lowerBnd xmax]);
plot_tit = sprintf('GEV - PDF - %s', station_name);
title(plot_tit)

ax = gca;  % Play with the Axes 
ax.XLim = [8 xmax*1.1];
% Add GEV parameters to the plot
tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f \nn: %d',...
    paramEsts(1),paramEsts(2),paramEsts(3), length(maxima));
%text(12,0.15, tbox)

% Add box around the text
dim = [.29 .5 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');





xlabel('Max Hourly Wind Speed Obs [m/s]')
ylabel('Probability Density')
%legend('Hourly','Six-Hr Avg.','Location','NorthEast')
box on

% Calculate the CDF
cdf = 1 - gevcdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)); % create CDF from GEV PDF

% % % % % % % % % x = maxima;  
% % % % % % % % % nblocks = length(maxima); 
% % % % % % % % % x_min = 8;
% % % % % % % % % x_max = 37;
% % % % % % % % % x_bin = 0.1;
% % % % % % % % % hist_bin = 0.5;
% % % % % % % % % 
% % % % % % % % % % Calculate GEV Parameters
% % % % % % % % % paramEsts = gevfit(x);  % grab GEV values 
% % % % % % % % % xgrid = x_min:x_bin:x_max;  % create evenly spaced grid
% % % % % % % % % histgrid = x_min:hist_bin:x_max;  % create locations for bars
% % % % % % % % % pdf = gevpdf(xgrid,paramEsts(1),paramEsts(2), paramEsts(3));  % create PDF from GEV parameters
% % % % % % % % % cdf = 1 - gevcdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)); % create CDF from GEV PDF
% % % % % % % % % 
% % % % % % % % % %-------Note----------%
% % % % % % % % % % Height on CDF refers to area under curve on PDF, and thus the probability
% % % % % % % % % 
% % % % % % % % % % Now plot the GEV with Block Maxima
% % % % % % % % % myhist = histc(x,histgrid);  % counts the number of values within the binned ranges of histgrid
% % % % % % % % % myhist = myhist/sum(myhist*hist_bin);
% % % % % % % % % hold on
% % % % % % % % % subplot(2,2,[1 3])
% % % % % % % % % bar(histgrid,myhist,'FaceColor',[.8 .8 1])
% % % % % % % % % line(xgrid,pdf);
% % % % % % % % % plot_tit = sprintf('GEV - PDF - %s', station_name);
% % % % % % % % % title(plot_tit)
% % % % % % % % % 
% % % % % % % % % % Plot Parameters
% % % % % % % % % ax = gca;  % Play with the Axes 
% % % % % % % % % ax.XLim = [10 37];
% % % % % % % % % 
% % % % % % % % % 
% % % % % % % % % % Add GEV parameters to the plot
% % % % % % % % % tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f',paramEsts(1),paramEsts(2),paramEsts(3));
% % % % % % % % % text(20,0.2, tbox)
% % % % % % % % % 
% % % % % % % % % xlabel('Max Hourly Wind Speed Obs[m/s]')
% % % % % % % % % ylabel('Probability')
% % % % % % % % % %legend('Hourly','Six-Hr Avg.','Location','NorthEast')
% % % % % % % % % box on





%% Calculate Recurrence Interval

%-------Note-----------%
%RI = 1/Probability
%Knowing CDF and thus the probability, I can calculate the Recurrence

RI = 1./cdf;
subplot(2,2,[2 4])
plot(xgrid, RI)
ylim([0 100])
plot_tit = sprintf('Recurrence Interval - %s', station_name);
title(plot_tit)
xlabel('Wind Speed [m/s]')
ylabel('Time [years]')


ax = gca;
set(gca,'XMinorTick','on')  %add minor tick marks on x-axis

box on 
grid on

% Generate specific values for recurrence levels

R100MLE = gevinv(1-1./100,paramEsts(1),paramEsts(2),paramEsts(3));
R50MLE = gevinv(1-1./50,paramEsts(1),paramEsts(2),paramEsts(3));
R25MLE = gevinv(1-1./25,paramEsts(1),paramEsts(2),paramEsts(3));
R10MLE = gevinv(1-1./10,paramEsts(1),paramEsts(2),paramEsts(3));
R5MLE = gevinv(1-1./5,paramEsts(1),paramEsts(2),paramEsts(3));
R2MLE = gevinv(1-1./2,paramEsts(1),paramEsts(2),paramEsts(3));

% Add GEV parameters to the plot
tbox = sprintf('100 yr: %4.2f m/s\n50 yr: %4.2f m/s\n25 yr: %4.2f m/s\n10 yr: %4.2f m/s\n5 yr: %4.2f m/s\n2 yr: %4.2f m/s'...
    ,R100MLE, R50MLE, R25MLE, R10MLE, R5MLE, R2MLE);
%text(4,16, tbox)

% Add box around the text
dim = [.62 .3 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');


%% Save the Plot

cd('../../Matlab_Figures/GEV/Updated')

outname = sprintf('GEV_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

cd('../../../matlab/Climatology')
