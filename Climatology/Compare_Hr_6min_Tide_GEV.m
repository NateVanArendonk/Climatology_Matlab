%% Code to compare the plots of 6 min and hourly tide data for GEV analysis


clearvars

%first load in the data
%dir_nm = '../../hourly_data/';
dir_nm = '../../COOPS_tides/';
station_name = 'Seattle';
station_nm = 'seattle';

load_file1 = strcat(dir_nm,station_nm,'/',station_nm,'_hrV');
load_file2 = strcat(dir_nm,station_nm,'/',station_nm,'_6minV');
load(load_file1)
thr = tides;
clear tides
load(load_file2)
t6 = tides;
clear tides
clear dir_nm file_nm load_file


%%  Find block maximum - rth yearly max for hourly data
% Number of r values to look for
r_val = 3;

%make a year vec
yr_vechr = year(thr.time(1)):year(thr.time(end)); 

%create matrix to house all of the block maxima
maxhr = zeros(length(yr_vechr), r_val); 
%Detrend water
thr.WL_VALUE = detrend(thr.WL_VALUE);

for y = 1:length(yr_vechr)
    % Grab all of the years
    yr_ind = find(year(thr.time) == yr_vechr(y));
    temp_time = thr.time(yr_ind);
    temp_wl = thr.WL_VALUE(yr_ind);
    
    %Make sure atleast half of the dates exist
    if length(yr_ind) < 8760*.5  %525600 minutes in a year, get in 6 minute increments so use 87600
        break
    else
        % Genearte empty vector to house maximum values
        max_block = NaN(1,r_val);

        % Loop through and grab the maximum values and delete a window
        % around each maximum to ensure different tide cycles
        for m = 1:r_val
            % Grab the maximum
            [M, I] = max(temp_wl);

            % Generate a window to delete values
            if I < 72
                window = I - (I-1):1:I + 72;
            elseif length(temp_wl) - I < 72
                window = I - 72:1:length(temp_wl);
            else
                window = I-72:1:I+72;
            end
            temp_wl(window) = [];
            temp_time(window) = [];
            
            % Add the maximum value to the empty vector
            max_block(m) = M;
        end
    end
    
    % Now populate matrix with maximum values
    maxhr(y,:) = max_block;
end


%%  Find maximum - rth yearly max for 6min data
% Number of r values to look for
r_val = 3;

%make a year vec
yr_vec6 = year(t6.time(1)):year(t6.time(end)); 

%create matrix to house all of the block maxima
max6 = zeros(length(yr_vec6), r_val); 
%Detrend water
t6.WL_VALUE = detrend(t6.WL_VALUE);

for y = 1:length(yr_vec6)
    % Grab all of the years
    yr_ind = find(year(t6.time) == yr_vec6(y));
    temp_time = t6.time(yr_ind);
    temp_wl = t6.WL_VALUE(yr_ind);
    
    %Make sure atleast half of the dates exist
    if length(yr_ind) < 87600*.5  %525600 minutes in a year, get in 6 minute increments so use 87600
        break
    else
        % Genearte empty vector to house maximum values
        max_block = NaN(1,r_val);

        % Loop through and grab the maximum values and delete a window
        % around each maximum to ensure different tide cycles
        for m = 1:r_val
            % Grab the maximum
            [M, I] = max(temp_wl);

            % Generate a window to delete values
            if I < 720
                window = I - (I-1):1:I + 720;
            elseif length(temp_wl) - I < 720
                window = I - 72:1:length(temp_wl);
            else
                window = I-720:1:I+720;
            end
            temp_wl(window) = [];
            temp_time(window) = [];
            
            % Add the maximum value to the empty vector
            max_block(m) = M;
        end
    end
    
    % Now populate matrix with maximum values
    max6(y,:) = max_block;
end


%% Get GEV statistics from the data
% Reshape to be a single vector
maxhr = reshape(maxhr, [length(yr_vechr)*r_val, 1]);
max6 = reshape(max6, [length(yr_vec6)*r_val, 1]);

[paramEstshr, paramCIhr] = gevfit(maxhr);
[paramEsts6, paramCI6] = gevfit(max6);
%----------------Results from GEV-------------------------------
% % % kMLE = paramEsts(1);        % Shape parameter
% % % sigmaMLE = paramEsts(2);    % Scale parameter
% % % muMLE = paramEsts(3);       % Location parameter



clf

lowerBnd = 0;
xhr = maxhr;
x6 = max6;
xmaxhr = 1.1*max(xhr);
xmax6 = 1.1*max(x6);
binshr = floor(lowerBnd):.1:ceil(xmaxhr);
bins6 = floor(lowerBnd):.1:ceil(xmax6);

% plot the hist with GEV line
subplot(2,2,[1 3])
h1 = bar(binshr,histc(xhr,binshr)/length(xhr),'histc');
h1.FaceColor = [1 .8 .8];
hold on
h2 = bar(bins6,histc(x6,bins6)/length(x6),'histc');
h2.FaceColor = [.8 .8 1];
xgridhr = linspace(lowerBnd,xmaxhr,100);
xgrid6 = linspace(lowerBnd,xmax6,100);
lhr = line(xgridhr,.1*gevpdf(xgridhr,paramEstshr(1),paramEstshr(2),paramEstshr(3)));
lhr.Color = 'red';
l6 = line(xgrid6,.1*gevpdf(xgrid6,paramEsts6(1),paramEsts6(2),paramEsts6(3)));
l6.Color = 'blue';
%xlim([0 xmaxhr]);
plot_tit = sprintf('GEV - Rth Largest - %s', station_name);
title(plot_tit)
legend 

ax = gca;  % Play with the Axes 
ax.XLim = [.5 xmaxhr*1.1];


% % % Add GEV parameters to the plot
tbox1 = sprintf('\t\t\t\t\t\t Hourly\n mu = %4.2f \nsigma = %4.2f \nk = %4.2f \nr: %d',...
    paramEstshr(1),paramEstshr(2),paramEstshr(3), r_val);
text(10,0.25,tbox1)

tbox2 = sprintf('\t\t\t\t\t\t 6 min\nmu = %4.2f \nsigma = %4.2f \nk = %4.2f \nr: %d',...
    paramEsts6(1),paramEsts6(2),paramEsts6(3), r_val);
text(10,0.25,tbox2)

% Add box around the text
dim1 = [.15 .6 .1 .1];
annotation('textbox',dim1,'String',tbox1,'FitBoxToText','on');
dim2 = [.15 .4 .1 .1];
annotation('textbox',dim2,'String',tbox2,'FitBoxToText','on');




xlabel('Total Water Level [m]')
ylabel('Probability Density')
%legend('Hourly','Six-Hr Avg.','Location','NorthEast')
box on

lg1 = legend([lhr l6 h1 h2],'Hourly', '6 min', 'Hourly', '6 min');
lg1.Position = [.2 .83 .05 .05];


% Calculate the CDF - CDF will give me the probability of values 
cdfhr = 1 - gevcdf(xgridhr,paramEstshr(1),paramEstshr(2),paramEstshr(3)); % create CDF from GEV PDF
cdf6 = 1 - gevcdf(xgrid6,paramEsts6(1),paramEsts6(2),paramEsts6(3)); % create CDF from GEV PDF        
        
%% Calculate Recurrence Interval

%-------Note-----------%
%RI = 1/Probability
%Knowing CDF and thus the probability, I can calculate the Recurrence

RIhr = 1./cdfhr;
RI6 = 1./cdf6;
subplot(2,2,[2 4])
gg1 = plot(xgridhr, RIhr);
hold on
gg2 = plot(xgrid6, RI6);
ylim([0 100])
plot_tit = sprintf('Recurrence Interval - %s', station_name);
title(plot_tit)
xlabel('Total Water Level [m]')
ylabel('Time [years]')


ax = gca;
set(gca,'XMinorTick','on')  %add minor tick marks on x-axis
ax.XLim = [1 2.5];
box on 
grid on


% Generate specific values for recurrence levels

% Hourly Data
R100MLEhr = gevinv(1-1./100,paramEstshr(1),paramEstshr(2),paramEstshr(3));
R50MLEhr = gevinv(1-1./50,paramEstshr(1),paramEstshr(2),paramEstshr(3));
R25MLEhr = gevinv(1-1./25,paramEstshr(1),paramEstshr(2),paramEstshr(3));
R10MLEhr = gevinv(1-1./10,paramEstshr(1),paramEstshr(2),paramEstshr(3));
R5MLEhr = gevinv(1-1./5,paramEstshr(1),paramEstshr(2),paramEstshr(3));
R2MLEhr = gevinv(1-1./2,paramEstshr(1),paramEstshr(2),paramEstshr(3));

% Add GEV parameters to the plot
tbox = sprintf('100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLEhr, R50MLEhr, R25MLEhr, R10MLEhr, R5MLEhr, R2MLEhr);
dim = [.62 .4 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');

% Six minute data
R100MLE6 = gevinv(1-1./100,paramEsts6(1),paramEsts6(2),paramEsts6(3));
R50MLE6 = gevinv(1-1./50,paramEsts6(1),paramEsts6(2),paramEsts6(3));
R25MLE6 = gevinv(1-1./25,paramEsts6(1),paramEsts6(2),paramEsts6(3));
R10MLE6 = gevinv(1-1./10,paramEsts6(1),paramEsts6(2),paramEsts6(3));
R5MLE6 = gevinv(1-1./5,paramEsts6(1),paramEsts6(2),paramEsts6(3));
R2MLE6 = gevinv(1-1./2,paramEsts6(1),paramEsts6(2),paramEsts6(3));

% Add GEV parameters to the plot
tbox = sprintf('100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLE6, R50MLE6, R25MLE6, R10MLE6, R5MLE6, R2MLE6);
dim = [.62 .1 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');


lg2 = legend([gg1 gg2],'Hourly', '6 min');
lg2.Position = [.62 .86 .05 .05];



%%
% Save the Plot
%cd('../../Matlab_Figures/GEV/Tides/Rth/')
%cd('../../swin/GEV/10_block/')
cd('../../');
outname = sprintf('GEV_compare_hr_6',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%cd('../../../matlab/Climatology')
cd('matlab/Climatology')


