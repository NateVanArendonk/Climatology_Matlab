% blocksize = 1000;
% nblocks = 250;
% 
% x = max(t); % 250 column maxima
% paramEsts = gevfit(x);
% 
% 
% histogram(x,2:20,'FaceColor',[.8 .8 1]);
% xgrid = linspace(2,20,1000);
% line(xgrid,nblocks*...
%      gevpdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)));
 
%% GEV Fit for Block Maxima

clearvars

%first load in the data
dir_nm = '../../hourly_data/';
%dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
station_name = 'Van Airport';
station_nm = 'van_arpt';
%file_nm = 'whidbey_nas_hourly'; % you will have to change this variable for each station
load_file = strcat(dir_nm,station_nm, '_hourly');
load(load_file)
clear dir_nm file_nm load_file
wnddir = wnddir';

% for NDBC data get rid of 'hourly' in load_file 
% Also add the following line after wnddir = wndir';
            % wndspd = wndspd_obs;


%% Find yearly max

yr_vec = year(time(1)):year(time(end)); %make a year vec
maxima = NaN(length(yr_vec),1); %create vector to house all of the block maxima
for i = 1:length(yr_vec)
    yr_ind = find(year(time) == yr_vec(i));
    % If there is more than 50% of the hours missing for that year, I will
    % skip it
    if length(yr_ind) < 8760 * .5
        continue
    else
    %max_val = max(wndspd(yr_ind));
        maxima(i) = max(wndspd(yr_ind));
    end
end

del_ind = find(maxima < 10);   % find indices less than 10, likely indicating poor data coverage or a large data gap
maxima(del_ind) = []; % get rid of data
yr_vec(del_ind) = []; % get rid of year from year vec

clear j yr_ind

% Get GEV statistics about the data
[paramEsts, paramCIs] = gevfit(maxima);
%----------------Results from GEV-------------------------------
kMLE = paramEsts(1);        % Shape parameter
sigmaMLE = paramEsts(2);    % Scale parameter
muMLE = paramEsts(3);       % Location parameter
lowerBnd = muMLE-sigmaMLE./kMLE;
%% Plot the GEV
x = maxima;  
ymax = 1.1*max(x);
bins = floor(lowerBnd):ceil(ymax);
h = bar(bins,histc(x,bins)/length(x),'histc');
h.FaceColor = [.9 .9 .9];
ygrid = linspace(lowerBnd,ymax,100);
line(ygrid,gevpdf(ygrid,kMLE,sigmaMLE,muMLE));
xlabel('Block Maximum');
ylabel('Probability Density');
xlim([lowerBnd ymax]);
