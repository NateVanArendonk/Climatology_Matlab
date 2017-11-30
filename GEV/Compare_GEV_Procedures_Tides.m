%% Rth largest GEV
clearvars

%first load in the data
dir_nm = '../../COOPS_tides/';
%dir_nm = '../../hourly_data/gap_hourly/Station_Choice/';
station_name = 'Seattle';
station_nm = 'seattle';

load_file = strcat(dir_nm,station_nm,'/',station_nm,'_hrV');
load(load_file)
clear dir_nm file_nm load_file
%% Grab maxima from data
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

% rth values to collect (can vary)
block_num = 10;
r_val = 3;

% Min distance between events (half hour incr) 
min_sep = 12;

% Preallocate
data = zeros(length(yr),block_num);

% Find rth number of max events per year
for yy=1:length(yr)
    wl_inds = year(tides.time) == yr(yy);
    val_ind = tides.WL_VALUE(wl_inds);
    for r=1:block_num
        [data(yy,r), I] = max(val_ind);
        pop_inds = max([1 I-min_sep]):min([length(val_ind) I+min_sep]);
        val_ind(pop_inds) = [];
    end
end
%% Get GEV statistics about the data

% Create a single vector of data
maxima_vec = data(:,1:r_val); maxima_vec = maxima_vec(:);

% Grab GEV parameters
[paramEstsblock, paramCIs] = gevfit(data(:,1));
[paramEstsvit, paramCIs] = gevfit(maxima_vec);
[paramEstsrth] = gevfit_rth(data(:,1:r_val));

%----------------Results from GEV-------------------------------
% % % kMLE = paramEsts(1);        % Shape parameter
% % % sigmaMLE = paramEsts(2);    % Scale parameter
% % % muMLE = paramEsts(3);       % Location parameter
%% Plot Hist with GEV fits
lowerBnd = 2.5;
x = maxima_vec;
xmax = 1.1*max(x)+ten_mean;
bins = lowerBnd:.1:ceil(xmax); 

% Plot histograms for the data 
clf
figure(1)
% Plot Rth distribution
h1 = bar(bins,histc(x+ten_mean,bins)/length(x),'histc');
h1.FaceColor = [.8 .8 .8];

hold on
% Plot block data distribution
h2 = bar(bins,histc(data(:,1)+ten_mean,bins)/length(data),'histc');
h2.FaceColor = [.8 .8 1];
set(h2,'FaceAlpha',.3);

% Add the Line for the estimates of the GEV Fit
xgrid = linspace(lowerBnd,xmax,100);
lb = line(xgrid,.1*gevpdf(xgrid,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3)+ten_mean));
lr = line(xgrid,.1*gevpdf(xgrid,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3)+ten_mean));
lv = line(xgrid,.1*gevpdf(xgrid,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3)+ten_mean));
lb.Color = 'red';
lr.Color = 'blue';
lv.Color = 'green';

% Add a legend to the plot
legend([lb lr lv h1 h2],'Block','Rth','Hybrid','Rth','Block');

% Add A title
plot_tit = sprintf('GEV Comparison - %s', station_name);
title(plot_tit)

% Limit Axes 
ax = gca;   
ax.XLim = [2.8 4];

% Add GEV parameters to the plot
% Block data
tbox = sprintf('\t\t\t\t\t\tBlock\nmu = %4.2f \nsigma = %4.2f \nk = %4.2f \nr: %d',...
    paramEstsblock(1),paramEstsblock(2),paramEstsblock(3), 1);
dim = [.18 .6 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');
% Rth Largest
tbox2 = sprintf('\t\t\t\t\t\tRth\nmu = %4.2f \nsigma = %4.2f \nk = %4.2f \nr: %d',...
    paramEstsrth(1),paramEstsrth(2),paramEstsrth(3), r_val);
dim = [.18 .4 .3 .3];
annotation('textbox',dim,'String',tbox2,'FitBoxToText','on');
% Vitousik/Hybrid
tbox3 = sprintf('\t\t\t\t\t\tHybrid\nmu = %4.2f \nsigma = %4.2f \nk = %4.2f \nr: %d',...
    paramEstsvit(1),paramEstsvit(2),paramEstsvit(3), r_val);
dim = [.18 .2 .3 .3];
annotation('textbox',dim,'String',tbox3,'FitBoxToText','on');

% Label Axes
xlabel('Total Water Level [m]')
ylabel('Probability Distribution')
box on


%% Save the plot 
cd('../../');
outname = sprintf('GEV_compareMethods_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%cd('../../../matlab/Climatology')
cd('matlab/Climatology')

%% Calculate Recurrence Interval


cdfblock = 1 - gevcdf(xgrid,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3)+ten_mean); % create CDF from GEV PDF
cdfrth = 1 - gevcdf(xgrid,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3)+ten_mean); % create CDF from GEV PDF      
cdfvit = 1 - gevcdf(xgrid,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3)+ten_mean); % create CDF from GEV PDF  
%-------Note-----------%
%RI = 1/Probability
%Knowing CDF and thus the probability, I can calculate the Recurrence
figure(2)
RIblock = 1./cdfblock;
RIrth = 1./cdfrth;
RIvit = 1./cdfvit;
%subplot(2,2,[2 4])
rcb = line(xgrid, RIblock);
rcb.Color = 'red';
rcr = line(xgrid, RIrth);
rcr.Color = 'blue';
rcv = line(xgrid, RIvit);
rcv.Color = 'green';



ylim([0 100])
xlim([3.1 4.0])
% Add Labels
plot_tit = sprintf('Recurrence Interval Comparison - %s', station_name);
title(plot_tit)
xlabel('Total Water Level [m]')
ylabel('Time [years]')

% Add minor tick marks on x-axis
ax = gca;
set(gca,'XMinorTick','on') 

box on 
grid on
legend([rcb,rcr,rcv],'Block','Rth','Hybrid')


% Generate RI Estimates
% Block
R100MLEblock = gevinv(1-1./100,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3)+ten_mean);
R50MLEblock = gevinv(1-1./50,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3)+ten_mean);
R25MLEblock = gevinv(1-1./25,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3)+ten_mean);
R10MLEblock = gevinv(1-1./10,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3)+ten_mean);
R5MLEblock = gevinv(1-1./5,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3)+ten_mean);
R2MLEblock = gevinv(1-1./2,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3)+ten_mean);
% Rth
R100MLErth = gevinv(1-1./100,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3)+ten_mean);
R50MLErth = gevinv(1-1./50,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3)+ten_mean);
R25MLErth = gevinv(1-1./25,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3)+ten_mean);
R10MLErth = gevinv(1-1./10,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3)+ten_mean);
R5MLErth = gevinv(1-1./5,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3)+ten_mean);
R2MLErth = gevinv(1-1./2,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3)+ten_mean);
% Vit/Hybrid
R100MLEvit = gevinv(1-1./100,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3)+ten_mean);
R50MLEvit = gevinv(1-1./50,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3)+ten_mean);
R25MLEvit = gevinv(1-1./25,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3)+ten_mean);
R10MLEvit = gevinv(1-1./10,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3)+ten_mean);
R5MLEvit = gevinv(1-1./5,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3)+ten_mean);
R2MLEvit = gevinv(1-1./2,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3)+ten_mean);

% Add GEV parameters to the plot
tboxb = sprintf('\t\t\t\t\t\t\tBlock\n 100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLEblock, R50MLEblock, R25MLEblock, R10MLEblock, R5MLEblock, R2MLEblock);
dim = [.4 .54 .3 .3];
annotation('textbox',dim,'String',tboxb,'FitBoxToText','on');

tboxr = sprintf('\t\t\t\t\t\tRth\n 100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLErth, R50MLErth, R25MLErth, R10MLErth, R5MLErth, R2MLErth);
dim = [.2 .54 .3 .3];
annotation('textbox',dim,'String',tboxr,'FitBoxToText','on');

tboxv = sprintf('\t\t\t\t\t\t\tHybrid\n 100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLEvit, R50MLEvit, R25MLEvit, R10MLEvit, R5MLEvit, R2MLEvit);
dim = [.3 .25 .3 .3];
annotation('textbox',dim,'String',tboxv,'FitBoxToText','on');

%% Save the plot
cd('../../');
outname = sprintf('RI_compareMethods_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%cd('../../../matlab/Climatology')
cd('matlab/Climatology')
