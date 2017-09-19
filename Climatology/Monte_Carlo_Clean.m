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

% rth values to collect (can vary)
r_num = 10;

% Min distance between events (half hour incr) 
min_sep = 12;

% Preallocate
data = zeros(length(yr),r_num);

% Find rth number of max events per year
for yy=1:length(yr)
    wl_inds = year(tides.time) == yr(yy);
    val_ind = tides.WL_VALUE(wl_inds);
    for r=1:r_num
        [data(yy,r), I] = max(val_ind);
        pop_inds = max([1 I-min_sep]):min([length(val_ind) I+min_sep]);
        val_ind(pop_inds) = [];
    end
end

% Grab GEV estimates
[parmhat, parmCI] = gevfit(data(:,1));

% Calculate Standard Error for each parameter 
kSE = (parmCI(1,1)-parmhat(1))/2;
sigSE = (parmCI(1,2)-parmhat(2))/2;
muSE = (parmCI(1,3)-parmhat(3))/2;

% Preallocate
num_its = 10000;
k_hat = zeros(1,num_its);
sig_hat = k_hat;
mu_hat = k_hat;

% Run Monte Carlo simulation 
for jj = 1:num_its
    k_hat(1,jj) = parmhat(1) + (kSE * randn(1,1));
    sig_hat(1,jj) = parmhat(2) + (sigSE * randn(1,1));
    mu_hat(1,jj) = parmhat(3) + (muSE * randn(1,1));
end

% Create X-Axis for data for plotting 
xlims = [min(data(:))+ten_mean, 1.1*(max(data(:))+ten_mean)];
x_axis = linspace(xlims(1),xlims(2),1000);

% Preallocate
cdf_hat = zeros(length(x_axis),num_its);

% Estimate the CDF 
count = 1;
for ii = 1:num_its
    cdf_hat(:,count) = 1 - gevcdf(x_axis,k_hat(ii),sig_hat(ii),mu_hat(ii)+ten_mean);
    count = count + 1;
end

% Calculate RI
RI_hat = 1./cdf_hat;

%% Find the water level at each yearly recurrence interval

% Preallocate
years = 1:1:100;
indices = zeros(length(years),length(RI_hat));

% Find indices of each yearly water level
for col = 1:length(RI_hat)
    temp_col = RI_hat(:,col);
    for yr = 1:length(years)
        temp_ind = findnearest(yr, temp_col);
        indices(yr,col) = temp_ind(1);
    end
end
%%
% Grab water levels for each indice 
wl_mat = x_axis(indices);

% Calculate mean and standard deviation for each yearly water level
mean_mat = mean(wl_mat,2);
std_mat = std(wl_mat,0,2);
std_mat = std_mat';
%% Plot to see 1 Standard Deviation and Histogram of water levels 
std_val = 50;
y = 1:.5:500;
x1 = ones(length(y))*(mean_mat(std_val,1)-std_mat(1,std_val));
x2 = ones(length(y))*(mean_mat(std_val,1)+std_mat(1,std_val));

clf
hist(wl_mat(std_val,:),100)
hold on
line(x1,y)
line(x2,y)
%% Plot GEV estimates for RI with confidence intervals for recurrence
x_axis = linspace((min(data(:))+ten_mean),4,length(std_mat));
% Grab CDF based on GEV parameters
cdf = 1 - gevcdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+ten_mean);

% Grab the estimate for recurrence interval
RI = 1./cdf;

clf
plot(x_axis, RI)
line(x_axis - std_mat, RI, 'LineStyle', '--', 'Color', 'red');
line(x_axis + std_mat, RI, 'LineStyle', '--', 'Color', 'red');
mean_line = line(mean_mat, RI, 'Color', 'black');


for k = 1:100:num_its
    temp_cdf = 1 - gevcdf(x_axis,k_hat(k),sig_hat(k),mu_hat(k)+ten_mean);
    temp_RI = 1./temp_cdf;
    line(x_axis, temp_RI, 'Color', [.7 .7 .7])
end
ax = gca;
ax.XLim = [3.2 4];
ax.YLim = [0 100];
xlabel('Maximum TWL [m]');
ylabel('Recurrence Interval [years]');
grid on
hold on 

ri_line = line(x_axis, RI, 'Color', 'blue', 'LineWidth', 2);
lower = line(x_axis - std_mat, RI, 'LineStyle', '--', 'Color', 'red', 'LineWidth', 2);
upper = line(x_axis + std_mat, RI, 'LineStyle', '--', 'Color', 'red', 'LineWidth', 2);
