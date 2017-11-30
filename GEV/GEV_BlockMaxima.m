%% GEV Fit for Block Maxima

clearvars

%first load in the data
dir_nm = '../../hourly_data/gap_hourly/';
station_name = 'Whidbey';
station_nm = 'whidbey_nas';

load_file = strcat(dir_nm,station_nm, '_hourly');
load(load_file)

clear dir_nm file_nm load_file
wnddir = wnddir';


% for NDBC data get rid of 'hourly' in load_file 
% Also add the following line after wnddir = wndir';
            % wndspd = wndspd_obs;
%% Find yearly max

% Create yearly vector
yr_vec = year(time(1)):year(time(end)); 

% Preallocate
data = NaN(length(yr_vec),1); 

% Grab yearly max
for i = 1:length(yr_vec)
    yr_ind = find(year(time) == yr_vec(i));
    if length(yr_ind) < 8760 * .5
        continue
    else
        data(i) = max(wndspd(yr_ind));
    end
end

% Find any nans and get rid of them
nan_ind = isnan(data); 
data(nan_ind) = [];

% find indices less than 10, likely indicating poor data coverage or a large data gap
del_ind = find(data < 10);  
data(del_ind) = [];
yr_vec(del_ind) = []; 

% Get rid of data that is likely an outlier
max_del = find(data > 35);
data(max_del) = [];

clear j yr_ind
%% Perform Block Maxia GEV fit to data

[parmhat, parmCI] = gevfit(data);

%----------------Results from GEV-----------------
% kMLE = paramEsts(1);        % Shape parameter
% sigmaMLE = paramEsts(2);    % Scale parameter
% muMLE = paramEsts(3);       % Location parameter
%% Plot the GEV

% Variables needed for plotting of histogram
x = data;
lowerBnd = min(x)-2;
xmax = 1.1*max(x);
bins = floor(lowerBnd):ceil(xmax);

% Plot the distribution
clf
subplot(2,2,[1 3])
h1 = bar(bins,histc(x,bins)/length(x),'histc');
h1.FaceColor = [.8 .8 .8];

% Add line of fit to histogram
xgrid = linspace(lowerBnd,xmax,100);
l1 = line(xgrid,gevpdf(xgrid,parmhat(1),parmhat(2),parmhat(3)));

% Plot Title
plot_tit = sprintf('GEV - PDF - %s', station_name);
title(plot_tit)

% Play with the Axes 
ax = gca;  
ax.XLim = [lowerBnd 1.1*xmax];

% Add GEV parameters to the plot in a text box
tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f \nn: %d',...
    parmhat(1),parmhat(2),parmhat(3), length(data));
% Add box around the text and dictate location
dim = [.31 .5 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');

% Label Axes
xlabel('Max Hourly Wind Speed Obs [m/s]')
ylabel('Probability Density')
box on

% Calculate the CDF
cdf = 1 - gevcdf(xgrid,parmhat(1),parmhat(2),parmhat(3)); % create CDF from GEV PDF
%% Calculate Recurrence Interval
%-------Note-----------%
%RI = 1/Probability

% Calculate Recurrence Interval
RI = 1./cdf;

% Plot recurrence interval of 
subplot(2,2,[2 4])
plot(xgrid, RI)

% Title and axis labels 
plot_tit = sprintf('Recurrence Interval - %s', station_name);
title(plot_tit)
xlabel('Wind Speed [m/s]')
ylabel('Time [years]')

% Add minor tick marks on x-axis and limits
ax = gca;
set(gca,'XMinorTick','on')  
ax.XLim = [lowerBnd xmax];
ax.YLim = [0 100];
box on 
grid on

% Generate specific values for recurrence levels
R100MLE = gevinv(1-1./100,parmhat(1),parmhat(2),parmhat(3));
R50MLE = gevinv(1-1./50,parmhat(1),parmhat(2),parmhat(3));
R25MLE = gevinv(1-1./25,parmhat(1),parmhat(2),parmhat(3));
R10MLE = gevinv(1-1./10,parmhat(1),parmhat(2),parmhat(3));
R5MLE = gevinv(1-1./5,parmhat(1),parmhat(2),parmhat(3));
R2MLE = gevinv(1-1./2,parmhat(1),parmhat(2),parmhat(3));

% Add GEV parameters to the plot in a textbox
tbox = sprintf('100 yr: %4.2f m/s\n50 yr: %4.2f m/s\n25 yr: %4.2f m/s\n10 yr: %4.2f m/s\n5 yr: %4.2f m/s\n2 yr: %4.2f m/s'...
    ,R100MLE, R50MLE, R25MLE, R10MLE, R5MLE, R2MLE);
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
