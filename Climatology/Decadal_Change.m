%% Code to generate statistics regarding changes through time in average values
% % 
%clearvars
%station_nm = 'obs_westpoint'; % change this to the location of interest
%dir_nm = '../../hourly_data/gap_hourly/station_choice/';
% %dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
file_load = strcat(dir_nm, station_nm, '_hourly.mat');
load(file_load)

% clear stn_nm dir_nm file_load file_nm

%% Find winds above threshold

% now break the time variable up into 20 year segments
yr_vec = year(time(1)):1:year(time(end)); % create year vec

% % Find year breaks for segments
yr_len = length(yr_vec); % length of years   
%num_breaks = round(yr_len/10); % dividing years up into groups of 10

% Hardwire the year breaks
yr_breaks = [1955 1965 1975 1985 1995 2005 2015];

% now find the indices wihtin each group
group_inds = NaN(1, length(yr_breaks));

for n = 1:length(group_inds)
    if yr_breaks(n) < year(time(end))  % if the year break is within the years on record
        if ismember(yr_breaks(n),yr_vec) % if the year break is part of the years on record
            temp = find(year(time) == yr_breaks(n)); % find the indices that are in the chunk of years
            group_inds(n) = temp(end);   % find the end of the current chunk
        else % otherwise populate with NaN
            group_inds(n) = NaN;
        end
    else % otherwise if the breaks is outside of the years on record, grab the last year and do the same thing
        if ismember(yr_breaks(n), yr_vec)
            temp_break = year(time(end));
            temp = find(year(time) == temp_break);
            group_inds(n) = temp(end);
        else
            group_inds(n) = NaN;
        end
    end
end

%% Grab indices of interest
% So I now have the end indices of each year that correspond to my
% predetermined year blocks

block_inds = NaN(1, length(yr_breaks)); % each of these will contain every indice within the year block 
block_inds = num2cell(block_inds);

% Loop through and grab all of the dates between bookends and add to
% block_inds
for j = 1:length(block_inds)
    st_yr = yr_breaks(j) - 10; % Establish a start year
    end_yr = yr_breaks(j);  % Establish a end year
    
    yr_inds = find(year(time) >= st_yr & year(time) <= end_yr); % Find all values within that window
    
    if length(yr_inds) < 87600 * .5 % If more than half of the data is missing
        block_inds{j} = NaN; % Don't use it
    else % Otherwise
        block_inds{j} = yr_inds; % Populate with the indices
    end
end

%% Generate mean values for each decade

% Create empty vectors
spd_mn = NaN(1,length(yr_breaks));
slp_mn = spd_mn;
dir_mn = spd_mn;

% Populate the empty vectors
for j = 1:length(spd_mn)
    if isnan(block_inds{1,j})
        spd_mn(j) = NaN;
        slp_mn(j) = NaN;
        dir_mn(j) = NaN;
    else   
        spd_mn(j) = nanmean(wndspd(block_inds{1,j}));
        slp_mn(j) = nanmean(slp(block_inds{1,j}));
        dir_mn(j) = nanmean(wnddir(block_inds{1,j}));
    end
end

%% Create a structure from data
% % data.(station_nm).lat = lat;
% % data.(station_nm).lon = lon;
% % data.(station_nm).spd_mn = spd_mn;
% % data.(station_nm).slp_mn = slp_mn;
% % data.(station_nm).dir_mn = dir_mn;


    
%Generate Decade vector to house blocks of interest

d_block = NaN(length(yr_breaks), 2);

for m = 1:length(yr_breaks)
    d_block(m,1) = yr_breaks(m)-10;
    d_block(m,2) = yr_breaks(m);
end

        


% Print output to Command Window
% % for n = 1:length(d_block)
% %     if ~isnan(spd_mn(n))
% %         fprintf('Span: %d %d - Speed: %4.2f \t\n', d_block(n,1), d_block(n,2), spd_mn(n))
% %     else
% %         fprintf('Span: %d %d - Speed: NaN\t\n', d_block(n,1), d_block(n,2))
% %     end
% % end
% % fprintf('\n')

% % for n = 1:length(d_block)
% %     if ~isnan(slp_mn(n))
% %     fprintf('Span: %d %d - Direction: %4.2f \t\n', d_block(n,1), d_block(n,2), dir_mn(n)) 
% %     else
% %         fprintf('Span: %d %d - Direction: NaN\t\n', d_block(n,1), d_block(n,2))
% %     end
% % end
% % fprintf('\n')

for n = 1:length(d_block)
    if ~isnan(dir_mn(n))
        fprintf('Span: %d %d - Pressure: %4.2f \t\n', d_block(n,1), d_block(n,2), slp_mn(n))
    else
        fprintf('Span: %d %d - Pressure: NaN\t\n', d_block(n,1), d_block(n,2))
    end
end
fprintf('\n')