%% Rth largest GEV


clearvars

%first load in the data
dir_nm = '../../COOPS_tides/';
%dir_nm = '../../hourly_data/gap_hourly/Station_Choice/';
station_name = 'Seattle';
station_nm = 'seattle';

load_file = strcat(dir_nm,station_nm,'/',station_nm,'_hrV');
load(load_file)
clear dir_nm file_nm load_file

%%
r_val = 3;
%make a year vec
yr_vec = year(tides.time(1)):year(tides.time(end)); 

%create matrix to house all of the block maxima
maxima = zeros(length(yr_vec), r_val); 
for y = 1:length(yr_vec)
    % Grab all of the years
    yr_ind = find(year(tides.time) == yr_vec(y));
    temp_time = tides.time(yr_ind);
    temp_wl = tides.WL_VALUE(yr_ind);


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
    maxima(y,:) = max_block;
end   
%% Get GEV statistics about the data
% Reshape to be a single vector
maxima_vec = reshape(maxima, [length(yr_vec)*r_val, 1]);

[paramEstsblock, paramCIs] = gevfit(maxima(:,1));
[paramEstsvit, paramCIs] = gevfit(maxima(:));
[paramEstsrth] = gevfit_rth(maxima(:,1:r_val));
%----------------Results from GEV-------------------------------
% % % kMLE = paramEsts(1);        % Shape parameter
% % % sigmaMLE = paramEsts(2);    % Scale parameter
% % % muMLE = paramEsts(3);       % Location parameter
%% Preliminary Plotting Data
lowerBnd = 2.5;
x = maxima_vec;
xmax = 1.1*max(x);
bins = lowerBnd:.1:ceil(xmax); 
%% Plot the Data
% Plot histograms for the data 
clf
figure(1)
h1 = bar(bins,histc(x,bins)/length(x),'histc');
h1.FaceColor = [.8 .8 .8];
hold on
h2 = bar(bins,histc(maxima(:,1),bins)/length(maxima),'histc');
h2.FaceColor = [.8 .8 1];


% Add the Line for the estimates of the GEV Fit
xgrid = linspace(lowerBnd,xmax,100);
lb = line(xgrid,.1*gevpdf(xgrid,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3)));
lr = line(xgrid,.1*gevpdf(xgrid,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3)));
lv = line(xgrid,.1*gevpdf(xgrid,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3)));
lb.Color = 'red';
lr.Color = 'blue';
lv.Color = 'green';

% Add a legend to the plot
legend([lb lr lv h1 h2],'Block','Rth','Vit','Rth','Block');

% Add A title
plot_tit = sprintf('GEV Comparison - %s', station_name);
title(plot_tit)

% Limit Axes 
ax = gca;   
ax.XLim = [2.6 4];


% % % % % Add GEV parameters to the plot % % % % % %
% Block Maxima
tbox = sprintf('\t\t\t\t\t\tBlock\nmu = %4.2f \nsigma = %4.2f \nk = %4.2f \nr: %d',...
    paramEstsblock(1),paramEstsblock(2),paramEstsblock(3), 1);
dim = [.18 .6 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');
% Rth Largest
tbox2 = sprintf('\t\t\t\t\t\tRth\nmu = %4.2f \nsigma = %4.2f \nk = %4.2f \nr: %d',...
    paramEstsrth(1),paramEstsrth(2),paramEstsrth(3), r_val);
dim = [.18 .4 .3 .3];
annotation('textbox',dim,'String',tbox2,'FitBoxToText','on');
% Vitousik/Hybrid
tbox3 = sprintf('\t\t\t\t\t\tVit\nmu = %4.2f \nsigma = %4.2f \nk = %4.2f \nr: %d',...
    paramEstsvit(1),paramEstsvit(2),paramEstsvit(3), r_val);
dim = [.18 .2 .3 .3];
annotation('textbox',dim,'String',tbox3,'FitBoxToText','on');

% Label Axes
xlabel('Total Water Level [m]')
ylabel('Probability Density')
box on


%% Save the plot 
cd('../../');
outname = sprintf('GEV_compareMethods_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%cd('../../../matlab/Climatology')
cd('matlab/Climatology')

%% Calculate Recurrence Interval


cdfblock = 1 - gevcdf(xgrid,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3)); % create CDF from GEV PDF
cdfrth = 1 - gevcdf(xgrid,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3)); % create CDF from GEV PDF      
cdfvit = 1 - gevcdf(xgrid,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3)); % create CDF from GEV PDF  
%-------Note-----------%
%RI = 1/Probability
%Knowing CDF and thus the probability, I can calculate the Recurrence
figure(2)
RIblock = 1./cdfblock;
RIrth = 1./cdfrth;
RIvit = 1./cdfvit;
%subplot(2,2,[2 4])
rcb = line(xgrid, RIblock);
rcb.Color = 'red';
rcr = line(xgrid, RIrth);
rcr.Color = 'blue';
rcv = line(xgrid, RIvit);
rcv.Color = 'green';



ylim([0 100])
xlim([2.8 4.2])
% Add Labels
plot_tit = sprintf('Recurrence Interval Comparison - %s', station_name);
title(plot_tit)
xlabel('Total Water Level [m]')
ylabel('Time [years]')

% Add minor tick marks on x-axis
ax = gca;
set(gca,'XMinorTick','on') 

box on 
grid on
legend([rcb,rcr,rcv],'Block','Rth','Vit')


% Generate RI Estimates
% Block
R100MLEblock = gevinv(1-1./100,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3));
R50MLEblock = gevinv(1-1./50,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3));
R25MLEblock = gevinv(1-1./25,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3));
R10MLEblock = gevinv(1-1./10,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3));
R5MLEblock = gevinv(1-1./5,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3));
R2MLEblock = gevinv(1-1./2,paramEstsblock(1),paramEstsblock(2),paramEstsblock(3));
% Rth
R100MLErth = gevinv(1-1./100,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3));
R50MLErth = gevinv(1-1./50,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3));
R25MLErth = gevinv(1-1./25,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3));
R10MLErth = gevinv(1-1./10,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3));
R5MLErth = gevinv(1-1./5,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3));
R2MLErth = gevinv(1-1./2,paramEstsrth(1),paramEstsrth(2),paramEstsrth(3));
% Vit/Hybrid
R100MLEvit = gevinv(1-1./100,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3));
R50MLEvit = gevinv(1-1./50,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3));
R25MLEvit = gevinv(1-1./25,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3));
R10MLEvit = gevinv(1-1./10,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3));
R5MLEvit = gevinv(1-1./5,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3));
R2MLEvit = gevinv(1-1./2,paramEstsvit(1),paramEstsvit(2),paramEstsvit(3));

% Add GEV parameters to the plot
tboxb = sprintf('\t\t\t\t\t\t\tBlock\n 100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLEblock, R50MLEblock, R25MLEblock, R10MLEblock, R5MLEblock, R2MLEblock);
dim = [.4 .54 .3 .3];
annotation('textbox',dim,'String',tboxb,'FitBoxToText','on');

tboxr = sprintf('\t\t\t\t\t\t\tRth\n 100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLErth, R50MLErth, R25MLErth, R10MLErth, R5MLErth, R2MLErth);
dim = [.2 .54 .3 .3];
annotation('textbox',dim,'String',tboxr,'FitBoxToText','on');

tboxv = sprintf('\t\t\t\t\t\t\tVit\n 100 yr: %4.2f m\n50 yr: %4.2f m\n25 yr: %4.2f m\n10 yr: %4.2f m\n5 yr: %4.2f m\n2 yr: %4.2f m'...
    ,R100MLEvit, R50MLEvit, R25MLEvit, R10MLEvit, R5MLEvit, R2MLEvit);
dim = [.3 .25 .3 .3];
annotation('textbox',dim,'String',tboxv,'FitBoxToText','on');

%% Save the plot
cd('../../');
outname = sprintf('RI_compareMethods_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%cd('../../../matlab/Climatology')
cd('matlab/Climatology')
