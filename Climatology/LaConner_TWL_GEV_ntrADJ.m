% Plot GEV for LaConner TWL
%% GEV for La Conner
% Data is every half hour

clearvars

% add path to t_tides
addpath('../../matlab_functions/t_tide')

% Load in data
clearvars                                                                  
dir_nm = '../../COOPS_tides/';
station_nm = 'LaConner';
load_file = strcat(dir_nm,station_nm,'/',station_nm,'_predictions_ntr');
LC = load(load_file);

%S = load('seattle_hrV.mat');
%S = S.tides;

% Load LaConner Constituents
load_file = strcat(dir_nm,station_nm,'/',station_nm,'_harmonics.mat');
LC_harm = load(load_file);
LC.tide_pred_cust = t_predic(LC.time,LC_harm);

% Convert prediction from MSL to MLLW by adding amplitudes of M2,K1,O1
% harmonics
% M2 - 15, K1 - 8, O1 - 6
LC.tide_pred_cust = LC.tide_pred_cust + LC_harm.tidecon(15,1) + LC_harm.tidecon(8,1) + LC_harm.tidecon(6,1);


m2ft = 3.28;

% Convert to Feet, Current datum for LC is MLLW, for S is NAVD88
% navd882mllw = 0.416*m2ft;
% test = navd882mllw + m2ft*LC.tide_pred;
% test2 = navd882mllw + m2ft*LC.twl;
LC.twl = LC.twl*m2ft;
LC.tide_pred = LC.tide_pred*m2ft;
LC.ntr = LC.ntr*m2ft;
LC.tide_pred_cust = LC.tide_pred_cust*m2ft;

LC.tide_pred(1:2000) = NaN;

LC.twl = LC.tide_pred+1.25*LC.ntr;

%% Cursory Look
clf
subplot(211)
plot(LC.time,LC.tide_pred)

datetick
%ylim([-2 4])

subplot(212)
plot(LC.time,LC.ntr)
datetick

%% Short Time series
clf

hold on
plot(LC.time,LC.tide_pred)
%plot(LC.time,LC.twl)
plot(LC.time,LC.tide_pred_cust,'--b')
plot(LC.time,LC.ntr,'-k')
%xlim([datenum(2005,12,25) datenum(2006,1,6)])
xlim([datenum(2006,2,1) datenum(2006,2,8)])
datetick('x','mm/dd/yyyy','keeplimits')
xlabel('2006')
ylim([-2 15])
grid on
box on
legend('Tide-NOAA','Tide-Cust','NTR')
ylabel('Elevation [ft, MLLW]')

[m, I] = max(LC.twl)

%printFig(gcf,'LaConner_Feb2006',[6 6],'png',200)

%% Long Time series
clf

hold on
plot(LC.time,LC.tide_pred)
plot(LC.time,LC.twl)
plot(LC.time,LC.tide_pred_cust,'--b')
plot(LC.time,LC.ntr,'-k')
%xlim([datenum(2005,12,25) datenum(2006,1,6)])
%xlim([datenum(2006,2,1) datenum(2006,2,8)])
datetick('x','keeplimits')
xlabel('2006')
ylim([-2 15])
grid on
box on
legend('Tide','TWL','NTR','Location','SouthWest')
ylabel('Elevation [ft, MLLW]')
%printFig(gcf,'LaConner_20years',[6 6],'png',200)

%% CDF Distribution of just Tidal Predictions
clf
m2ft = 3.28;
navd882mllw = 0.416*m2ft;
test2 = LC.tide_pred;
test = LC.twl;

test(test>15) = NaN;
test(test<-4) = NaN;

cdf = sort(test,'ascend');
cdf2 = sort(test2,'ascend');


yaxis = linspace(0,1,length(cdf));
plot(cdf,yaxis,'-')
hold on
plot(cdf2,yaxis,'-')
grid on
box on
ylabel('CDF')
xlabel('Elevation [ft, MLLW]')
legend('Tide Pred','TWL','Location','NorthWest')
%printFig(gcf,'LaConner_TidePred_CDF',[6 6],'png',200)


%% Collect maxima

% Time and variable of interest
myvar = LC.twl;
time = LC.time;
%myvar = S.WL_VALUE;
%time = S.time;

% Convert to desired datnum,unit
% m2ft = 3.28;
% navd882mllw = 0.416*m2ft;
% myvar = navd882mllw + m2ft*myvar;

% Remove NaN values
inds = isnan(myvar);
myvar(inds) = [];
time(inds) = [];

% Mean from last 10-years
mymean = mean(myvar(time>=datenum(2006,1,1) & time < datenum(2017,1,1)));

% Detrend
myvar = detrend(myvar);

% Years available
yr = 1996:2016;

% rth values to collect (can use less later)
r_num = 10;

% Min distance between events (half hour incr)
min_sep = 144;

% Preallocate
data = zeros(length(yr),r_num);

% Loop
for yy=1:length(yr)
    inds = year(time) == yr(yy);
    temp = myvar(inds);
    
    % If half of the year of data doesn't exist, skip
    if sum(inds) < 17520*.5
        data(yy,:) = NaN(1,r_num);
    else
        for r=1:r_num
            [data(yy,r), I] = max(temp);
            pop_inds = max([1 I-min_sep]):min([length(temp) I+min_sep]);
            temp(pop_inds) = [];
        end
    end
end

% Create data+mean, in whatever datum data was in 
data_datum = data + mymean;



%% Estimate the GEV paramters for varying R
figure(1)

% limits
my_xlim = [min(data_datum(:))*.95 max(data_datum(:))*1.05];

% Num hist binds
nbins = 8;

clf
%subplot(311)
pdf_data = histogram(data_datum(:,1),nbins,'Normalization','pdf');
hold on

%pdf_data = histogram(data_datum(:),nbins,'Normalization','pdf');

mycolors = jet(10);

for rth_num = 1:10
parmhat = gevfit_rth(data(:,1:rth_num));

temp = data(:,1:rth_num);
parmhat_sv = gevfit_rth(temp(:));


% GEV pdf 
x_axis = linspace(my_xlim(1),my_xlim(2),100);
pdf_gev = gevpdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+mymean); 
%pdf_gev_sv = gevpdf(x_axis,parmhat_sv(1),parmhat_sv(2),parmhat_sv(3)+mymean); 


plot(x_axis,pdf_gev,'Color',mycolors(rth_num,:))
%plot(x_axis,pdf_gev_sv,'--','Color',mycolors(rth_num,:))

end

chan = colorbar;
colormap(mycolors)

legend('r=1','r=10')

chan.YTick = .05:.1:.95;
chan.YTickLabel = 1:10;
ylabel(chan,'r-value')
ylabel('Probability')
xlabel('Maximum yearly TWL [m]')
title('La Conner')

%% Simple plot (r = 5th)

shift_to_obs = 13.6-max(LC.twl);

rth_num = 1;

% Find fit
temp = data(:,1:rth_num);
parmhat = gevfit_rth(temp);

parmhat_shift = gevfit_rth(temp+shift_to_obs);


% GEV pdf 
x_axis = linspace(my_xlim(1),my_xlim(2),1000);
pdf_gev = gevpdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+mymean); 
cdf_gev = gevcdf(x_axis,parmhat(1),parmhat(2),parmhat(3)+mymean); 

cdf_gev_shift = gevcdf(x_axis,parmhat_shift(1),parmhat_shift(2),parmhat_shift(3)+mymean); 

rec = 1./(1-cdf_gev);
rec_shift = 1./(1-cdf_gev_shift);

fill_x1 = linspace(11,13.3,100);
fill_cdf = gevcdf(fill_x1,parmhat(1),parmhat(2),parmhat(3)+mymean);
fill_rec1 = 1./(1-fill_cdf);
fill_x2 = linspace(11,13.8,100);
fill_cdf = gevcdf(fill_x2,parmhat(1),parmhat(2),parmhat(3)+mymean+.43);
fill_rec2 = 1./(1-fill_cdf);


clf
%-----Plot PDF----------

clf
p_left = .075;
p_right = 0.025;
p_bot = .085;
p_top = 0.06;
p_vspace = .075;
p_wid = (1-p_vspace-p_left-p_right)/2;
p_hspace = .0;
p_height = (1-p_bot-p_top-p_hspace)/1;

axes('position',[p_left+0*(p_vspace+p_wid) p_bot+0*(p_hspace+p_height) p_wid p_height])
hold on
histogram(data_datum(:,1),5,'Normalization','pdf');
%histogram(data_datum(:),nbins,'Normalization','pdf');
plot(x_axis,pdf_gev,'Color','b','LineWidth',1)
lhan=legend('Observations','GEV','Location','NorthWest');
set(lhan,'box','off')
ylabel('Probability Distribution')
xlabel('Maximum Yearly Water Level [ft, MLLW]')
%title('La Conner')
box on

mycolors = lines(10);
axes('position',[p_left+1*(p_vspace+p_wid) p_bot+0*(p_hspace+p_height) p_wid p_height])
%hold on

hold on
fhan=fill([fill_x1 fliplr(fill_x2)],[fill_rec1 fliplr(fill_rec2)],mycolors(1,:));
set(fhan,'EdgeColor','none')
alpha(.5)
semilogy(x_axis,rec,'k')
%semilogy(fill_x2,fill_rec2,'Color',mycolors(7,:))
semilogy(x_axis+1,rec,'Color',mycolors(3,:))
semilogy(x_axis+2,rec,'Color',mycolors(2,:))
set(gca,'YScale','log')
ylim([0 100])
xlim([12 15.5])
grid on
xlabel('Maximum Yearly Water Level [ft, MLLW]')
ylabel('Recurrence Intveral [years]')

legend('Range','Current','1-foot SLR','2-feet SLR','Location','NorthWest')

%printFig(gcf,'LaConner_GEV_Imperial_MLLW_adj',[10 6],'png',200)

% Print out recurrence levels
rec_rate = [2 5 10 25 50 100];
fid = fopen('LaConnerReturnRates_adjNTR.txt','wt');
for rr = 1:length(rec_rate)
    I = findnearest(rec_rate(rr),rec);
    fprintf(fid,'%d-year Return Level: %4.2f ft \n',rec_rate(rr),x_axis(I))
end
fclose(fid);

% % Print out recurrence levels
% rec_rate = [5 10 25 50 100];
% fid = fopen('LaConnerReturnRates_1slr.txt','wt');
% for rr = 1:length(rec_rate)
%     I = findnearest(rec_rate(rr),rec);
%     fprintf(fid,'%d-year Return Level: %4.2f ft \n',rec_rate(rr),x_axis(I)+1)
% end
% fclose(fid);
% 
% % Print out recurrence levels
% rec_rate = [5 10 25 50 100];
% fid = fopen('LaConnerReturnRates_2slr.txt','wt');
% for rr = 1:length(rec_rate)
%     I = findnearest(rec_rate(rr),rec);
%     fprintf(fid,'%d-year Return Level: %4.2f ft \n',rec_rate(rr),x_axis(I)+2)
% end
% fclose(fid);

%% La Conner TWL Exceedance hours

mycolors = lines(10);

%thresh = [10 12.8 13.5 14];
thresh = 10:.1:14;
for tt=1:length(thresh)
    mycount(tt) = sum(LC.twl > thresh(tt));
    mycount_slr1(tt) = sum(LC.twl+1 > thresh(tt));
    mycount_slr2(tt) = sum(LC.twl+2 > thresh(tt));
end

L = (LC.time(end)-LC.time(1))/365.25;
mycount = mycount/2/L;% hours per year
mycount_slr1 = mycount_slr1/2/L;% hours per year
mycount_slr2 = mycount_slr2/2/L;% hours per year

clf
hold on
plot(thresh,mycount,'-','Color',mycolors(1,:))
plot(thresh,mycount_slr1,'-','Color',mycolors(3,:))
plot(thresh,mycount_slr2,'-','Color',mycolors(2,:))


clear mycount mycount_slr1 mycount_slr2
thresh = [10 12.8 13.5 14];
for tt=1:length(thresh)
    mycount(tt) = sum(LC.twl > thresh(tt));
    mycount_slr1(tt) = sum(LC.twl+1 > thresh(tt));
    mycount_slr2(tt) = sum(LC.twl+2 > thresh(tt));
end
L = (LC.time(end)-LC.time(1))/365.25;
mycount = mycount/2/L;% hours per year
mycount_slr1 = mycount_slr1/2/L;% hours per year
mycount_slr2 = mycount_slr2/2/L;% hours per year
plot(thresh,mycount,'o','Color',mycolors(1,:),'MarkerFaceColor',mycolors(1,:))
plot(thresh,mycount_slr1,'o','Color',mycolors(3,:),'MarkerFaceColor',mycolors(3,:))
plot(thresh,mycount_slr2,'o','Color',mycolors(2,:),'MarkerFaceColor',mycolors(2,:))

ylabel('Mean Yearly Exceedance [hours]')
xlabel('TWL [ft, MLLW]')
grid on
legend('Current','1-foot SLR','2-feet SLR')
set(gca,'YScale','log')
ylim([1e-1 1e4])

box on

% printFig(gcf,'LaConner_TWL_Exceedance',[6 6],'png',200)
% 
% fid = fopen('Exceedance_Bar.csv','wt');
% fprintf(fid,'%5.2f,%5.2f,%5.2f,%5.2f\n',thresh);
% fprintf(fid,'%5.2f,%5.2f,%5.2f,%5.2f\n',mycount);
% fprintf(fid,'%5.2f,%5.2f,%5.2f,%5.2f\n',mycount_slr1);
% fprintf(fid,'%5.2f,%5.2f,%5.2f,%5.2f\n',mycount_slr2);
% fclose(fid);



%%
return


%%
% x = 0:.1:100;
% y = .1*x+randn(size(x))+5;
% y_d = detrend(y);
% 
% clf
% plot(x,y,x,y_d)
% 
% 
% 
% %%
% f = @(x,y,z) x*cos(y)+z^2;
% x0 = [1 2 3];
% 
% %H = numHessian(f,x0,3)
% 
% H = numHessian(@test_func,[0 0 0]',2)






