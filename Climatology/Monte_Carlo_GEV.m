%% Code to perform a Monte Carlo simulation on GEV parameters for assessment of RI
% First load in the data
clearvars

%first load in the data
dir_nm = '../../COOPS_tides/';
%dir_nm = '../../hourly_data/gap_hourly/Station_Choice/';
station_name = 'Seattle';
station_nm = 'seattle';

load_file = strcat(dir_nm,station_nm,'/',station_nm,'_hrV');
load(load_file)
clear dir_nm file_nm load_file

%% Grab Maxima 

% Years available
yr = year(tides.time(1)):year(tides.time(end));

% Find mean of last 10 years 
tinds = find(year(tides.time) == yr(end) - 10);
inds = tinds(1):length(tides.WL_VALUE);
ten_mean = mean(tides.WL_VALUE(inds));

% Detrend tides
tides.WL_VALUE = detrend(tides.WL_VALUE);

% rth values to collect (can use less later)
r_num = 10;

% Min distance between events (half hour incr) 24 if half our, 12 if hour
min_sep = 12;

% Preallocate
maxima = zeros(length(yr),r_num);

% Loop
for yy=1:length(yr)
    inds = year(tides.time) == yr(yy);
    val_ind = tides.WL_VALUE(inds);
    for r=1:r_num
        [maxima(yy,r), I] = max(val_ind);
        pop_inds = max([1 I-min_sep]):min([length(val_ind) I+min_sep]);
        val_ind(pop_inds) = [];
    end
end

% Create variable with water level back to datum
data_datum = maxima + ten_mean;

% Numer of data points
n = length(maxima);

%% Calculate estimated GEV parameters 

% Grab GEV estimates
[parmhat parmCI] = gevfit(maxima(:,1));

% Grab specific params
khat = parmhat(1);
sighat = parmhat(2);
muhat = parmhat(3);

% Calculate Standard Error for each parameter 
kSE = (parmCI(1,1)-khat)/2;
sigSE = (parmCI(1,2)-sighat)/2;
muSE = (parmCI(1,3)-muhat)/2;

%% Run Monte Carlo for Parameters 
tic
% preallocate
its = 10000;
monteK = zeros(1,its);
monteSig = monteK;
monteMu = monteK;

% run simulation
for jj = 1:its
    monteK(1,jj) = khat + (kSE * randn(1,1));
    monteSig(1,jj) = sighat + (sigSE * randn(1,1));
    monteMu(1,jj) = muhat + (muSE * randn(1,1));
end
toc
%% Now calculate RI using results from Monte Carlo simulation 
tic
% First calculate cdf 
x_axis = linspace((min(maxima(:))+ten_mean),4,1000); % Note, use a large number here to enhance accuracy of finding each year later on
count = 1;
cdf = zeros(length(x_axis),length(monteK));

for ii = 1:length(monteK)
    cdf(:,count) = 1 - gevcdf(x_axis,monteK(ii),monteSig(ii),monteMu(ii)+ten_mean);
    count = count + 1;
end
toc

% Calculate RI
RI = 1./cdf;
%% Get all the points where RI is the 1,2,3...100 year level

% Create empty vector to populate
inds = zeros(1,length(RI));

yr_vec = 1:1:100;
inds_mat = zeros(length(yr_vec),length(RI));
tic
% Find each location of the jth year water level
for j = 1:length(RI)
    % Grab one column of data
    vals = RI(:,j);
    for m = 1:length(yr_vec)
        % Find the location of each yearly water level
        temp_ind = findnearest(m,vals);
        % Add it to the matrix 
        inds_mat(m,j) = temp_ind(1);
    end
end

wl_mat = x_axis(inds_mat);

toc

% Get the mean and standard deviation for each yearly water level
mean_mat = mean(wl_mat,2);
std_mat1 = std(wl_mat,0,2);

%% Plot GEV estimates for RI with confidence intervals for recurrence
% Base on standard deviation of 100 year levels
x_axis = linspace((min(maxima(:))+ten_mean),4,length(std_mat));
% Grab CDF based on GEV parameters
cdf = 1 - gevcdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+ten_mean);

% Grab the estimate for recurrence interval
RI = 1./cdf;

plot(x_axis, RI)
lower = line(x_axis - std_mat, RI, 'LineStyle', '--', 'Color', 'red');
upper = line(x_axis + std_mat, RI, 'LineStyle', '--', 'Color', 'red');
%mean_line = line(mean_mat, RI, 'Color', 'black');


for k = 1:10:length(monteK)
    temp_cdf = 1 - gevcdf(x_axis,monteK(k),monteSig(k),monteMu(k)+ten_mean);
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
%mean_line = line(mean_mat, RI, 'Color', 'black');


