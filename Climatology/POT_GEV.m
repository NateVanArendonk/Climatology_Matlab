%% Code to perform a Monte Carlo simulation on GEV parameters and Assess RI

% Load in data
clearvars                                                                  
dir_nm = '../../COOPS_tides/';
station_nm = 'seattle';
load_file = strcat(dir_nm,station_nm,'/',station_nm,'_hrV');
load(load_file)
clear dir_nm file_nm load_file
%% Run Monte Carlo on GEV estimates for data and calculate Recurrence Interval

% Years available
yr = year(tides.time(1)):year(tides.time(end));

% Find mean of last 10 years 
tinds = find(year(tides.time) == yr(end) - 10);
wl_inds = tinds(1):length(tides.WL_VALUE);
ten_mean = mean(tides.WL_VALUE(wl_inds));

% Detrend tides
tides.WL_VALUE = detrend(tides.WL_VALUE);
% Convert to feet
%tides.WL_VALUE = tides.WL_VALUE*3.28084;


% Establish Threshold - Use R to plot Mean Residual Life Plot to grab threshold
threshold = 1.2;

% Find indices above threshold
thresh_inds = find(tides.WL_VALUE > threshold);

% Filter out lower than threshold values
data = tides.WL_VALUE(thresh_inds);
%% Fit GPD to data
parmhat = gpfit(data);

xlim = [(min(data(:)))-.5 (1.1*max(data(:)))];

subplot(2,2,[1 3])
pdf_data = histogram(data(:)+ten_mean,10,'Normalization','pdf');
mycolors = jet(10);
hold on

x_axis = linspace(xlim(1),xlim(2)+.5,100);
pdf_gev = gppdf(x_axis,parmhat(1),parmhat(2)+ten_mean); 
plot(x_axis,pdf_gev,'Color',mycolors(1,:))

ax = gca;
ax.XLim = ([2.2 4.4]);

%% 
rng default
t=trnd(5,5000,1);
y = t(t>2)-2;
parmhat = gpfit(y);