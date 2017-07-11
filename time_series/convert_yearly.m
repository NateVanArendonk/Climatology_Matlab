%% Get the yearly average 

%Load in data, this will change a lot
load('/Users/andrewmcauliffe/Desktop/Matlab/Matlab_Structure/downloaded_data/Whidbey_hourly.mat')
%wind direction for some reason isn't in the correct format so change it
wnddir = wnddir';

%%
yr_vec = year(time(1)):year(time(end));  %creates a vector spanning from years of data
wndspd_mean = NaN(length(yr_vec),1);  %sets this variable equal to NaNs the length of yr_vec
wnddir_mean = wndspd_mean;  %Equal to NaNs 
wnddir_weighted = wndspd_mean; %Equal to Nans
for yr = 1:length(yr_vec)
    tinds = year(time)==yr_vec(yr);
    
    %This will run the length of yr_vec, so tinds is a logical "vector"
    %that stores the indices where for that iteration, the time vector has
    %the same value as the yr_vec
    
    % then run an if statement, to see if there are enough values to
    % calculate a mean for the year, if there are then calculate the mean
    % at each tind for the entire year and then start over.  
    
    
    if sum(tinds) > 365*24*.5 %50% of year
        wndspd_mean(yr) = mean(wndspd(tinds));
        wnddir_mean(yr) = mean(wnddir(tinds));
        wnddir_weighted(yr) = sum(wndspd(tinds).*wnddir(tinds))/sum(wndspd(tinds));
    end
end    
%% Another way to aggregate on yearly 

temp_wndspd = fints(time,wndspd);
temp_wnddir = fints(time,wnddir);
temp_slp = fints(time,slp);
temp_dewp = fints(time,airtemp);
temp_airtemp = fints(time,dewp);

wndspd_yy = toannual(temp_wndspd, 'CalcMethod', 'SimpAvg');
wnddir_yy = toannual(temp_wnddir, 'CalcMethod', 'SimpAvg');
slp_yy = toannual(temp_slp, 'CalcMethod', 'SimpAvg');
dewp_yy = toannual(temp_dewp, 'CalcMethod', 'SimpAvg');
airtemp_yy = toannual(temp_airtemp, 'CalcMethod', 'SimpAvg');
%window_size = 12;
%simple = tsmovavg(wnddir_mo,'s',window_size,1) %calculates moving average

wndspd_yr = fts2mat(wndspd_yy);
wnddir_yr = fts2mat(wnddir_yy);
slp_yr = fts2mat(slp_yy);
dewp_yr = fts2mat(dewp_yy);
airtemp_yr = fts2mat(airtemp_yy);
%simple = tsmovavg(wnddir_mo,'s',window_size,1); %calculates moving average
clear temp_wndspd temp_wnddir temp_slp temp_dewp temp_airtemp wndspd_yy wnddir_yy slp_yy dewp_yy airtemp_yy






%% Plot binned results, fit trend lines
% half_time = round(length(yr_vec)/2);
% first_third = round(length(yr_vec)/3);
% second_third = first_third + first_third;
% 
% 
% clf
% subplot(311)
% plot(yr_vec,wndspd_mean)
% ylabel('Avg Wind Speed (m/s)')
% xlabel('Time (years)')
% title('Whidbey NAS - Wind')
% grid on
% 
% hold on
% myfit = fitlm(yr_vec(1:end), wndspd_mean(1:end));
% plot(yr_vec(1:end), myfit.Fitted)
% slope = num2str(round(myfit.Coefficients{2,1},4));
% slope = strcat('Slope: ',' ', slope);
% pvalue = num2str(round(myfit.Coefficients{2,4},2));
% pvalue = strcat('p-value: ',' ', pvalue);
% r2 = num2str(round(myfit.Rsquared.Ordinary(1,1),4));
% r2 = strcat('R^2: ',' ', r2);
% text(1942,2.8,slope)
% text(1942,2.5,pvalue)
% text(1942,2.2,r2)
% 
% 
% 
% subplot(312)
% plot(yr_vec,wnddir_mean)
% ylabel('Avg Wind Dir (degrees)')
% xlabel('Time (years)')
% grid on
% 
% hold on
% myfit = fitlm(yr_vec(1:end), wnddir_mean(1:end));
% plot(yr_vec(1:end), myfit.Fitted)
% slope = num2str(round(myfit.Coefficients{2,1},3));
% slope = strcat('Slope: ',' ', slope);
% pvalue = num2str(round(myfit.Coefficients{2,4},2));
% pvalue = strcat('p-value: ',' ', pvalue);
% r2 = num2str(round(myfit.Rsquared.Ordinary(1,1),4));
% r2 = strcat('R^2: ',' ', r2);
% text(1942,208,slope)
% text(1942,205,pvalue)
% text(1942,202,r2)
% 
% 
% 
% 
% subplot(313)
% plot(yr_vec,wnddir_weighted)
% ylabel('Avg Wind Dir - Weighted (degrees)')
% xlabel('Time (years)')
% grid on
% 
% 
% hold on
% %Adds trends for half the year
% % myfit = fitlm(yr_vec(1:half_time),wnddir_weighted(1:half_time));
% % plot(yr_vec(1:half_time),myfit.Fitted)
% % myfit = fitlm(yr_vec(half_time:end),wnddir_weighted(half_time:end));
% % plot(yr_vec(half_time:end),myfit.Fitted)
% % myfit = fitlm(yr_vec(1:end),wnddir_weighted(1:end));
% % plot(yr_vec(1:end),myfit.Fitted)
% %Linear model for 1st third of data
% myfit1 = fitlm(yr_vec(1:first_third), wnddir_weighted(1:first_third));
% plot(yr_vec(1:first_third), myfit1.Fitted)
% slope = num2str(round(myfit1.Coefficients{2,1},3));
% slope = strcat('Slope: ',' ', slope);
% text(1953,205,slope)
% 
% %Linear model for 2nd third of data
% myfit2 = fitlm(yr_vec(first_third:second_third),wnddir_weighted(first_third:second_third));
% plot(yr_vec(first_third:second_third), myfit2.Fitted)
% slope = num2str(round(myfit2.Coefficients{2,1},3));
% slope = strcat('Slope: ',' ', slope);
% text(1983,205,slope)
% 
% %Linear model for last third of data
% myfit3 = fitlm(yr_vec(second_third:end), wnddir_weighted(second_third:end));
% plot(yr_vec(second_third:end), myfit3.Fitted)
% slope = num2str(round(myfit3.Coefficients{2,1},3));
% slope = strcat('Slope: ',' ', slope);
% text(2003,205,slope)
% 
% %Linear model for all of data
% myfit_tot = fitlm(yr_vec(1:end),wnddir_weighted(1:end));
% plot(yr_vec(1:end),myfit_tot.Fitted)
% slope = num2str(round(myfit_tot.Coefficients{2,1},3));
% slope = strcat('Slope: ',' ', slope);
% pvalue = num2str(round(myfit_tot.Coefficients{2,4},2));
% pvalue = strcat('p-value: ',' ', pvalue);
% r2 = num2str(round(myfit_tot.Rsquared.Ordinary(1,1),4));
% r2 = strcat('R^2: ',' ', r2);
% text(1942,218,slope)
% text(1942,212,pvalue)
% text(1942,207,r2)
%% 

% 
% clf 
% subplot(211)
% plot(yr_vec(20:end),wndspd_mean(20:end))
% ylabel('Avg Wind Speed (m/s)')
% xlabel('Time (years)')
% title('Whidbey NAS - Wind')
% grid on
% 
% subplot(212)
% plot(yr_vec(20:end), wnddir_mean(20:end))
% ylabel('Avg Wind Dir (degrees)')
% xlabel('Time (years)')
% title('Whidbey NAS - Wind Dir')
% grid on
% 
% 
% outname = sprintf('Windspd_DIR_whidbeyNAS');
% hFig = gcf;
% hFig.PaperUnits = 'inches';
% hFig.PaperSize = [7 7];
% hFig.PaperPosition = [0 0 7 7];
% print(hFig,'-dpng','-r350',outname)
% 
% close(hFig)



