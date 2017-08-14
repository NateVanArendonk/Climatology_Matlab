%% Code to create a wind rose diagram from hourly time series data
clearvars

file_nm = 'saturna_hourly.mat'; % change this to the location of interest
station_nm = 'Saturna';  %Change this depending on station
file_loc = '../../hourly_data/gap_hourly/';
file_load = strcat(file_loc, file_nm);

%load in the data
load(file_load)
clear stn_nm file_loc file_load
%% Bin winds & break up by time

% now break the time variable up into 30 or 10 year segments depending on
% length of record

yr_vec = year(time(1)):1:year(time(end)); % create year vec

spd_thresh = 20; % establish search parameter for wind speeds


if yr_vec < 30
    sh = 5; % How much to shift (sh = shift)
    cs = 10; % Size of the chunk (cs = chunk size)
    yr_block = yr_vec(bsxfun(@plus,(1:cs),(0:sh:length(yr_vec)-cs)'));
else
    sh = 10;
    cs = 30;
    yr_block = yr_vec(bsxfun(@plus,(1:cs),(0:sh:length(yr_vec)-cs)'));    
end

% create empty matrix to house beginning and end indice of year block
% Grab the size of the year block
[row, col] = size(yr_block);

% Create empty matrix to house first and last year of block
inds = NaN(row,2);
[~, c2] = size(inds);



for r = 1:row
    for c = 1:c2
        if c == 1
            indF = find(year(time) == yr_block(r,1));
            inds(r,c) = indF(1);
        else
            indF = find(year(time) == yr_block(r,end));
            inds(r,c) = indF(end);
        
        end
    end
end
        
% Grab the yearly indice you want either as (1,1):(1,2) or (1):(5) *****Depending
% on size of the of matrix
block1 = inds(1);
block2 = inds(2);
inds_use = block1:block2;

% if a speed threshold has been established above, filter results
if exist('spd_thresh')
    % Find indices greater than 10 of the current indices
    spd_inds = find(wndspd(inds_use) >= spd_thresh);
    % Grab the correct indices of the newly found indices (indices of
    % indices)
    inds_use = inds_use(spd_inds);
end



% Text variables to add to figure, convert to strings
yr1 = year(time(block1));
yr2 = year(time(block2));

yr1 = num2str(yr1);
yr2 = num2str(yr2);



%% Plot the Wind Rose
data_type = 'NDBC';
options.nDirections = 36;  % most stations show sub-5 degree binning
%sta_num = [1 2 3 4 5];
options.vWinds = [0 5 10 15 20 25]; %Specify the wind speeds that you want to appear on the windrose
options.AngleNorth = 0;
options.AngleEast = 90;
options.labels = {'North (360°)','South (180°)','East (90°)','West (270°)'};
options.TitleString = [];
%options.axes = ax;
%inds_w = (~isnan(O.wnddir) & ~isnan(O.wndspd));
[figure_handle,count,speeds,directions,Table] = WindRose(wnddir(inds_use),wndspd(inds_use),options);
%title('Obs - ', station_nm)
%suptitle('Paine Field')




%% Save the wind rose 
if exist('spd_thresh')
    
    spd_thresh = num2str(spd_thresh);
    
    cd('../../Matlab_Figures/Windrose_thru_time')
    outname = sprintf('WindRose_%s_spdAbove_%s_%s_%s',station_nm, spd_thresh, yr1, yr2);
    hFig = gcf;
    hFig.PaperUnits = 'inches';
    hFig.PaperSize = [8.5 11];
    hFig.PaperPosition = [0 0 7 7];
    print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
    close(hFig)
    cd('../../Matlab/Climatology')
    
else    
    
    cd('../../Matlab_Figures/Windrose_thru_time')
    outname = sprintf('WindRose_%s_%s_%s',station_nm, yr1, yr2);
    hFig = gcf;
    hFig.PaperUnits = 'inches';
    hFig.PaperSize = [8.5 11];
    hFig.PaperPosition = [0 0 7 7];
    print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
    close(hFig)
    cd('../../Matlab/Climatology')

end
