%% GEV Fit for Block Maxima

clearvars

%first load in the data
%dir_nm = '../../hourly_data/';
dir_nm = '../../Downloaded Raw Data/';
station_name = 'SeaTac';
station_nm = 'seatac';
load_file = strcat(dir_nm,station_nm);
load(load_file)
clear dir_nm file_nm load_file
%wnddir = wnddir';

% for NDBC data get rid of 'hourly' in load_file 
% Also add the following line after wnddir = wndir';
            % wndspd = wndspd_obs;
            
%% Code to make datenum from dates in station_data

% if it is not in the correct format, convert it 
if ~isfield(station_data, 'usaf')

    temp = station_data;
    clear station_data

    station_data.usaf = temp.USAF;
    station_data.wban = temp.WBAN;
    station_data.yr = temp.YR;
    station_data.mo = temp.MO;
    station_data.da = temp.DA;
    station_data.hr = temp.HR;
    station_data.mn = temp.MN;
    station_data.wnddir = temp.DIR;
    station_data.wndspd = temp.SPD;
    %station_data.wndmaxspd = temp.GUS;
    station_data.airtemp = temp.TEMP;
    station_data.dewp = temp.DEWP;
    station_data.slp = temp.SLP;
    station_data.alt = temp.ALT;
    station_data.stp = temp.STP;

    clear temp
    
    station_data.dtnum = [];

    for i = 1:length(station_data.yr)
        station_data.dtnum(end+1) = datenum(station_data.yr(i), station_data.mo(i), station_data.da(i), station_data.hr(i), station_data.mn(i), 30);
    end


    clear i j 

    station_data.time = datenum(station_data.yr, station_data.mo,...
        station_data.da, station_data.hr, station_data.mn, 30);

    station_data.time = station_data.time';
    station_data.dtnum = station_data.dtnum';
end

    %Convert to m/s
station_data.wndspd = station_data.wndspd * .44704;        
            
            

%% Change entire structure to go from oldest to current date     
[~, I] = sort(station_data.time,'ascend');
%sort the time vector in ascending order from oldest date to current data
station_data.time = station_data.time(I);
station_data.time_copy = station_data.time;

station_data.usaf = station_data.usaf(I);
station_data.wban = station_data.wban(I);
station_data.yr = station_data.yr(I);
station_data.mo = station_data.mo(I);
station_data.da = station_data.da(I);
station_data.hr = station_data.hr(I);
station_data.mn = station_data.mn(I);
station_data.wnddir = station_data.wnddir(I);
station_data.wndspd = station_data.wndspd(I);
%station_data.wndmaxspd = station_data.wndmaxspd(I);
station_data.airtemp = station_data.airtemp(I);
station_data.dewp = station_data.dewp(I);
station_data.slp = station_data.slp(I);
station_data.alt = station_data.alt(I);
station_data.stp = station_data.stp(I);

%% Find yearly max
yr_vec = year(station_data.time(2)):year(station_data.time(end-10)); %make a year vec, -10 because of NaNs
maxima = NaN(length(yr_vec),1); %create vector to house all of the block maxima
for i = 1:length(yr_vec)
    yr_ind = find(year(station_data.time) == yr_vec(i));
    % If there is more than 50% of the hours missing for that year, I will
    % skip it
    if length(yr_ind) < 8760 * .5
        maxima(i) = NaN;
    else
    %max_val = max(wndspd(yr_ind));
        maxima(i) = max(station_data.wndspd(yr_ind));
    end
end

nan_ind = isnan(maxima); % Find any nans and get rid of them
maxima(nan_ind) = [];

del_ind = find(maxima < 10);   % find indices less than 10, likely indicating poor data coverage or a large data gap
maxima(del_ind) = []; % get rid of data
yr_vec(del_ind) = []; % get rid of year from year vec


%nan_ind = find(maxima > 40);
%maxima(nan_ind) = [];


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
ax.XLim = [8 xmax*1.3];

% Add GEV parameters to the plot
tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f \nn: %d',...
    paramEsts(1),paramEsts(2),paramEsts(3), length(maxima));
%text(10,0.25, tbox)

% Add box around the text
dim = [.28 .35 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');



xlabel('Max Hourly Wind Speed Obs [m/s]')
ylabel('Probability Density')
%legend('Hourly','Six-Hr Avg.','Location','NorthEast')
box on

% Calculate the CDF - CDF will give me the probability of values 
cdf = 1 - gevcdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)); % create CDF from GEV PDF


% ----------Notes-----------
% - PDF sums to 1, represents probability density
% - CDF is the cumulative PDF, represents probability
% - CDF is the probability of the random variable being less than X

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
%text(6,60, tbox)

dim = [.62 .3 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');

%%
% Save the Plot
cd('../../Matlab_Figures/GEV/Updated')

outname = sprintf('GEV_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

cd('../../../matlab/Climatology')
