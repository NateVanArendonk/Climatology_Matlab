% EVT - Block Maxima Analysis 
%   Both from Observations & Predictions
%   Wind Speed may be partitioned by direction range
%
%   Simple block maxima and GEV Fit
%   Rth largest 

clearvars
addpath('D:/Functions_Matlab/')

% Define sites of interest to extract
Station = readStationMeta();

% Station to use
sta_num = 3; %Smith

% Load Obs
fol_loc = '../DownloadMetData';
data_type = 'obs';
fname = sprintf('%s/%s_%s.mat',fol_loc,data_type,Station.shortName{sta_num});
O = load(fname);

% Generate 6-hour smoothed records (match more closely with NNRP predictions
O.wnddir_hourly = O.wnddir;
O.wndspd_hourly = O.wndspd_obs;
O.wnddir = conv(O.wnddir_hourly,1/6*ones(1,6),'same');
O.wndspd_obs = conv(O.wndspd_hourly,1/6*ones(1,6),'same');

% Load NNRP Predictions
fol_loc = '../ExtractNNRP/Output';
data_type = 'NNRP';
fname = sprintf('%s/%s_%s.mat',fol_loc,data_type,Station.shortName{sta_num});
N = load(fname);
N.time = datenum(1950,1,1):(1/4):datenum(2010,12,31,18,0,0); % Add time vector

% Load HRDPS Predictions
fol_loc = '../ExtractHRDPS/Output';
data_type = 'HRDPS';
fname = sprintf('%s/%s_%s.mat',fol_loc,data_type,Station.shortName{sta_num});
H = load(fname);

%% Plot Wind Roses

% Set Wind Rose options
options.nDirections = 32*2;
options.vWinds = [0 5 10 15 20 25];
options.AngleNorth = 0;
options.AngleEast = 90;
options.labels = {'North (360°)','South (180°)','East (90°)','West (270°)'};
options.TitleString = [];

clf
ax = subplot(131);
options.axes = ax;
[figure_handle,count,speeds,directions,Table] = WindRose(O.wnddir,O.wndspd_obs,options);
title('Obs')

ax = subplot(132);
options.axes = ax;
[figure_handle,count,speeds,directions,Table] = WindRose(N.wnddir,N.wndspd_10m,options);
title('NNRP')

ax = subplot(133);
options.axes = ax;
[figure_handle,count,speeds,directions,Table] = WindRose(H.wnddir,H.wndspd_10m,options);
title('HRDPS')

%% Print Max winds observed/predicted

fprintf('Obs Max Wind Speed %4.2f m/s \n',(max(O.wndspd_obs)))
fprintf('NNRP Max Wind Speed %4.2f m/s \n',(max(N.wndspd_10m)))
fprintf('HRDPS Max Wind Speed %4.2f m/s \n',(max(H.wndspd_10m(:,3))))


%% Find yearly maxima
yr = year(O.time(1)):year(O.time(end));
Omax = zeros(1,length(yr));
Omax_hourly = zeros(1,length(yr));
for yy = 1:length(yr)
    Omax(yy) = max(O.wndspd_obs(year(O.time)==yr(yy)));
    Omax_hourly(yy) = max(O.wndspd_hourly(year(O.time)==yr(yy)));
end

yr = year(N.time(1)):year(N.time(end));
Nmax = zeros(1,length(yr));
for yy = 1:length(yr)
    Nmax(yy) = max(N.wndspd_10m(year(N.time)==yr(yy)));
end

%%
clf

%--------------Observations------------------
subplot(221)
x = Omax;
nblocks = length(Omax);
x_min = 0;
x_max = 30;
x_bin = 0.1;
hist_bin = 0.5;

% location parameter µ, scale parameter ?, and shape parameter k 
paramEsts = gevfit(x);
xgrid = 0:x_bin:30;
histgrid = x_min:hist_bin:x_max;
pdf = gevpdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3));
O.cdf = 1-cumsum(pdf)*x_bin;

myhist = histc(x,histgrid);
myhist = myhist/sum(myhist*hist_bin);
myhist_hourly = histc(Omax_hourly,histgrid);
myhist_hourly = myhist_hourly/sum(myhist_hourly*hist_bin);
hold on
bar(histgrid,myhist_hourly,'FaceColor',[1 .8 .8])
bar(histgrid,myhist,'FaceColor',[.8 .8 1])

line(xgrid,pdf);
 
ax = gca;
ax.XLim = [15 28];

tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f',paramEsts(1),paramEsts(2),paramEsts(3));
text(ax.XLim(1)*1.01,ax.YLim(2)*.9,tbox)

xlabel('Max Yearly 6-hourly Wind Speed Obs[m/s]')
ylabel('Probability')


%--------------NNRP------------------
subplot(223)
x = Nmax;
nblocks = length(Nmax);
x_min = min(x);
x_max = max(x);
x_bin = 0.1;
hist_bin = 0.5;

% location parameter µ, scale parameter ?, and shape parameter k 
paramEsts = gevfit(x);
xgrid = 0:x_bin:30;
histgrid = x_min:hist_bin:x_max;
pdf = gevpdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3));
N.cdf = 1-cumsum(pdf)*x_bin;

myhist = histc(x,histgrid);
myhist = myhist/sum(myhist*hist_bin);
bar(histgrid,myhist,'FaceColor',[.8 .8 1])
hold on
line(xgrid,pdf);
 
ax = gca;
ax.XLim = [15 28];

tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f',paramEsts(1),paramEsts(2),paramEsts(3));
text(ax.XLim(1)*1.01,ax.YLim(2)*.9,tbox)

xlabel('Max Yearly 6-hourly Wind Speed Pred [m/s]')
ylabel('Probability')


% CDF and Return Invtervals
subplot(2,2,[2 4])
hold on
N.recur = 1./N.cdf;
O.recur = 1./O.cdf;
plot(xgrid,O.recur)
plot(xgrid,N.recur)
xlim([17 25])
ylim([0 100])
ylabel('Reoccurence Interval [years]')
xlabel('Max 6-hour Yearly wind Speed [m/s]')
grid on
box on
legend('Obs','Pred','Location','NorthWest')


printFig(gcf,sprintf('YearlyMaxima_%s',Station.shortName{sta_num}),[11 8.5],'pdf')