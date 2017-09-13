%% GEV Fit for Block Maxima

clearvars

%first load in the data
%dir_nm = '../../hourly_data/';
dir_nm = '../../COOPS_tides/';
station_name = 'Seattle';
station_nm = 'seattle';

load_file = strcat(dir_nm,station_nm,'/',station_nm,'_hrV');
load(load_file)
clear dir_nm file_nm load_file



%% Collect maxima

% Years available
yr = year(tides.time(1)):year(tides.time(end));
% Calculate the mean over the past 10 years and add it to the GEV param mu
tinds = find(year(tides.time) == yr(end) - 10);
inds = tinds(1):length(tides.WL_VALUE);
ten_mean = mean(tides.WL_VALUE(inds));


tides.WL_VALUE = detrend(tides.WL_VALUE);

% rth values to collect (can use less later)
r_num = 10;
r_val = 3;

% Min distance between events (half hour incr) 24 if half our, 12 if hour
min_sep = 12;

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

% maxima = maxima(:,1:r_val);
% [parmhat, paramCIs] = gevfit(maxima(:));
%----------------Results from GEV-------------------------------
% % % kMLE = paramEsts(1);        % Shape parameter
% % % sigmaMLE = paramEsts(2);    % Scale parameter
% % % muMLE = paramEsts(3);       % Location parameter
%% Plot the GEV

xlim = [(min(maxima(:))) (1.1*max(maxima(:)))];

clf
subplot(2,2,[1 3])
pdf_data = histogram(maxima(:,1:r_val)+ten_mean,8,'Normalization','pdf');
mycolors = jet(10);
hold on

% GEV pdf 
xgrid = linspace(xlim(1),xlim(2),100);
pdf_gev = gevpdf(xgrid,parmhat(1),parmhat(2),parmhat(3)+ten_mean); 
plot(xgrid,pdf_gev,'Color',mycolors(1,:))


plot_tit = sprintf('GEV - Rth - %s', station_name);
title(plot_tit)
% Add GEV parameters to the plot
tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f \nn: %d \nr: %d',...
    parmhat(1),parmhat(2),parmhat(3), length(maxima), r_val);
%text(10,0.25, tbox)

% Add box around the text
dim = [.143 .6 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');

ax = gca;
ax.XLim = ([2.4 4]);
set(gca,'XMinorTick','on')



xlabel('Total Water Level [m]')
ylabel('Probability Density')
%legend('Hourly','Six-Hr Avg.','Location','NorthEast')
box on

% Calculate the CDF - CDF will give me the probability of values 
cdf = 1 - gevcdf(xgrid,parmhat(1),parmhat(2),parmhat(3)+ten_mean); % create CDF from GEV PDF


%% Old way
% % % 
% % % 
% % % lowerBnd = 2;
% % % x = maxima;  
% % % xmax = 1.1*max(x);
% % % bins = floor(lowerBnd):.1:ceil(xmax);
% % % 
% % % % plot the hist with GEV line
% % % subplot(2,2,[1 3])
% % % h = bar(bins,histc(x,bins)/length(x),'histc');
% % % h.FaceColor = [.8 .8 .8];
% % % xgrid = linspace(lowerBnd,xmax,100);
% % % line(xgrid,.1*gevpdf(xgrid,parmhat(1),parmhat(2),parmhat(3)));
% % % xlim([lowerBnd xmax]);
% % % plot_tit = sprintf('GEV - Block Maxima - %s', station_name);
% % % title(plot_tit)
% % % 
% % % ax = gca;  % Play with the Axes 
% % % ax.XLim = [2 xmax];
% % % 
% % % 
% % % % Add GEV parameters to the plot
% % % tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f \nn: %d',...
% % %     parmhat(1),parmhat(2),parmhat(3), length(maxima));
% % % %text(10,0.25, tbox)
% % % 
% % % % Add box around the text
% % % dim = [.16 .5 .3 .3];
% % % annotation('textbox',dim,'String',tbox,'FitBoxToText','on');
% % % 
% % % 
% % % 
% % % xlabel('Total Water Level [m]')
% % % ylabel('Probability Density')
% % % %legend('Hourly','Six-Hr Avg.','Location','NorthEast')
% % % box on
% % % 
% % % % Calculate the CDF - CDF will give me the probability of values 
% % % cdf = 1 - gevcdf(xgrid,parmhat(1),parmhat(2),parmhat(3)); % create CDF from GEV PDF
% % % 
% % % 
% % % % ----------Notes-----------
% % % % - PDF sums to 1, represents probability density
% % % % - CDF is the cumulative PDF, represents probability
% % % % - CDF is the probability of the random variable being less than X

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
xlabel('Total Water Level [m]')
ylabel('Time [years]')


ax = gca;
ax.XLim = ([3 3.8]);
set(gca,'XMinorTick','on')  %add minor tick marks on x-axis

box on 
grid on


% Generate specific values for recurrence levels

R100MLE = gevinv(1-1./100,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
R50MLE = gevinv(1-1./50,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
R25MLE = gevinv(1-1./25,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
R10MLE = gevinv(1-1./10,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
R5MLE = gevinv(1-1./5,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
R2MLE = gevinv(1-1./2,parmhat(1),parmhat(2),parmhat(3)+ten_mean);

% Add GEV parameters to the plot
tbox = sprintf('100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLE, R50MLE, R25MLE, R10MLE, R5MLE, R2MLE);
%text(6,60, tbox)

dim = [.62 .3 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');






%%
% Save the Plot
cd('../../')

outname = sprintf('GEV_%s_Rth',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

cd('matlab/Climatology')
