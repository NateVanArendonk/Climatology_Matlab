%% Code to generate statistics regarding changes through time in average values
% % 
% clearvars
%file_nm = 'sentry_shoal'; % change this to the location of interest
%dir_nm = '../../hourly_data/gap_hourly/station_choice/';
% %dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
file_load = strcat(dir_nm, station_nm, '_hourly.mat');
% 
% 
% %load in the data
load(file_load)
% clear stn_nm dir_nm file_load file_nm

%% Find winds above threshold

% now break the time variable up into 20 year segments
yr_vec = year(time(1)):1:year(time(end)); % create year vec

% Find year breaks for segments
yr_len = length(yr_vec); % length of years   
num_breaks = round(yr_len/10); % dividing years up into groups of 10
yr_breaks = NaN(1, num_breaks); % create empty vector

count = year(time(1)); % create counter
for n = 1:length(yr_breaks) 
    yr_breaks(n) = count + 10;   % find the years that are 10 apart
    count = count + 10;  % increase counter
end

% now find the indices wihtin each group
group_inds = NaN(1, num_breaks);

for n = 1:length(group_inds)
    if yr_breaks(n) < year(time(end))  % if the year break is within the years on record
        temp = find(year(time) == yr_breaks(n)); % find the indices that are in the chunk of years
        group_inds(n) = temp(end);   % find the end of the current chunk
    else % otherwise if the breaks is outside of the years on record, grab the last year and do the same thing
        temp_break = year(time(end));
        temp = find(year(time) == temp_break);
        group_inds(n) = temp(end);
    end
end

% So I now have the end indices of each year

block_inds = NaN(1, num_breaks); % each of these will contain every indice within the year block above the threshold
block_inds = num2cell(block_inds);
for n = 1:length(block_inds)
    if n == 1  % first block of years
        cur_inds = 1:group_inds(1);
        %ind_crop = find(wndspd(cur_inds) >= 10); % find all the indices greater than 10 m/s of that year
        block_inds{n} = cur_inds;
    else
        start = group_inds(n-1) + 1;
        stop = group_inds(n);
        cur_inds = start:stop;
        %ind_crop = find(cur_inds > 10);
        block_inds{n} = cur_inds;
    end
end

%% Generate mean values for each decade

% Create empty vectors
spd_mn = NaN(1,length(block_inds));
slp_mn = spd_mn;
dir_mn = spd_mn;

% Populate the empty vectors
for j = 1:length(spd_mn)
    spd_mn(j) = nanmean(wndspd(block_inds{1,j}));
    slp_mn(j) = nanmean(slp(block_inds{1,j}));
    dir_mn(j) = nanmean(wnddir(block_inds{1,j}));
end
    
%% Generate Decade vector to house blocks of interest

d_block = NaN(length(yr_breaks), 2);

for m = 1:length(yr_breaks)
    if m == 1
        d_block(1,1) = year(time(1));
        d_block(1,2) = yr_breaks(1);
    else
        d_block(m,1) = yr_breaks(m-1);
        d_block(m,2) = yr_breaks(m);
    end
end

        


%% Print output to Command Window
for n = 1:length(d_block)
    fprintf('Span: %d %d - Speed: %4.2f \t\n', d_block(n,1), d_block(n,2), spd_mn(n)) 
end
fprintf('\n')

% % % for n = 1:length(d_block)
% % %     fprintf('Span: %d %d - Direction: %4.2f \t\n', d_block(n,1), d_block(n,2), dir_mn(n)) 
% % % end
% % % fprintf('\n')
% % % 
% % % for n = 1:length(d_block)
% % %     fprintf('Span: %d %d - Pressure: %4.2f \t\n', d_block(n,1), d_block(n,2), slp_mn(n)) 
% % % end
% % % fprintf('\n')