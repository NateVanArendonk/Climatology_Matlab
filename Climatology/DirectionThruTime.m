%% Code to generate plots showing histograms of winds above specific threshodls through time

clearvars

%first load in the data
%dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
dir_nm = '../../';                                                         % goes back 2 directories, to the desktop directory
file_nm = '/hourly_data/bham_airport_hourly';                                   % you will have to change this variable for each station
stn_nm = 'bham_arpt';
load_file = strcat(dir_nm,file_nm);
load(load_file)
clear dir_nm file_nm load_file
wnddir = wnddir';

%% Find winds above threshold

% now break the time variable up into 20 year segments
yr_vec = year(time(1)):1:year(time(end)); % create year vec

% Find year breaks for segments
yr_len = length(yr_vec); % length of years   
num_breaks = round(yr_len/20); % dividing years up into groups of 20
yr_breaks = NaN(1, num_breaks); % create empty vector

count = year(time(1)); % create counter
for n = 1:length(yr_breaks) 
    yr_breaks(n) = count + 20;   % find the years that are 20 apart
    count = count + 20;  % increase counter
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
for n = 1:length(block_inds);
    if n == 1  % first block of years
        cur_inds = 1:group_inds(1);
        ind_crop = find(wndspd(cur_inds) >= 10); % find all the indices greater than 10 m/s of that year
        block_inds{n} = ind_crop;
    else
        start = group_inds(n-1) + 1;
        stop = group_inds(n);
        cur_inds = start:stop;
        ind_crop = find(cur_inds > 10);
        block_inds{n} = cur_inds(ind_crop);
    end
end

%% Now plot the histograms through time
year1 = year(time(1));
break1 = yr_breaks(1);
year2 = break1 + 1;
break2 = yr_breaks(2);
year3 = break2 + 1;
break3 = yr_breaks(3);
year4 = break3 + 1;
break4 = year(time(end));


figure

subplot(3,1,1)
histogram(wnddir(block_inds{1}))
xlabel('Wind Direction [degrees]')
tit = sprintf('%d - %d', year1, break1);
title(tit)


subplot(3,1,2)
histogram(wnddir(block_inds{2}))
xlabel('Wind Direction [degrees]')
tit = sprintf('%d - %d', year2, break2);
title(tit)


subplot(3,1,3)
histogram(wnddir(block_inds{3}))
xlabel('Wind Direction [degrees]')
tit = sprintf('%d - %d', year3, break4);
title(tit)


% subplot(4,1,4)
% histogram(wnddir(block_inds{4}))
% xlabel('Wind Direction [degrees]')
% tit = sprintf('%d - %d', year4, break4);
% title(tit)


%% Save the Plot 
cd('../../Matlab_Figures/Distributions/DirThruTime')
outname = sprintf('DirThruTime_%s',stn_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)
cd('../../../Matlab/Climatology')

