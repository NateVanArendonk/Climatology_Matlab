%% GEV Fit for Block Maxima

clearvars

%first load in the data
%dir_nm = '../../hourly_data/';
dir_nm = '../../COOPS_tides/';
station_name = 'La Conner';
station_nm = 'LaConner';

%load_file = strcat(dir_nm,station_nm,'/',station_nm,'_6minV');
load_file = strcat(dir_nm,station_nm,'/',station_nm);
load(load_file)
clear dir_nm file_nm load_file


%% Find yearly max
yr_vec = year(tides.time(1)):year(tides.time(end)); %make a year vec
maxima = NaN(length(yr_vec),1); %create vector to house all of the block maxima
for i = 1:length(yr_vec)
    yr_ind = find(year(tides.time) == yr_vec(i));
    % If there is more than 50% of the hours missing for that year, I will
    % skip it
    if length(yr_ind) < 8760 * .5
        maxima(i) = NaN;
    else
    %max_val = max(wndspd(yr_ind));
        maxima(i) = max(tides.WL_VALUE(yr_ind));
    end
end

nan_ind = isnan(maxima); % Find any nans and get rid of them
maxima(nan_ind) = [];

clear j yr_ind

% Get GEV statistics about the data
[paramEsts, paramCIs] = gevfit(maxima);
%----------------Results from GEV-------------------------------
% % % kMLE = paramEsts(1);        % Shape parameter
% % % sigmaMLE = paramEsts(2);    % Scale parameter
% % % muMLE = paramEsts(3);       % Location parameter
%% fit the GEV
lowerBnd = 2;
x = maxima;  
xmax = 1.1*max(x);
bins = floor(lowerBnd):.1:ceil(xmax);
xgrid = linspace(lowerBnd,xmax,190);

% Calculate the CDF - CDF will give me the probability of values 
cdf = gevcdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)); % create CDF from GEV PDF
%% Exceedance Probability

% PE = 1 - cdf
clf
PE = 1 - cdf;

set(gca, 'YScale', 'log')

% 2 feet of SLR
zgrid = xgrid + .6096;
l3 = line(zgrid, PE, 'Linewidth', 2);
l3.Color = 'red';

hold on
% 1 foot of SLR
tgrid = xgrid + .3048;
l2 = line(tgrid, PE,'Linewidth', 2);
l2.Color = 'green';

hold on

l1 = line(xgrid, PE,'Linewidth', 2);
ylim([10^-3 10^0])
l1.Color = 'blue';

xlim([2 4])

legend('2 ft SLR', '1 ft SLR', 'Current WL')

xlabel('Total Water Level [meters]')
ylabel('Probability of Exceedance')




grid on


% Find difference in recurrence interval


recur_10 = findnearest(.1, PE, 0);
recur_100 = findnearest(.01, PE, 0);


% Find the water values at each 10, 100 yr level
wl10 = xgrid(recur_10);
wl100 = xgrid(recur_100);


% Find water levels in 1 ft scenario
ind10_1 = findnearest(wl10, tgrid, 0);
ind100_1 = findnearest(wl100, tgrid, 0);
% Find water levels in 2 ft scenario
ind10_2 = findnearest(wl10, zgrid, 0);
ind100_2 = findnearest(wl100, zgrid, 0);

% Grab actual values
peval_10_1 = PE(ind10_1);
peval_100_1 = PE(ind100_1);
peval_10_2 = PE(ind10_2);
peval_100_2 = PE(ind100_2);
% Convert to new recurrence interval
RIwith1_10 = 1/peval_10_1;
RIwith1_100 = 1/peval_100_1;
RIwith2_10 = 1/peval_10_2;
RIwith2_100 = 1/peval_100_2;

    
tbox = sprintf('Change in Recurrence\n 10 year\t\t\t 100 year\n 1 ft:%4.2f\t\t\t %4.2f\n 2ft:%4.2f \t\t\t %4.2f'...
    , RIwith1_10, RIwith1_100, RIwith2_10, RIwith2_100);

dim = [.2 .3 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');



%%
% Save the Plot
cd('../../swin/tides/')

outname = sprintf('Prob_exceed_change%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

cd('../../matlab/Climatology')
