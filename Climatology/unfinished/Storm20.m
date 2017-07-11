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

% storm12 houses all the info about storms lasting longer than 12 hours

% stormFreq is a vertical cell array splitting up non-consecutive wind
% events

%stormWindow is all the locations where difference between storms is 12
%hours or greater thus indicating different storm events

%stormYear3 has all the indices for each year of the record above the
%threshold, again subdivided by year


%% Storms Greater than 10 m/s
wndspd20 = find(wndspd >= 20); %grab the indices of winds > 10 m/s
breaks = find(diff(wndspd20) ~= 1);  %find where the wind speeds>10 m/s indices
% are not consecutive aka the breaks in the indice vector

%%%%%%%%%%%This code below I don't use but will keep for now
% Find consecutive values for wind aka sustained winds      
% A = find(diff(wndspd10)==1);  %find all the indices where the difference is equal to 1
% %All sustained winds that are part of one event
% B = A+1; %Because diff returns a vector 1-less than needed, I add 1 to every value in the diff vector
% C = union(A,B); % this combines the vectors with no repetitions 
% clear A B C  
% Now I need to find where within the winds > 10 m/s are
% sustained for more than 3 hours.  


%% Consecutive Storms

% For this I create a matrix and pad it with NaN's this is not the best
% method but it can be used, see the cell array below for method I prefer

% 
% breaks = find(diff(wndspd10) ~= 1);  %find where the wind speeds>10 m/s indices
% % are not consecutive aka the breaks in the indice vector
% 
% stormBlocks = NaN(length(breaks), max(diff(breaks)));  %make the matrix to house the storm data
% 
% %Now grab all of the consecutive storms and put them in a matrix   
% temp = [];
% for i = 1:length(breaks)
%     if i == 1
%         temp = 1:breaks(i);
%         for n = 1:length(temp)
%             stormBlocks(i,n) = temp(n);
%         end
%     elseif ismember(breaks(i) - 1, breaks) 
%         continue
%     elseif ~ismember(breaks(i) -1, breaks)
%         beg = breaks(i-1) + 1;
%         fin = breaks(i);
%         limit = fin - beg;
%         temp = 1:limit;
%         for n = 1:length(temp)+1
%             if n == 1
%                 stormBlocks(i,n) = beg;
%             else
%                 stormBlocks(i,n) = beg + n-1;
%             end
%         end
%     end
% end
% clear i n temp   
% 
% %Shrink the matrix to get rid of any rows that start with NaN
% na_del = find(isnan(stormBlocks(:,1)));
% stormBlocks(na_del,:) = [];
% clear na_del
% 
% %% Now I need to shrink the matrix even further to house only 3+ hour events
% [m,n] = size(stormBlocks);  % m is the number of rows, n is number of columns
% shortStorms = [];
% for i = 1:m
%     num_nan = find(isnan(stormBlocks(i,:)));
%     % so if the number of NaNs is greater than n - 3, then its shorter than
%     % 3 hours and I will delete that row
%     if length(num_nan) > n - 3
%         shortStorms(end+1) = i;
%     end
% end
% %Now delete all of the short storms
% stormBlocks(shortStorms, :) = [];
% %clean up the workspace
% clear m n shortStorms num_nan beg fin i limit


%% Find all of storms greater than 20 m/s and lasting 3 or more hours

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

actual_ind = wndspd20(storm3.ind);

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

%% Now to do the same but for storms greater than 6 hours 

%Now to get rid of all the less than 3 hour blocks
shortStorm = []; % this will house the indices of all of the short storms
for i = 1:length(stormFreq)
    if length(stormFreq{i}) < 6
        shortStorm(end+1) = i;
    end
end
        
stormFreq(shortStorm) = []; %Get rid of all the short storms now

%% Now create one vector of all the indices of storms 
storm6.ind = [];
for i = 1:length(stormFreq)
    temp = stormFreq{i};
    for j = 1:length(temp)
        storm6.ind(end+1) = temp(j);
    end
end

storm6.ind = storm6.ind'; %note that storm3.ind relates to the indices
%within the wndspd10 variable.  It is the indices of the indices of the
%wind speeds, if that makes sense.  

actual_ind = wndspd20(storm6.ind);

%Now fill the data structure with all the other info for all the storms
storm6.wndspd = wndspd(actual_ind);
storm6.wnddir = wnddir(actual_ind);
storm6.slp = slp(actual_ind);
storm6.stp = stp(actual_ind);
storm6.dewp = dewp(actual_ind);
storm6.time = time(actual_ind);
storm6.ind = actual_ind;
storm6.north = find(storm6.wnddir <= 11.25 | storm6.wnddir > 270);
storm6.south = find(storm6.wnddir > 90 & storm6.wnddir <= 191.25);



clear shortStorm i j actual_ind




%% Now to do the same but for storms greater than 12 hours 

%Now to get rid of all the less than 3 hour blocks
shortStorm = []; % this will house the indices of all of the short storms
for i = 1:length(stormFreq)
    if length(stormFreq{i}) < 12
        shortStorm(end+1) = i;
    end
end
        
stormFreq(shortStorm) = []; %Get rid of all the short storms now

%% Now create one vector of all the indices of storms 
storm12.ind = [];
for i = 1:length(stormFreq)
    temp = stormFreq{i};
    for j = 1:length(temp)
        storm12.ind(end+1) = temp(j);
    end
end

storm12.ind = storm12.ind'; %note that storm3.ind relates to the indices
%within the wndspd10 variable.  It is the indices of the indices of the
%wind speeds, if that makes sense.  

actual_ind = wndspd20(storm12.ind);

%Now fill the data structure with all the other info for all the storms
storm12.wndspd = wndspd(actual_ind);
storm12.wnddir = wnddir(actual_ind);
storm12.slp = slp(actual_ind);
storm12.stp = stp(actual_ind);
storm12.dewp = dewp(actual_ind);
storm12.time = time(actual_ind);
storm12.ind = actual_ind;
storm12.north = find(storm12.wnddir <= 11.25 | storm12.wnddir > 270);
storm12.south = find(storm12.wnddir > 90 & storm12.wnddir <= 191.25);



clear shortStorm i j actual_ind
%% Now to break the winds up by year, strating with 3 hours >

stormWindow = find(diff(storm3.ind) > 12);
%This tells me where all of the individual storms are that are broken up by
%12 hours

% Now to grab all the indices for each storm
for i = 1:length(stormWindow)
    if i == 1
        window = 1:stormWindow(i);
        actInd = storm3.ind(window);
        individualStorm{i} = actInd;
    else 
        beg = stormWindow(i-1) + 1;
        fin = stormWindow(i);
        actInd = storm3.ind(beg:fin);
        individualStorm{i} = actInd;
    end
end
clear beg fin i limit window actInd

individualStorm = individualStorm'; %make it a vertical cell array


%create single vector of individual storms
stormEvents.ind = [];
for i = 1:length(individualStorm)
    temp = individualStorm{i};
    for j = 1:length(temp)
        stormEvents.ind(end+1) = temp(j);
    end
end
        




%now I know the end point of each storm and thus the frequency over the
%whole record 

%Now i need to make a cell array of each year for winds lasting greater
%than 3 hours 
yr_vec = year(time(1)):year(time(end));

for i = 1:length(yr_vec)
    temp = [];
    for j = 1:length(storm3.time)
        if year(storm3.time(j)) == yr_vec(i)
            temp(end+1) = storm3.ind(j);
        end
    end
    stormYear3{i} = temp;
    clear temp
end

%Individual Storms
storm3.individual.ind = stormWindow;
storm3.individual.wndspd = wndspd(storm3.ind(stormWindow));
storm3.individual.wnddir = wnddir(storm3.ind(stormWindow));
storm3.individual.slp = slp(storm3.ind(stormWindow));
storm3.individual.stp = stp(storm3.ind(stormWindow));
storm3.individual.dewp = dewp(storm3.ind(stormWindow));
storm3.individual.time = time(storm3.ind(stormWindow));

stormYear3 = stormYear3'; %make it vertical
storm3.yearBreak = stormYear3;

%So now I have all the indices of each year that are above a certain
%threshold

clear i j year_vec


%% Now to break up the winds by year for winds lasting 6 hours or more


yr_vec = year(time(1)):year(time(end));

for i = 1:length(yr_vec)
    temp = [];
    for j = 1:length(storm6.time)
        if year(storm6.time(j)) == yr_vec(i)
            temp(end+1) = storm6.ind(j);
        end
    end
    stormYear6{i} = temp;
    clear temp
end

stormYear6 = stormYear6'; %make it vertical
storm6.yearBreak = stormYear6;

%So now I have all the indices of each year that are above a certain
%threshold

clear i j year_vec

 
%% Now to break up the winds by year for winds lasting 6 hours or more


yr_vec = year(time(1)):year(time(end));

for i = 1:length(yr_vec)
    temp = [];
    for j = 1:length(storm12.time)
        if year(storm12.time(j)) == yr_vec(i)
            temp(end+1) = storm12.ind(j);
        end
    end
    stormYear12{i} = temp;
    clear temp
end

stormYear12 = stormYear12'; %make it vertical
storm12.yearBreak = stormYear12;

%So now I have all the indices of each year that are above a certain
%threshold

clear i j year_vec



%% Now to make one big structure to house all of the data


storm = struct();
storm.three = storm3;
storm.six = storm6;
storm.twelve = storm12;
storm.individualStorms = stormWindow;



%clear storm12 storm6 storm3 stormWindow stormFreq stormYear12 stormYear3 stormYear6 yr_vec



