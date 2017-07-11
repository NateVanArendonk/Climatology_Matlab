%% Code to 

clearvars

%first load in the data
dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
file_nm = 'whidbey_hourly'; % you will have to change this variable for each station
load_file = strcat(dir_nm,file_nm);
load(load_file)
clear dir_nm file_nm load_file
wnddir = wnddir';

% Notes 
% storm3 houses all the info about storms lasting longer than 3 hours

% storm6 houses all the info about storms lasting longer than 6 hours

% stormFreq is a vertical cell array splitting up non-consecutive wind
% events

%stormWindow is all the locations where difference between storms is 12
%hours or greater thus indicating different storm events

%stormYear has all the indices for each year of the record


%% Storms Greater than 10 m/s
wndspd10 = find(wndspd >= 10); %grab the indices of winds > 10 m/s
breaks = find(diff(wndspd10) ~= 1);  %find where the wind speeds>10 m/s indices
% are not consecutive aka the breaks in the indice vector

%% Find all of storms greater than 10 m/s and lasting 3 or more hours

%I know the indices of all the winds greater than 10 m/s and thus the
%breaks in the wind where unsustained winds of 10 m/s occur. I create a new
%variable called stormFreq to house all of the consecutive runs of strong
%winds

for i = 1:length(breaks)
    if i == 1
        stormFreq{i} = 1:breaks(i);
    elseif ismember(breaks(i) - 1, breaks) 
        continue
    elseif ~ismember(breaks(i) -1, breaks)
        beg = breaks(i-1) + 1;
        fin = breaks(i);
        limit = fin - beg;
        stormFreq{i} = beg:fin;
    end
end
clear beg fin i limit 

stormFreq = stormFreq(~cellfun('isempty',stormFreq)); % get rid of any empty cells
stormFreq = stormFreq'; %make it a vertical cell array

%Now to get rid of all the less than 3 hour blocks
shortStorm = []; % this will house the indices of all of the short storms
for i = 1:length(stormFreq)
    if length(stormFreq{i}) < 3
        shortStorm(end+1) = i;
    end
end
        
stormFreq(shortStorm) = []; %Get rid of all the short storms now

%% Now create one vector of all the indices of storms 
storm3.ind = [];
for i = 1:length(stormFreq)
    temp = stormFreq{i};
    for j = 1:length(temp)
        storm3.ind(end+1) = temp(j);
    end
end
storm3.ind = storm3.ind'; %note that storm3.ind relates to the indices 
%within the wndspd10 variable.  It is the indices of the indices of the
%wind speeds, if that makes sense.  

actual_ind = wndspd10(storm3.ind);

%Now fill the data structure with all the other info for all the storms
storm3.wndspd = wndspd(actual_ind);
storm3.wnddir = wnddir(actual_ind);
storm3.slp = slp(actual_ind);
storm3.stp = stp(actual_ind);
storm3.dewp = dewp(actual_ind);
storm3.time = time(actual_ind);
storm3.ind = actual_ind;
storm3.north = find(storm3.wnddir <= 11.25 | storm3.wnddir > 270);
storm3.south = find(storm3.wnddir > 90 & storm3.wnddir <= 191.25);

clear shortStorm i j actual_ind

%% Now I need to define each event such that anything less than a 12 hour gap 
% is considered the same storm

stormWindow = find(diff(storm3.ind) > 12);
%now I know the end point of each storm and thus the frequency over the
%whole record 

%Now i need to make a cell array of each year
yr_vec = year(time(1)):year(time(end));

for i = 1:length(yr_vec)
    temp = [];
    for j = 1:length(storm3.time)
        if year(storm3.time(j)) == yr_vec(i)
            temp(end+1) = storm3.ind(j);
        end
    end
    stormYear{i} = temp;
    clear temp
end

stormYear = stormYear'; %make it vertical

%So now I have all the indices of each year that are above a certain
%threshold
