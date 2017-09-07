%% Compare GEV methods


clearvars

%first load in the data
dir_nm = '../../hourly_data/gap_hourly/Station_Choice/';
%dir_nm = '../../COOPS_tides/';
station_name = 'Whidbey';
station_nm = 'whidbey_nas';

load_file = strcat(dir_nm,station_nm,'_hourly');
load(load_file)
clear dir_nm file_nm load_file


%%  Find maximum yearly max
% Number of r values to look for
r_val = 3;

% make a year vec

% % % tides data
%yr_vec = year(tides.time(1)):year(tides.time(end)); 

% % % wind data
yr_vec = year(time(1)):year(time(end)); %make a year vec

%create matrix to house all of the block maxima
maxima = zeros(length(yr_vec), r_val); 

% Detrend tidal data
%tides.WL_VALUE = detrend(tides.WL_VALUE);

% Grab maxima values for either water or tides or slp
if exist('tides')
    for y = 1:length(yr_vec)
        % Grab all of the years
        yr_ind = find(year(tides.time) == yr_vec(y));
        temp_time = tides.time(yr_ind);
        temp_wl = tides.WL_VALUE(yr_ind);

        %Make sure atleast half of the dates exist
        if length(yr_ind) < 87600*.5  %525600 minutes in a year, get in 6 minute increments
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
                    window = I - 720:1:length(temp_wl);
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
        maxima(y,:) = max_block;
    end
else
    for y = 1:length(yr_vec)
        % Grab all of the years
        yr_ind = find(year(time) == yr_vec(y));
        temp_time = time(yr_ind);
        temp_spd = wndspd(yr_ind);

        %Make sure atleast half of the dates exist
        if length(yr_ind) < 8760*.5  %525600 minutes in a year, get in 6 minute increments
            break
        else
            % Genearte empty vector to house maximum values
            max_block = NaN(1,r_val);

            % Loop through and grab the maximum values and delete a window
            % around each maximum to ensure different tide cycles
            for m = 1:r_val
                % Grab the maximum
                [M, I] = max(temp_spd);

                % Generate a window to delete values, 72 hour window to
                % seperate events
                if I < 72
                    window = I - (I-1):1:I + 72;
                elseif length(temp_spd) - I < 72
                    window = I - 72:1:length(temp_spd);
                else
                    window = I-72:1:I+72;
                end
                temp_spd(window) = [];
                temp_time(window) = [];

                % Add the maximum value to the empty vector
                max_block(m) = M;
            end
        end

        % Now populate matrix with maximum values
        maxima(y,:) = max_block;
    end
end




%% Get GEV statistics about the data
% Reshape to be a single vector
maxima = reshape(maxima, [length(yr_vec)*r_val, 1]);

[paramEsts, paramCIs] = gevfit(maxima);
%----------------Results from GEV-------------------------------
% % % kMLE = paramEsts(1);        % Shape parameter
% % % sigmaMLE = paramEsts(2);    % Scale parameter
% % % muMLE = paramEsts(3);       % Location parameter



clf

lowerBnd = 0;
x = maxima;  
xmax = 1.1*max(x);
bins = floor(lowerBnd):ceil(xmax);

% plot the hist with GEV line
subplot(2,2,[1 3])
h = bar(bins,histc(x,bins)/length(x),'histc');
h.FaceColor = [.8 .8 .8];
xgrid = linspace(lowerBnd,xmax,100);
line(xgrid,gevpdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)));
xlim([lowerBnd xmax]);
plot_tit = sprintf('GEV - Rth Largest - %s', station_name);
title(plot_tit)

ax = gca;  % Play with the Axes 
ax.XLim = [8 xmax*1.1];

% % % Taken from R % % % 
% Whidbey Wind
RparamEsts(1) = -0.44580;
RparamEsts(2) = 2.212207;
RparamEsts(3) = 18.656641;

line(xgrid,gevpdf(xgrid,RparamEsts(1),RparamEsts(2),RparamEsts(3)),'Color','red');


% Add GEV parameters to the plot
tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f \nr: %d',...
    paramEsts(1),paramEsts(2),paramEsts(3), r_val);
%text(10,0.25, tbox)

% Add box around the text
dim = [.15 .6 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');



xlabel('Total Water Level [m]')
ylabel('Probability Density')
%legend('Hourly','Six-Hr Avg.','Location','NorthEast')
box on




% Calculate the CDF - CDF will give me the probability of values 
cdf = 1 - gevcdf(xgrid,paramEsts(1),paramEsts(2),paramEsts(3)); % create CDF from GEV PDF
rcdf = 1 - gevcdf(xgrid,RparamEsts(1),RparamEsts(2),RparamEsts(3)); % CDF from R - rth largest
%cdf = 1 - gevcdf(xgrid,-0.3771048, 0.1034551, 3.4687437); % create CDF from GEV PDF


% ----------Notes-----------
% - PDF sums to 1, represents probability density
% - CDF is the cumulative PDF, represents probability
% - CDF is the probability of the random variable being less than X
        
        
%% Calculate Recurrence Interval

%-------Note-----------%
%RI = 1/Probability
%Knowing CDF and thus the probability, I can calculate the Recurrence

RI = 1./cdf;
subplot(2,2,[2 4])
plot(xgrid, RI)
ylim([0 100])
plot_tit = sprintf('Recurrence Interval - %s', station_name);
title(plot_tit)
xlabel('Total Water Level [m]')
ylabel('Time [years]')


ax = gca;
set(gca,'XMinorTick','on')  %add minor tick marks on x-axis

box on 
grid on


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
%text(6,60, tbox)

dim = [.62 .3 .3 .3];
annotation('textbox',dim,'String',tbox,'FitBoxToText','on');


%%
% Save the Plot
%cd('../../Matlab_Figures/GEV/Tides/Rth/')
cd('../../swin/GEV/10_block/')

outname = sprintf('GEV10_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

cd('../../../matlab/Climatology')



