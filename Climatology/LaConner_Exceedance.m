%% GEV for La Conner
% Data is every half hour

clearvars

%first load in the data
%dir_nm = '../../hourly_data/';
dir_nm = '../../COOPS_tides/';
station_name = 'La Conner'; % to be used in titles
station_nm = 'LaConner';

%load_file = strcat(dir_nm,station_nm,'/',station_nm,'_6minV');
load_file = strcat(dir_nm,station_nm,'/',station_nm);
load(load_file)
clear dir_nm file_nm load_file


%%  Find maximum - R number of 'blocks'
% Number of r values to look for
r_val = 3;

%make a year vec
yr_vec = year(time(1)):year(time(end)); 

%create matrix to house all of the block maxima
maxima = zeros(length(yr_vec), r_val); 

for y = 1:length(yr_vec)
    % Grab current year indices
    yr_ind = find(year(time) == yr_vec(y));
    % Populate temporary variables
    temp_time = time(yr_ind);
    temp_wl = twl(yr_ind);
    
    % If half of the year of data doesn't exist, skip
    if length(yr_ind) < 17520*.5
        max_block = NaN(y,r_val);
    else
        
        % Loop through and grab the maximum values and delete a window
        % around each maximum to ensure different tide cycles
        max_block = NaN(1,r_val);
        for m = 1:r_val
            [M, I] = max(temp_wl);
            % Remove 72 hours around each point to ensure different events
            if I < 144
                window = I - (I-1):1:I + 144;
            elseif length(temp_wl) - I < 144
                window = I - 144:1:length(temp_wl);
            else
                window = I - 144:1:I+144;
            end
            % Remove indices
            temp_wl(window) = [];
            temp_time(window) = [];
            max_block(m) = M;
        end
    end
    % Add max values to maxima matrix
    maxima(y,:) = max_block;
end

%% Get GEV statistics of the distribution

% Reshape to be a single vector
maxima = reshape(maxima, [length(yr_vec)*r_val, 1]);
% Remove NaN's
na_ind = isnan(maxima);
maxima(na_ind) = [];

[paramEsts, paramCIs] = gevfit(maxima);
%----------------Results from GEV-------------------------------
% % % kMLE = paramEsts(1);        % Shape parameter
% % % sigmaMLE = paramEsts(2);    % Scale parameter
% % % muMLE = paramEsts(3);       % Location parameter


%% Calculate CDF from GEV fit of PDF
lowerBnd = 2;
x = maxima;  
xmax = 1.1*max(x);
bins = floor(lowerBnd):.1:ceil(xmax);
xgrid = linspace(lowerBnd,xmax,10000);

% Calculate the CDF - CDF will give me the probability of values 
cdf = gevcdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)); 
cdf2 = 1 - gevcdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)); 

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
ylim([1 100])
xlim([3.4 4.8])
plot_tit = sprintf('Recurrence Interval - %s', station_name);
title(plot_tit)
xlabel('Total Water Level [m]')
ylabel('Time [years]')

% Add minor tick marks on x-axis and Relabel Ticks on Y-axis
ax = gca;
set(gca,'XMinorTick','on','YTickLabel',{'1-year','10-year','100-year'})  

% Add grid lines
box on; grid on


% Generate specific values for recurrence levels
R100MLE = gevinv(1-1./100,paramEsts(1),paramEsts(2),paramEsts(3));
R50MLE = gevinv(1-1./50,paramEsts(1),paramEsts(2),paramEsts(3));
R25MLE = gevinv(1-1./25,paramEsts(1),paramEsts(2),paramEsts(3));
R10MLE = gevinv(1-1./10,paramEsts(1),paramEsts(2),paramEsts(3));
R5MLE = gevinv(1-1./5,paramEsts(1),paramEsts(2),paramEsts(3));
R2MLE = gevinv(1-1./2,paramEsts(1),paramEsts(2),paramEsts(3));

% Add GEV parameters to the plot
tbox = sprintf('100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLE, R50MLE, R25MLE, R10MLE, R5MLE, R2MLE);
dim = [.154 .43 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');


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
lgd.Position = [.195 .845 .05 .05];

% Add text to figure showing recurrence interval change
nx = 3.4;
ny = RI(loc1)+.14;
txt1 = sprintf('%4.2f years', RI(loc1));
t(1) = text(nx,ny,txt1);
t(1).FontSize = 14;


mx = 3.45;
my = RI(loc2)+.19;
txt2 = sprintf('%4.2f years', RI(loc2));
t(2) = text(mx,my,txt2);
t(2).FontSize = 14;


%% Exceedance Probability
% % % % % PE = 1 - cdf;
% % % % % 
% % % % % 
% % % % % % Generate the Plots
% % % % % % Set Log Scale
% % % % % set(gca, 'YScale', 'log')
% % % % % 
% % % % % % 2 feet of SLR plot
% % % % % zgrid = xgrid + .6096;
% % % % % l3 = line(zgrid, PE, 'Linewidth', 2);
% % % % % l3.Color = 'red';
% % % % % hold on
% % % % % 
% % % % % % 1 foot of SLR plot
% % % % % tgrid = xgrid + .3048;
% % % % % l2 = line(tgrid, PE,'Linewidth', 2);
% % % % % l2.Color = 'green';
% % % % % hold on
% % % % % 
% % % % % % TWL plot under current conditions
% % % % % l1 = line(xgrid, PE,'Linewidth', 2);
% % % % % ylim([10^-3 10^0])
% % % % % l1.Color = 'blue';
% % % % % 
% % % % % % Set Axis limits
% % % % % xlim([3.4 4.8])
% % % % % ylim([.01 1])
% % % % % % Set tick marks for Y-axis
% % % % % %set(gca,'YTickLabel',{'100-year','10-year','1-year'})
% % % % % 
% % % % % % Add labels
% % % % % legend([l3 l2 l1],'2 ft SLR', '1 ft SLR', 'Current WL')
% % % % % xlabel('Total Water Level [meters]')
% % % % % ylabel('Probability of Exceedance [years]')
% % % % % grid on
% % % % % 
% % % % % %%
% % % % % % Find difference in recurrence interval
% % % % % recur_10 = findnearest(.1, PE, 0);
% % % % % recur_100 = findnearest(.01, PE, 0);
% % % % % 
% % % % % % Find the water values at each 10, 100 yr level
% % % % % wl10 = xgrid(recur_10);
% % % % % wl100 = xgrid(recur_100);
% % % % % 
% % % % % % Find water levels in 1 ft scenario
% % % % % ind10_1 = findnearest(wl10, tgrid, 0);
% % % % % ind100_1 = findnearest(wl100, tgrid, 0);
% % % % % % Find water levels in 2 ft scenario
% % % % % ind10_2 = findnearest(wl10, zgrid, 0);
% % % % % ind100_2 = findnearest(wl100, zgrid, 0);
% % % % % 
% % % % % % Grab actual values
% % % % % peval_10_1 = PE(ind10_1);
% % % % % peval_100_1 = PE(ind100_1);
% % % % % peval_10_2 = PE(ind10_2);
% % % % % peval_100_2 = PE(ind100_2);
% % % % % % Convert to new recurrence interval
% % % % % RIwith1_10 = 1/peval_10_1;
% % % % % RIwith1_100 = 1/peval_100_1;
% % % % % RIwith2_10 = 1/peval_10_2;
% % % % % RIwith2_100 = 1/peval_100_2;
% % % % % 
% % % % % 
% % % % % %% Create vectors to plot vertical line for 10 year & 100 year levels
% % % % % 
% % % % % % 10 year lines
% % % % % vec_y = linspace(.01,peval_10_1,length(PE));
% % % % % vec_x = ones(1,length(vec_y))*xgrid(recur_10);
% % % % % p1 = line(vec_x, vec_y);
% % % % % p1.Color = 'black';
% % % % % 
% % % % % hor_x = linspace(0,wl10,length(PE));
% % % % % hor_y = ones(1,length(hor_x))* peval_10_1;
% % % % % p2 = line(hor_x, hor_y);
% % % % % p2.Color = 'black';
% % % % % 
% % % % % 
% % % % % % 100 year lines
% % % % % v2_y = linspace(0.01,peval_100_1, length(PE));
% % % % % v2_x = ones(1,length(v2_y))*xgrid(recur_100);
% % % % % p3 = line(v2_x, v2_y);
% % % % % p3.Color = 'black';
% % % % % 
% % % % % h2_x = linspace(0,wl100,length(PE));
% % % % % h2_y = ones(1,length(h2_x))*peval_100_1;
% % % % % p3 = line(h2_x, h2_y);
% % % % % p3.Color = 'black';
% % % % % 
% % % % % 
% % % % % % % tbox = sprintf('Change in Recurrence\n 10 year\t\t\t 100 year\n 1 ft:%4.2f\t\t\t %4.2f\n 2ft:%4.2f \t\t\t %4.2f'...
% % % % % % %     , RIwith1_10, RIwith1_100, RIwith2_10, RIwith2_100);
% % % % % % % 
% % % % % % % dim = [.2 .3 .3 .3];
% % % % % % % annotation('textbox',dim,'String',tbox,'FitBoxToText','on');
% % % % % 
% % % % % 
% % % % % 
% % % % % 
% % % % % 
% % % % %     
% % % % %      
