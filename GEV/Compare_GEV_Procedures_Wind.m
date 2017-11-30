%% Compare GEV procedures for Wind Data
clearvars

%first load in the data
%dir_nm = '../../hourly_data/';
dir_nm = '../../hourly_data/gap_hourly/Station_Choice/';
station_name = 'Whidbey';
station_nm = 'whidbey_nas';

load_file = strcat(dir_nm,station_nm,'_hourly');
load(load_file)
clear dir_nm file_nm load_file
%% Grab data from data

% Years available
yr = year(time(1)):year(time(end));

% rth values to collect 
block_num = 10;
r_val = 3;

% Min distance between events (half hour incr) 
min_sep = 6;

% Preallocate
data = zeros(length(yr),block_num);

% Find rth number of max events per year
for yy=1:length(yr)
    t_inds = year(time) == yr(yy);
    val_ind = wndspd(t_inds);
    for r=1:block_num
        [data(yy,r), I] = max(val_ind);
        pop_inds = max([1 I-min_sep]):min([length(val_ind) I+min_sep]);
        val_ind(pop_inds) = [];
    end
end
%% Get GEV statistics about the data

% Create a single vector of data
maxima_vec = data(:,1:r_val); maxima_vec = maxima_vec(:);

% Fit GEV to data
[paramEstsblock, paramCIs] = gevfit(data(:,1));
[paramEstsvit, paramCIs] = gevfit(data(:));
[paramEstsrth] = gevfit_rth(data(:,1:r_val));

%----------------Results from GEV-----------------
% kMLE = paramEsts(1);        % Shape parameter
% sigmaMLE = paramEsts(2);    % Scale parameter
% muMLE = paramEsts(3);       % Location parameter
%% Plot Hist with GEV fits

% Values used for plotting of Histograms
lowerBnd = 10;
x = maxima_vec;
xmax = 1.1*max(x);
bins = lowerBnd:ceil(xmax); 

% Plot histograms for the data 
clf
h1 = bar(bins,histc(x,bins)/length(x),'histc');
h1.FaceColor = [.8 .8 .8];
hold on
h2 = bar(bins,histc(data(:,1),bins)/length(data),'histc');
h2.FaceColor = [.8 .8 1];

% Add the Line for the estimates of the GEV Fit
xgrid = linspace(lowerBnd,xmax,100);
lb = line(xgrid,gevpdf(xgrid,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3)));
lr = line(xgrid,gevpdf(xgrid,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3)));
lv = line(xgrid,gevpdf(xgrid,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3)));
lb.Color = 'red';
lr.Color = 'blue';
lv.Color = 'green';

% Add a legend to the plot
legend([lb lr lv h1 h2],'Block','Rth','Vit','Rth','Block');

% Add A title
plot_tit = sprintf('GEV Comparison - %s', station_name);
title(plot_tit)

% Limit Axes 
ax = gca;   
ax.XLim = [10 xmax];

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
tbox3 = sprintf('\t\t\t\t\t\tVit\nmu = %4.2f \nsigma = %4.2f \nk = %4.2f \nr: %d',...
    paramEstsvit(1),paramEstsvit(2),paramEstsvit(3), r_val);
dim = [.18 .2 .3 .3];
annotation('textbox',dim,'String',tbox3,'FitBoxToText','on');

% Label Axes
xlabel('Wind Speed [m/s]')
ylabel('Probability Density')
box on

%% Calculate Recurrence Interval

clf
cdfblock = 1 - gevcdf(xgrid,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3)); % create CDF from GEV PDF
cdfrth = 1 - gevcdf(xgrid,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3)); % create CDF from GEV PDF      
cdfvit = 1 - gevcdf(xgrid,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3)); % create CDF from GEV PDF  
%-------Note-----------%
%RI = 1/Probability
%Knowing CDF and thus the probability, I can calculate the Recurrence

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
xlim([14 26])
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
legend([rcb,rcr,rcv],'Block','Rth','Vit')


% Generate RI Estimates
% Block
R100MLEblock = gevinv(1-1./100,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3));
R50MLEblock = gevinv(1-1./50,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3));
R25MLEblock = gevinv(1-1./25,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3));
R10MLEblock = gevinv(1-1./10,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3));
R5MLEblock = gevinv(1-1./5,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3));
R2MLEblock = gevinv(1-1./2,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3));
% Rth
R100MLErth = gevinv(1-1./100,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3));
R50MLErth = gevinv(1-1./50,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3));
R25MLErth = gevinv(1-1./25,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3));
R10MLErth = gevinv(1-1./10,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3));
R5MLErth = gevinv(1-1./5,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3));
R2MLErth = gevinv(1-1./2,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3));
% Vit/Hybrid
R100MLEvit = gevinv(1-1./100,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3));
R50MLEvit = gevinv(1-1./50,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3));
R25MLEvit = gevinv(1-1./25,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3));
R10MLEvit = gevinv(1-1./10,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3));
R5MLEvit = gevinv(1-1./5,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3));
R2MLEvit = gevinv(1-1./2,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3));

% Add GEV parameters to the plot
tboxb = sprintf('\t\t\t\t\t\t\tBlock\n 100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLEblock, R50MLEblock, R25MLEblock, R10MLEblock, R5MLEblock, R2MLEblock);
dim = [.4 .54 .3 .3];
annotation('textbox',dim,'String',tboxb,'FitBoxToText','on');

tboxr = sprintf('\t\t\t\t\t\t\tRth\n 100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLErth, R50MLErth, R25MLErth, R10MLErth, R5MLErth, R2MLErth);
dim = [.2 .5 .3 .3];
annotation('textbox',dim,'String',tboxr,'FitBoxToText','on');

tboxv = sprintf('\t\t\t\t\t\t\tVit\n 100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLEvit, R50MLEvit, R25MLEvit, R10MLEvit, R5MLEvit, R2MLEvit);
dim = [.3 .25 .3 .3];
annotation('textbox',dim,'String',tboxv,'FitBoxToText','on');


%%
% Save the Plot
%cd('../../Matlab_Figures/GEV/Tides/Rth/')
%cd('../../swin/GEV/10_block/')
cd('../../');
outname = sprintf('GEVrof3_%s_1898_17',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%cd('../../../matlab/Climatology')
cd('matlab/Climatology')


