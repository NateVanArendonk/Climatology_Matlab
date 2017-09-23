%% GEV Fit for Block Maxima

clearvars

%first load in the data
%dir_nm = '../../hourly_data/';
dir_nm = '../../COOPS_tides/';
station_name = 'Seattle';
station_nm = 'Seattle';

%load_file = strcat(dir_nm,station_nm,'/',station_nm,'_6minV');
load_file = strcat(dir_nm,station_nm,'/',station_nm,'_hrV');
load(load_file)
clear dir_nm file_nm load_file


%% Find yearly max
% Years available
yr = year(tides.time(1)):year(tides.time(end));

% rth values to collect (can use less later)
r_num = 10;
r_val = 3;

% Min distance between events (half hour incr) 24 if half our, 12 if hour
min_sep = 12;

% Calculate the mean over the past 10 years and add it to the GEV param mu
tinds = find(year(tides.time) == yr(end) - 10);
inds = tinds(1):length(tides.WL_VALUE);
ten_mean = mean(tides.WL_VALUE(inds));

% Detrend SLR 
tides.WL_VALUE = detrend(tides.WL_VALUE);

% Preallocate
maxima = zeros(length(yr),r_num);

% Loop
for yy=1:length(yr)
    inds = year(tides.time) == yr(yy);
    temp = tides.WL_VALUE(inds);
    for r=1:r_num
        [maxima(yy,r), I] = max(temp);
        pop_inds = max([1 I-min_sep]):min([length(temp) I+min_sep]);
        temp(pop_inds) = [];
    end
end
%%
% Get GEV statistics about the data
[parmhat] = gevfit_rth(maxima(:,1:r_val));

%maxima = maxima(:,1:r_val);
%[parmhat, paramCIs] = gevfit(maxima(:));
%----------------Results from GEV-------------------------------
% % % kMLE = paramEsts(1);        % Shape parameter
% % % sigmaMLE = paramEsts(2);    % Scale parameter
% % % muMLE = paramEsts(3);       % Location parameter
%% fit the GEV
xlim = [2.8 4];

clf
% Add PDF
pdf_data = histogram(maxima(:,1:r_val)+ten_mean,8,'Normalization','pdf');
hold on
% GEV pdf - Fit line to PDF
xgrid = linspace(xlim(1),xlim(2),100);
pdf_gev = gevpdf(xgrid,parmhat(1),parmhat(2),parmhat(3)+ten_mean); 

% Plot line
plot(xgrid,pdf_gev)
% Limit x axis 
ax = gca;
ax.XLim = [3 4];


plot_tit = sprintf('GEV - Rth - %s', station_name);
title(plot_tit)
% Add GEV parameters to the plot
tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f \nn: %d \nr: %d',...
    parmhat(1),parmhat(2),parmhat(3), length(maxima), r_val);
%text(10,0.25, tbox)

% Add box around the text
dim = [.17 .6 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');

ax = gca;
%ax.XLim = ([2.4 4]);
set(gca,'XMinorTick','on')



xlabel('Total Water Level [m]')
ylabel('Probability Density')
%legend('Hourly','Six-Hr Avg.','Location','NorthEast')
box on

% Calculate the CDF - CDF will give me the probability of values 
cdf = gevcdf(xgrid,parmhat(1),parmhat(2),parmhat(3)+ten_mean); % create CDF from GEV PDF
cdf2 = 1 - gevcdf(xgrid,parmhat(1),parmhat(2),parmhat(3)+ten_mean); 
%% Recurrence Interval

clf
% Add SLR
grid1 = xgrid + .3048; grid2 = xgrid + .6096;

% Calculate RI
RI = 1./cdf2;

set(gca, 'YScale', 'log')
% Plot 1 foot of SLR
z(1)=line(grid1, RI, 'LineWidth', 2);
z(1).Color = 'red';

% Plot 2 feet of SLR
hold on
z(2)=line(grid2, RI, 'LineWidth', 2);
z(2).Color = 'green';

% Plot current TWL
z(3)=line(xgrid, RI, 'LineWidth', 2);
z(3).Color = 'blue';

% Set Plot Limits
plot_tit = sprintf('Recurrence Interval [m] - %s', station_name);
%title(plot_tit)
xlabel('Total Water Level [m]')
ylabel('Time [years]')

% Add minor tick marks on x-axis and Relabel Ticks on Y-axis
ax = gca;
set(gca,'XMinorTick','on','YTickLabel',{'1-year','10-year','100-year'})  
ax.YLim = [1 100];
ax.XLim = [2.9 4.6];

% Add grid lines
box on; grid on


% Generate specific values for recurrence levels
R100MLE = gevinv(1-1./100,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
R50MLE = gevinv(1-1./50,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
R25MLE = gevinv(1-1./25,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
R10MLE = gevinv(1-1./10,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
R5MLE = gevinv(1-1./5,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
R2MLE = gevinv(1-1./2,parmhat(1),parmhat(2),parmhat(3)+ten_mean);

% Add GEV parameters to the plot
%tbox = sprintf('100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
%    ,R100MLE, R50MLE, R25MLE, R10MLE, R5MLE, R2MLE);
%dim = [.2 .35 .3 .3];
%annotation('textbox',dim,'String',tbox,'FitBoxToText','on');


% Find the location on the 1' SLR curve of 10 and 100 year levels
loc1 = findnearest(R10MLE, grid1);
loc2 = findnearest(R100MLE, grid1);

% Add Lines to plot for 10 and 100 year levels
% 10 year
hx1 = linspace(0,R10MLE,length(RI)); hy1 = ones(1,length(hx1))*RI(loc1);
a1 = line(hx1,hy1); a1.Color = 'black';

vy1 = linspace(RI(loc1),100,length(RI)); vx1 = ones(1,length(vy1))*R10MLE;
a2 = line(vx1,vy1); a2.Color = 'black';


% 100 year
hx1 = linspace(0,R100MLE,length(RI)); hy1 = ones(1,length(hx1))*RI(loc2);
b1 = line(hx1,hy1); b1.Color = 'black';

vy2 = linspace(RI(loc2),100,length(RI)); vx2 = ones(1,length(vy2))*R100MLE;
b2 = line(vx2,vy2); b2.Color = 'black';

% Add a legend to the plot
lgd = legend([z(2) z(1) z(3)],'2ft SLR', '1ft SLR', 'Current WL');
lgd.Position = [.21 .845 .05 .05];

% Add text to figure showing recurrence interval change
nx = 2.95;
ny = RI(loc1);
ny = 1.18;
txt1 = sprintf('%4.2f years', RI(loc1));
t1 = text(nx,ny,txt1);
t1.FontSize = 14;


mx = 3.18;
my = RI(loc2);
my = 1.73;
txt2 = sprintf('%4.2f years', RI(loc2));
t2 = text(mx,my,txt2);
t2.FontSize = 14;
%%
% Save the Plot
cd('../../')

outname = sprintf('Prob_exceed_change_Rth%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

cd('matlab/Climatology')
