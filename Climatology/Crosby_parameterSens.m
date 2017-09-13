% Plot GEV for LaConner TWL
%% GEV for La Conner
% Data is every half hour

clearvars
LC = load('LaConner_predictions_ntr.mat');

S = load('seattle_hrV.mat');
S = S.tides;

%% Cursory Look
clf
subplot(211)
plot(LC.time,LC.twl)
datetick

subplot(212)
plot(LC.time,LC.ntr)
datetick

%% Collect maxima

% Time and variable of interest
%myvar = LC.twl;
%time = LC.time;
myvar = S.WL_VALUE;
time = S.time;

% Remove NaN values
inds = isnan(myvar);
myvar(inds) = [];
time(inds) = [];

% Mean from last 10-years
mymean = mean(myvar(time>=datenum(2006,1,1) & time < datenum(2017,1,1)));

% Detrend
myvar = detrend(myvar);

% Years available
yr = 1900:2016;

% rth values to collect (can use less later)
r_num = 10;

% Min distance between events (half hour incr)
min_sep = 24;

% Preallocate
data = zeros(length(yr),r_num);

% Loop
for yy=1:length(yr)
    inds = year(time) == yr(yy);
    temp = myvar(inds);
    for r=1:r_num
        [data(yy,r), I] = max(temp);
        pop_inds = max([1 I-min_sep]):min([length(temp) I+min_sep]);
        temp(pop_inds) = [];
    end
end

% Create data+mean, in whatever datum data was in (NAVD88)
data_datum = data + mymean;

%% Estimate the GEV paramters for varying R
figure(1)

% limits
my_xlim = [min(data_datum(:))*.95 max(data_datum(:))*1.05];

% Num hist binds
nbins = 20;

clf
subplot(311)
pdf_data = histogram(data_datum(:,1),nbins,'Normalization','pdf');
hold on

pdf_data = histogram(data_datum(:),nbins,'Normalization','pdf');

mycolors = jet(10);

for rth_num = 1:10
parmhat = gevfit_rth(data(:,1:rth_num));

temp = data(:,1:rth_num);
parmhat_sv = gevfit_rth(temp(:));


% GEV pdf 
x_axis = linspace(my_xlim(1),my_xlim(2),100);
pdf_gev = gevpdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+mymean); 
pdf_gev_sv = gevpdf(x_axis,parmhat_sv(1),parmhat_sv(2),parmhat_sv(3)+mymean); 


plot(x_axis,pdf_gev,'Color',mycolors(rth_num,:))
plot(x_axis,pdf_gev_sv,'--','Color',mycolors(rth_num,:))

end

chan = colorbar;
colormap(mycolors)

legend('r=1','r=10')

chan.YTick = .05:.1:.95;
chan.YTickLabel = 1:10;
ylabel(chan,'r-value')
ylabel('Probability')
xlabel('Maximum yearly TWL [m]')
title('Seattle')


%% Estimate the GEV paramters for fixed r
figure(1)

% limits
my_xlim = [min(data_datum(:))*.95 max(data_datum(:))*1.05];

% Num hist binds
nbins = 20;

% Line colors
mycolors = jet(10);

% Find GEV Params
%[parmhat,parmCI] = gevfit_rth(data(:,1));
[parmhat,parmCI] = gevfit(data(:,1));

% GEV pdf 
x_axis = linspace(my_xlim(1),my_xlim(2),100);
pdf_gev = gevpdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+mymean); 

%-----Plot PDF----------

clf
subplot(311)
hold on
histogram(data_datum(:,1),nbins,'Normalization','pdf');
%histogram(data_datum(:),nbins,'Normalization','pdf');
plot(x_axis,pdf_gev,'Color','b')
legend('Observations','GEV')
ylabel('Probability')
xlabel('Maximum yearly TWL [m]')
title('Seattle')



%----Plot CDF----

% Data cdf based on block (r=1)
cdf_data = sort(data_datum(:,1),'ascend');
y_data = linspace(0,1,length(cdf_data));

% GEV CDF
cdf_gev = gevcdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+mymean); 

subplot(312)
hold on
plot(cdf_data,1-y_data,'ok')
plot(x_axis,1-cdf_gev,'b')
%plot(x_axis,1-cdf_gev_r)
xlabel('Maximum yearly TWL [m]')
ylabel('Probability of Yearly Exceedance')
grid on
xlim(my_xlim)
legend('Observations','GEV')
%set(gca,'YScale','log')

% Create cdf's for all rth values
for rth_num = 1:10
    parmhat_rth = gevfit_rth(data(:,1:rth_num));
    cdf_gev_r(:,rth_num) = gevcdf(x_axis,parmhat_rth(1),parmhat_rth(2),parmhat_rth(3)+mymean); 
end

% Create cdf's for varying block estimates using CI
res = 10;
k_var = linspace(parmCI(1,1),parmCI(2,1),res);
sig_var = linspace(parmCI(1,2),parmCI(2,2),res);
mu_var = linspace(parmCI(1,3),parmCI(2,3),res);
count = 1;
cdf_gev_MC = zeros(length(x_axis),res^3);
for ii = 1:length(k_var)
    for jj = 1:length(sig_var)
        for kk = 1:length(mu_var)
            parmhat = gevfit(data(:,1));
            cdf_gev_MC(:,count) = gevcdf(x_axis,k_var(ii),sig_var(jj),mu_var(kk)+mymean);
            count = count+1;
        end
    end
end


%subplot(313)
clf
hold on
%plot(x_axis,1./(1-cdf_gev))
%plot(cdf_data,1./(1-y_data),'o')
plot(x_axis,1./(1-cdf_gev_MC),'Color',[.7 .7 .7])
for rth_num = 1:10
    plot(x_axis,1./(1-cdf_gev_r(:,rth_num)),'Color',mycolors(rth_num,:))
end
xlabel('Maximum yearly TWL [m]')
ylabel('Recurrence Interval [years]')
grid on
set(gca,'YScale','log')
ylim([0 100])
xlim(my_xlim)

printFig(gcf,'LaConner_TWL_GEV',[5 8],'png',150)




%%
return


%%
x = 0:.1:100;
y = .1*x+randn(size(x))+5;
y_d = detrend(y);

clf
plot(x,y,x,y_d)



%%
f = @(x,y,z) x*cos(y)+z^2;
x0 = [1 2 3];

%H = numHessian(f,x0,3)

H = numHessian(@test_func,[0 0 0]',2)






