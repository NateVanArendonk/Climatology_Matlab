%% Get Monthly mean values, max values 
%Load in data

tic

load('/Users/andrewmcauliffe/Desktop/Matlab/Matlab_Structure/downloaded station data/Whidbey_hourly.mat')


%% Get rid of NaNs
% First 9 values are NaNs
wndspd(isnan(wndspd))=0;
slp(isnan(slp))=0;
wnddir(isnan(wnddir))=0;
airtemp(isnan(airtemp))=0;
dewp(isnan(dewp))=0;
%% Get monthly and yearly time vectors

%Number of months between begin date and end date
total_months = months(time(1),time(end));

%Create a yearly Vector
yr_vec = year(time(1)):year(time(end));  

%make a monthly time vector
mo_vec = datenum(year(time(1)),month(time(1)),15):(365.25/12):datenum(year(time(end)),month(time(end)),15);
%mo_vec=month(mo_vec); %convert to months

%Initialze some empty vectors to house the new data
total_pts = zeros((length(yr_vec)*12),1); 
mo_mean = NaN(length(total_pts),1);
mo_wnddir_mean = mo_mean;
mo_wnddir_weighted = mo_mean;



%% Grab mean monthly values
%Initialize a counter 
counter = 1;

for yr = 1:length(yr_vec)
    for mo = 1:12
        %grab all the indicies that are between the current year and month
        %and month + 1
        tinds = time > datenum(yr_vec(yr), mo, 1) & time < datenum(yr_vec(yr), mo + 1, 1);
        
        %Set values that aren't in the time series equal to zero 
        if sum(tinds) == 0;
            mo_mean(counter) = mean(wndspd(tinds));
            mo_wnddir_mean(counter) = mean(wnddir(tinds));
            mo_wnddir_weighted(counter) = sum(wndspd(tinds).*wnddir(tinds))/sum(wndspd(tinds));
            counter = counter + 1;
        else
            mo_mean(counter) = mean(wndspd(tinds));
            mo_wnddir_mean(counter) = mean(wnddir(tinds));
            mo_wnddir_weighted(counter) = sum(wndspd(tinds).*wnddir(tinds))/sum(wndspd(tinds)); 
            counter = counter + 1;
        end
    end
end

%% Get rid of NaNs padding beginning and end of data

%Indicies of all non NaN locations
i1 = ~isnan(mo_mean);
i2 = ~isnan(mo_wnddir_mean);
i3 = ~isnan(mo_wnddir_weighted);

%Update variables
mo_mean = mo_mean(i1);
mo_wnddir_mean = mo_wnddir_mean(i2);
mo_wnddir_weighted = mo_wnddir_weighted(i3);


%gets mo_vec on same length as average data
if length(mo_vec) ~= length(mo_mean);
    mo_vec(end+1) = datenum(year(time(end)),month(time(end)),15);
end

toc 

%% Convert to financial time series and convert to monthly


% temp_wndspd = fints(time,wndspd);
% temp_wnddir = fints(time,wnddir);
% temp_slp = fints(time,slp);
% temp_dewp = fints(time,airtemp);
% temp_airtemp = fints(time,dewp);
% 
% wndspd_mo = tomonthly(temp_wndspd, 'CalcMethod', 'SimpAvg');
% wnddir_mo = tomonthly(temp_wnddir, 'CalcMethod', 'SimpAvg');
% slp_mo = tomonthly(temp_slp, 'CalcMethod', 'SimpAvg');
% dewp_mo = tomonthly(temp_dewp, 'CalcMethod', 'SimpAvg');
% airtemp_mo = tomonthly(temp_airtemp, 'CalcMethod', 'SimpAvg');
% window_size = 12;
% %simple = tsmovavg(wnddir_mo,'s',window_size,1) %calculates moving average
% 
% wndspd_mo = fts2mat(wndspd_mo);
% wnddir_mo = fts2mat(wnddir_mo);
% slp_mo = fts2mat(slp_mo);
% dewp_mo = fts2mat(dewp_mo);
% airtemp_mo = fts2mat(airtemp_mo);
% simple = tsmovavg(wnddir_mo,'s',window_size,1); %calculates moving average
% clear temp_wndspd temp_wnddir temp_slp temp_dewp temp_airtemp
% 
% %This just creates a month vector of same length data vector
% if length(mo_vec) ~= length(wndspd_mo);
%     mo_vec(end+1) = datenum(year(time(end)),month(time(end)),15);
% end

% plot(mo_vec, simple)
% datetick()
% hold on
% myfit = fitlm(mo_vec(1:end), simple(1:end));
% plot(mo_vec(1:end), myfit.Fitted)
% xlabel('Time (years)')
% ylabel('Wind Direction - MA (degrees)')

% outname = sprintf('Whidbey_wnddirMA');
% hFig = gcf;
% hFig.PaperUnits = 'inches';
% hFig.PaperSize = [7 7];
% hFig.PaperPosition = [0 0 7 7];
% print(hFig,'-dpng','-r350',outname)
%  
% close(hFig)
