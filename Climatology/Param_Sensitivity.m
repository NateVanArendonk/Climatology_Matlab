%% Parameter sensitivity analysis for GEV parameters
clearvars

%first load in the data
dir_nm = '../../COOPS_tides/';
%dir_nm = '../../hourly_data/gap_hourly/Station_Choice/';
station_name = 'Seattle';
station_nm = 'seattle';

load_file = strcat(dir_nm,station_nm,'/',station_nm,'_hrV');
load(load_file)
clear dir_nm file_nm load_file

%% Collect maxima

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
    temp = tides.WL_VALUE(inds);
    for r=1:r_num
        [maxima(yy,r), I] = max(temp);
        pop_inds = max([1 I-min_sep]):min([length(temp) I+min_sep]);
        temp(pop_inds) = [];
    end
end

% Create variable with water level back to datum
data_datum = maxima + ten_mean;


%% Estimate the GEV paramters and preliminary plot of fit

% limits
xlim = [(min(maxima(:))+ten_mean) (1.1*max(maxima(:))+ten_mean)];

% Plot histogram of maximum data 
clf
figure(1)
subplot(2,2,1)
pdf_data = histogram(maxima(:,1:3)+ten_mean,8,'Normalization','pdf');
hold on

mycolors = jet(10);

% Get GEV parameters from distribution
parmhat = gevfit_rth(maxima(:,1:3)); % for r = 3

% Seattle SE estimates from R for r = 1:10 respectively 
parmCI1k = 0.052853561; parmCI1sig = 0.008332192; parmCI1mu = 0.012107234;
parmCI2k = 0.035790486; parmCI2sig = 0.005087182; parmCI2mu = 0.009950179;
parmCI3k = 0.027626061; parmCI3sig = 0.003790572; parmCI3mu = 0.008569755;
parmCI4k = 0.024745905; parmCI4sig = 0.003361619; parmCI4mu = 0.008046526; 
parmCI5k = 0.022052276; parmCI5sig = 0.003066568; parmCI5mu = 0.007655433;
parmCI6k = 0.021402956; parmCI6sig = 0.003030071; parmCI6mu = 0.007282214;
parmCI7k = 0.019711360; parmCI7sig = 0.002892105; parmCI7mu = 0.006997288;
parmCI8k = 0.019039934; parmCI8sig = 0.002866830; parmCI8mu = 0.006825072;
parmCI9k = 0.018517831; parmCI9sig = 0.002872376; parmCI9mu = 0.006666725;
parmCI10k = 0.017841100; parmCI10sig = 0.002857912; parmCI10mu = 0.006529347;

% Set up x axis
x_axis = linspace(xlim(1),xlim(2),100);

% Set up line of gev fit to data
parmhat = gevfit_rth(maxima(:,1)); % for r = 3
pdf_gev1 = gevpdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+ten_mean);

% Plot the line on the PDF
plot(x_axis,pdf_gev1,'Color',mycolors(1,:));
hold on 

% plot a line with r = 3
parmhat = gevfit_rth(maxima(:,1:3)); % for r = 3 'block maxima' 1 value estimate
pdf_gev3 = gevpdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
plot(x_axis,pdf_gev3,'Color',mycolors(3,:));
hold on 

% plot a line with r = 5
parmhat = gevfit_rth(maxima(:,1:5)); % for r = 5 1 value estimate
pdf_gev5 = gevpdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
plot(x_axis,pdf_gev5,'Color',mycolors(5,:));
hold on 

% plot a line with r = 10
parmhat = gevfit_rth(maxima(:,1:10)); % for r = 10 value estimate
pdf_gev10 = gevpdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+ten_mean);
plot(x_axis,pdf_gev10,'Color',mycolors(10,:));

% Add labels and establish limits
ylabel('Probability Distribution')
xlabel('Maximum yearly TWL [m]')
plot_tit = sprintf('%s - GEV Fit [rth largest]',station_name);
title(plot_tit)
ax = gca;
ax.XLim = [xlim(1) xlim(2)-.2];
legend('r=3','r=1','r=3','r=5','r=10','Location','northwest');


% go back to r = 3 for rth largest gev_estimates for plots below 
parmhat = gevfit_rth(maxima(:,1:3));




%% Change parameters using confidence intervals (95% CI from Matlab)

%----------------Results from GEV----------------%
% kMLE = paramhat(1);       % Shape parameter
% sigmaMLE = paramhat(2);   % Scale parameter
% muMLE = paramhat(3);      % Location parameter


% First play around with k - paramhat(1)
subplot(2,2,2)
pdf_data = histogram(maxima(:,1:3)+ten_mean,8,'Normalization','pdf');
hold on
% limits
ax = gca;
ax.XLim = [xlim(1) xlim(2)-.2];

kvec = linspace(parmhat(1) - parmCI1k, parmhat(1) + parmCI1k,10);
%kvec = linspace(parmCI(1,1),parmCI(2,1),10);

for k = 1:length(kvec)
% GEV pdf 
x_axis = linspace(xlim(1),xlim(2),100);
pdf_gev = gevpdf(x_axis,kvec(k),parmhat(2),parmhat(3)+ten_mean); 
plot(x_axis,pdf_gev,'Color',mycolors(k,:))
end
kvec = num2str(kvec,'%4.2f\n');
chan = colorbar;
colormap(mycolors)
kinc = diff(kvec);
%legend('r=1','r=10')

chan.YTick = .05:.1:.95;
chan.YTickLabel = kvec;
ylabel(chan,'k-value')
ylabel('Probability Distribution')
xlabel('Maximum yearly TWL [m]')
plot_tit = sprintf('%s - Varying K',station_name);
title(plot_tit)
%legend('r=3','Location','northwest')
%% Now for sigmahat - paramhat(2)
subplot(2,2,3)
pdf_data = histogram(maxima(:,1:3)+ten_mean,8,'Normalization','pdf');
hold on
% limits
ax = gca;
ax.XLim = [xlim(1) xlim(2)-.2];

% Create vector for sigma
sigvec = linspace(parmhat(2) - parmCI1sig, parmhat(2) + parmCI1sig,10);
%sigvec = linspace(parmCI(1,2),parmCI(2,2),10);

for s = 1:length(sigvec)
% GEV pdf 
x_axis = linspace(xlim(1),xlim(2),100);
pdf_gev = gevpdf(x_axis,parmhat(1),sigvec(s),parmhat(3)+ten_mean); 
plot(x_axis,pdf_gev,'Color',mycolors(s,:))
end
sigvec = num2str(sigvec,'%4.2f\n');
chan = colorbar;
colormap(mycolors)
sinc = diff(sigvec);
%legend('r=1','r=10')

chan.YTick = .05:.1:.95;
chan.YTickLabel = sigvec;
ylabel(chan,'sigma-value')
ylabel('Probability Distribution')
xlabel('Maximum yearly TWL [m]')
plot_tit = sprintf('%s - Varying Sigma',station_name);
title(plot_tit)
%legend('r=3','Location','northwest')

%% Now for muhat - paramhat(3)
subplot(2,2,4)
pdf_data = histogram(maxima(:,1:3)+ten_mean,8,'Normalization','pdf');
hold on
% limits
ax = gca;
ax.XLim = [xlim(1) xlim(2)-.2];

% Create vector for sigma
muvec = linspace(parmhat(3) - parmCI1mu, parmhat(3) + parmCI1mu,10);
%muvec = linspace(parmCI(1,3),parmCI(2,3),10);

for m = 1:length(muvec)
% GEV pdf 
x_axis = linspace(xlim(1),xlim(2),100);
pdf_gev = gevpdf(x_axis,parmhat(1),parmhat(2),muvec(m)+ten_mean); 
plot(x_axis,pdf_gev,'Color',mycolors(m,:))
end
muvec = num2str(muvec,'%4.2f\n');
chan = colorbar;
colormap(mycolors)
minc = diff(muvec);
%legend('r=1','r=10')

chan.YTick = .05:.1:.95;
chan.YTickLabel = muvec;
ylabel(chan,'mu-value')
ylabel('Probability Distribution')
xlabel('Maximum yearly TWL [m]')
plot_tit = sprintf('%s - Varying Mu',station_name);
title(plot_tit)
%legend('r=3','Location','northwest')

%% Save Plot 

cd('../../');
outname = sprintf('Rvalue_sensitivity_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%cd('../../../matlab/Climatology')
cd('matlab/Climatology')


%% Plot CDF
figure(2)
cdf_data = sort(data_datum(:,1),'ascend');
y_data = linspace(0,1,length(cdf_data));

cdf_gev = gevcdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+ten_mean); 
figure(2)
hold on
plot(cdf_data,1-y_data,'ok')
plot(x_axis,1-cdf_gev,'b')
%plot(x_axis,1-cdf_gev_r)
xlabel('Maximum yearly TWL [m]')
ylabel('Probability of Yearly Exceedance')
grid on
ax = gca;
ax.XLim = [3 4];
legend('Observations','GEV')

%set(gca,'YScale','log')

%% Save Plot 
cd('../../');
outname = sprintf('CDF_Fit_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%cd('../../../matlab/Climatology')
cd('matlab/Climatology')



%%  Vary Parameters and Plot CI






% ---- USE MONTE CARLO SCRIPT FOR THIS ---- %




% Create cdf's for all rth values
for rth_num = 1:10
    % Grab the GEV parameters
    parmhat_rth = gevfit_rth(maxima(:,1:r_num));
    % Calculate the CDF for each value in x_axis, which is 100
    cdf_gev_r(:,rth_num) = gevcdf(x_axis,parmhat_rth(1),parmhat_rth(2),parmhat_rth(3)+ten_mean); 
end

% Create cdf's for varying block estimates using CI
res = 10;

k_var = kvec;
sig_var = sigvec;
mu_var = muvec;
% k_var = linspace(parmCI(1,1),parmCI(2,1),res);
% sig_var = linspace(parmCI(1,2),parmCI(2,2),res);
% mu_var = linspace(parmCI(1,3),parmCI(2,3),res);


count = 1;
cdf_gev_MC = zeros(length(x_axis),res^3);
for ii = 1:length(k_var)
    for jj = 1:length(sig_var)
        for kk = 1:length(mu_var)
            parmhat = gevfit_rth(maxima(:,1));
            cdf_gev_MC(:,count) = gevcdf(x_axis,k_var(ii),sig_var(jj),mu_var(kk)+ten_mean);
            count = count+1;
        end
    end
end


figure(3)
clf
subplot(2,2,1)
% First plot entire range of estimates and corresponding RI 
plot(x_axis,1./(1-cdf_gev_MC),'Color',[.7 .7 .7])
hold on
for rth_num = 1:10
    plot(x_axis,1./(1-cdf_gev_r(:,rth_num)),'Color',mycolors(rth_num,:))
end
xlabel('Maximum yearly TWL [m]')
ylabel('Recurrence Interval [years]')
grid on
set(gca,'YScale','log')
ylim([0 100])
plot_tit = sprintf('Range of Parameters - %s', station_name);
title(plot_tit)

% Now hold specific parameters steady and vary a one

% Create vectors using 95% confidence intervals
its = 10;
%k_var = linspace(parmCI(1,1),parmCI(2,1),its);
%sig_var = linspace(parmCI(1,2),parmCI(2,2),its);
%mu_var = linspace(parmCI(1,3),parmCI(2,3),its);
cdf_gev_vk = zeros(length(x_axis),its); % varying K cdf
cdf_gev_vs = zeros(length(x_axis),its); % varying sig cdf
cdf_gev_vm = zeros(length(x_axis),its); % varying mu cdf

% -------------------------------------------------------------------------
% Start with K
subplot(2,2,2)
plot(x_axis,1./(1-cdf_gev_MC),'Color',[.7 .7 .7])
hold on
count = 1;
% Generate cdf
for kk = 1:its
    cdf_gev_vk(:,count) = gevcdf(x_axis,k_var(kk),parmhat(2),parmhat(3)+ten_mean);
    count = count+1;
end
% Plot different cdfs on top of the total confidence interval
for kk = 1:its
    plot(x_axis,1./(1-cdf_gev_vk(:,kk)),'Color',mycolors(kk,:))
end

xlabel('Maximum yearly TWL [m]')
ylabel('Recurrence Interval [years]')
grid on
set(gca,'YScale','log')
ylim([0 100])
plot_tit = sprintf('%s - Varying K', station_name);
title(plot_tit)

chan = colorbar;
colormap(mycolors)
chan.YTick = .05:.1:.95;
chan.YTickLabel = k_var;
ylabel(chan,'k-value')




% -------------------------------------------------------------------------
% Now Sigma
subplot(2,2,3)
plot(x_axis,1./(1-cdf_gev_MC),'Color',[.7 .7 .7])
hold on
count = 1;
% Generate cdf
for ss = 1:its
    cdf_gev_vs(:,count) = gevcdf(x_axis,parmhat(1),sig_var(ss),parmhat(3)+ten_mean);
    count = count+1;
end
% Plot different cdfs on top of the total confidence interval
for ss = 1:its
    plot(x_axis,1./(1-cdf_gev_vs(:,ss)),'Color',mycolors(ss,:))
end

xlabel('Maximum yearly TWL [m]')
ylabel('Recurrence Interval [years]')
grid on
set(gca,'YScale','log')
ylim([0 100])
plot_tit = sprintf('%s - Varying Sigma', station_name);
title(plot_tit)

chan = colorbar;
colormap(mycolors)
chan.YTick = .05:.1:.95;
chan.YTickLabel = sig_var;
ylabel(chan,'sigma-value')


% -------------------------------------------------------------------------
% Now Mu
subplot(2,2,4)
plot(x_axis,1./(1-cdf_gev_MC),'Color',[.7 .7 .7])
hold on
count = 1;
% Generate cdf
for mm = 1:its
    cdf_gev_vm(:,count) = gevcdf(x_axis,parmhat(1),parmhat(2),mu_var(mm)+ten_mean);
    count = count+1;
end
% Plot different cdfs on top of the total confidence interval
for mm = 1:its
    plot(x_axis,1./(1-cdf_gev_vm(:,mm)),'Color',mycolors(mm,:))
end

xlabel('Maximum yearly TWL [m]')
ylabel('Recurrence Interval [years]')
grid on
set(gca,'YScale','log')
ylim([0 100])
plot_tit = sprintf('%s - Varying mu', station_name);
title(plot_tit)

chan = colorbar;
colormap(mycolors)
chan.YTick = .05:.1:.95;
chan.YTickLabel = mu_var;
ylabel(chan,'mu-value')


%% Save Plot 

% % cd('../../');
% % outname = sprintf('Rvalue_sensitivity_%s',station_nm);
% % hFig = gcf;
% % hFig.PaperUnits = 'inches';
% % hFig.PaperSize = [8.5 11];
% % hFig.PaperPosition = [0 0 7 7];
% % print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
% % close(hFig)
% % 
% % %cd('../../../matlab/Climatology')
% % cd('matlab/Climatology')
