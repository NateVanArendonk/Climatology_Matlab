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
r_val = 10;
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
            elseif I - 72 <= 0
                window = 1:1:72 - (72 - I);
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
% Reshape to be a single vector depending on r value
maxima1 = maxima(:,1); maxima1 = maxima1(:);
maxima3 = maxima(:,1:3); maxima3 = maxima3(:);
maxima5 = maxima(:,1:5); maxima5 = maxima5(:);
maxima10 = maxima(:);
%% Run Different GEV on Data

% Rth Largest
[rparamEsts1] = gevfit_rth(maxima(:,1));
[rparamEsts3] = gevfit_rth(maxima(:,1:3));
[rparamEsts5] = gevfit_rth(maxima(:,1:5));
[rparamEsts10] = gevfit_rth(maxima(:,1:10));


% Hybrid
[hparamEsts1, hparamCI1] = gevfit(maxima1);
[hparamEsts3, hparamCI3] = gevfit(maxima3);
[hparamEsts5, hparamCI5] = gevfit(maxima5);
[hparamEsts10, hparamCI10] = gevfit(maxima10);

%----------------Results from GEV-------------------------------
% % % kMLE = paramEsts(1);        % Shape parameter
% % % sigmaMLE = paramEsts(2);    % Scale parameter
% % % muMLE = paramEsts(3);       % Location parameter
%% Set up plotting environment 
x = maxima(:);
lowerBnd = min(x) - .5;
xmax = 1.1*max(x);
bins = lowerBnd:.1:ceil(xmax); 
%% Plot the Data
% Plot histograms for the data 
clf
figure(1)
subplot(2,2,[1 3])
% Rth/Vit-Hybrid Method
h1 = bar(bins,histc(x,bins)/length(x),'histc');
h1.FaceColor = [.8 .8 .8];


% Add the Line for the estimates of the Rth largest GEV Fit
xgrid = linspace(lowerBnd,xmax,100);
lr1 = line(xgrid,.1*gevpdf(xgrid,rparamEsts1(1),rparamEsts1(2),rparamEsts1(3)));
lr3 = line(xgrid,.1*gevpdf(xgrid,rparamEsts3(1),rparamEsts3(2),rparamEsts3(3)));
lr5 = line(xgrid,.1*gevpdf(xgrid,rparamEsts5(1),rparamEsts5(2),rparamEsts5(3)));
lr10 = line(xgrid,.1*gevpdf(xgrid,rparamEsts10(1),rparamEsts10(2),rparamEsts10(3)));
lr1.Color = 'red';
lr3.Color = 'blue';
lr5.Color = 'green';
lr10.Color = 'yellow';

% Add a legend to the plot
rleg1 = legend([lr1 lr3 lr5 lr10],'r = 1','r = 3','r = 5','r = 10');
rleg1.Position = [.15 .8 .1 .1];


% Add A title
plot_tit = sprintf('Rth Largest Comparison - %s', station_name);
title(plot_tit)

% Limit Axes 
ax = gca;   
ax.XLim = [lowerBnd xmax];

% Calculate & Plot Recurrence interval

rcdf1 = 1 - gevcdf(xgrid,rparamEsts1(1),rparamEsts1(2),rparamEsts1(3)); % create CDF from GEV PDF
rcdf3 = 1 - gevcdf(xgrid,rparamEsts3(1),rparamEsts3(2),rparamEsts3(3)); % create CDF from GEV PDF      
rcdf5 = 1 - gevcdf(xgrid,rparamEsts5(1),rparamEsts5(2),rparamEsts5(3)); % create CDF from GEV PDF 
rcdf10 = 1 - gevcdf(xgrid,rparamEsts10(1),rparamEsts10(2),rparamEsts10(3)); % create CDF from GEV PDF 

% Calculate RI
RI1r = 1./rcdf1;
RI3r = 1./rcdf3;
RI5r = 1./rcdf5;
RI10r = 1./rcdf10;

subplot(2,2,[2 4])
r1 = line(xgrid, RI1r);
r1.Color = 'red';
r3 = line(xgrid, RI3r);
r3.Color = 'blue';
r5 = line(xgrid, RI5r);
r5.Color = 'green';
r10 = line(xgrid, RI10r);
r10.Color = 'yellow';

ylim([0 100])
xlim([lowerBnd xmax])
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
rleg2 = legend([r1,r3,r5,r10],'r = 1','r = 3','r = 5', 'r = 10');
rleg2.Position = [.6 .8 .1 .1];

%% Save the Plot 
cd('../../');
outname = sprintf('GEV_sensitivity_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%cd('../../../matlab/Climatology')
cd('matlab/Climatology')


%%  Hybrid Method

figure(2)
subplot(2,2,[1 3])
% Rth/Vit-Hybrid Method
h2 = bar(bins,histc(x,bins)/length(x),'histc');
h2.FaceColor = [.8 .8 .8];


% Add the Line for the estimates of the GEV Fit
xgrid = linspace(lowerBnd,xmax,100);
lh1 = line(xgrid,.1*gevpdf(xgrid,hparamEsts1(1),hparamEsts1(2),hparamEsts1(3)));
lh3 = line(xgrid,.1*gevpdf(xgrid,hparamEsts3(1),hparamEsts3(2),hparamEsts3(3)));
lh5 = line(xgrid,.1*gevpdf(xgrid,hparamEsts5(1),hparamEsts5(2),hparamEsts5(3)));
lh10 = line(xgrid,.1*gevpdf(xgrid,hparamEsts10(1),hparamEsts10(2),hparamEsts10(3)));
lh1.Color = 'red';
lh3.Color = 'blue';
lh5.Color = 'green';
lh10.Color = 'yellow';

% Add a legend to the plot
hleg1 = legend([lh1 lh3 lh5 lh10],'r = 1','r = 3','r = 5','r = 10');
hleg1.Position = [.15 .8 .1 .1];

% Add A title
plot_tit = sprintf('Hybrid Comparison - %s', station_name);
title(plot_tit)

% Limit Axes 
ax = gca;   
ax.XLim = [lowerBnd xmax];


% Calculate & Plot Recurrence interval

hcdf1 = 1 - gevcdf(xgrid,hparamEsts1(1),hparamEsts1(2),hparamEsts1(3)); % create CDF from GEV PDF
hcdf3 = 1 - gevcdf(xgrid,hparamEsts3(1),hparamEsts3(2),hparamEsts3(3)); % create CDF from GEV PDF      
hcdf5 = 1 - gevcdf(xgrid,hparamEsts5(1),hparamEsts5(2),hparamEsts5(3)); % create CDF from GEV PDF 
hcdf10 = 1 - gevcdf(xgrid,hparamEsts10(1),hparamEsts10(2),hparamEsts10(3)); % create CDF from GEV PDF 

% Calculate RI
RI1h = 1./hcdf1;
RI3h = 1./hcdf3;
RI5h = 1./hcdf5;
RI10h = 1./hcdf10;

subplot(2,2,[2 4])
h1 = line(xgrid, RI1h);
h1.Color = 'red';
h3 = line(xgrid, RI3h);
h3.Color = 'blue';
h5 = line(xgrid, RI5h);
h5.Color = 'green';
h10 = line(xgrid, RI10h);
h10.Color = 'yellow';

ylim([0 100])
xlim([lowerBnd xmax])
% Add Labels
plot_tit = sprintf('Recurrence Interval Hybrid - %s', station_name);
title(plot_tit)
xlabel('Total Water Level [m]')
ylabel('Time [years]')

% Add minor tick marks on x-axis
ax = gca;
set(gca,'XMinorTick','on') 

box on 
grid on
rleg2 = legend([h1,h3,h5,h10],'r = 1','r = 3','r = 5', 'r = 10');
rleg2.Position = [.6 .8 .1 .1];


%% Save the plot 
cd('../../');
outname = sprintf('RI_sensitivity_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%cd('../../../matlab/Climatology')
cd('matlab/Climatology')
