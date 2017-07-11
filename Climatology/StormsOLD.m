clearvars

%first load in the data
dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
file_nm = 'whidbey_hourly'; % you will have to change this variable for each station
load_file = strcat(dir_nm,file_nm);
load(load_file)
clear dir_nm file_nm load_file
wnddir = wnddir';

%% Find all of storms greater than 20 m/s and lasting 3 or more hours

wndspd20 = find(wndspd >= 20); %grab the indices of winds > 20 m/s
breaks = find(diff(wndspd20) ~= 1);  %find where the wind speeds >20 m/s indices
% are not consecutive aka the breaks in the indice vector


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

% Now create one vector of all the indices of storms 
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

actual_ind = wndspd20(storm3.ind); %actual indices of winds

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

%% Find all storms lasting greater than 6 hours 

%Now to get rid of all the less than 3 hour blocks
shortStorm = []; % this will house the indices of all of the short storms
for i = 1:length(stormFreq)
    if length(stormFreq{i}) < 6
        shortStorm(end+1) = i;
    end
end
        
stormFreq(shortStorm) = []; %Get rid of all the short storms now

% Make individual vector 
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


%% Find all storms lasting greater than greater than 12 hours 

%Now to get rid of all the less than 3 hour blocks
shortStorm = []; % this will house the indices of all of the short storms
for i = 1:length(stormFreq)
    if length(stormFreq{i}) < 12
        shortStorm(end+1) = i;
    end
end
        
stormFreq(shortStorm) = []; %Get rid of all the short storms now

% Now create one vector of all the indices of storms 
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

%% Break up Storms by Year
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

stormYear3 = stormYear3'; %make it vertical
storm3.yearBreak = stormYear3;
clear i j year_vec

% repeat for 6 hour winds
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


% Repeat for 12 hour winds
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

%% Now to find individual storm events seperated by 12 hours
       % This is for 3 hour winds
stormWindow3 = find(diff(storm3.ind) > 12);
%This tells me where all of the individual storms are that are broken up by
%12 hours

% Now to grab all the indices for each storm
for i = 1:length(stormWindow3)
    if i == 1
        window = 1:stormWindow3(i);
        actInd = storm3.ind(window);
        individualStorm{i} = actInd;
    else 
        beg = stormWindow3(i-1) + 1;
        fin = stormWindow3(i);
        actInd = storm3.ind(beg:fin);
        individualStorm{i} = actInd;
    end
end
clear beg fin i limit window actInd

individualStorm = individualStorm'; %make it a vertical cell array
%create single vector of individual storms
stormEvents = struct();
events = [];
for i = 1:length(individualStorm)
    temp = individualStorm{i};
    for j = 1:length(temp)
        events(end+1) = temp(j);
    end
end
events = events';

stormEvents.wndspd = wndspd(events);
stormEvents.wnddir = wnddir(events);
stormEvents.slp = slp(events);
stormEvents.stp = stp(events);
stormEvents.dewp = dewp(events);
stormEvents.time = time(events);
stormEvents.ind = events;
stormEvents.north = find(stormEvents.wnddir <= 11.25 | stormEvents.wnddir > 270);
stormEvents.south = find(stormEvents.wnddir > 90 & stormEvents.wnddir <= 191.25);
stormEvents.window = stormWindow3;
% Now break up the storm events by year
yr_vec = year(time(1)):year(time(end));

for i = 1:length(yr_vec)
    temp = [];
    for j = 1:length(stormEvents.ind)
        if year(stormEvents.time(j)) == yr_vec(i)
            temp(end+1) = storm3.ind(j);
        end
    end
    eventYear{i} = temp;
    clear temp
end

eventYear = eventYear';
stormEvents.yearBreak = eventYear;

storm3.events = stormEvents;


%%
%need to do the same for 6 and 12 hour winds


%% Now to find individual storm events seperated by 12 hours
       % This is for 6 hour winds
stormWindow6 = find(diff(storm6.ind) > 12);
%This tells me where all of the individual storms are that are broken up by
%12 hours

% Now to grab all the indices for each storm
for i = 1:length(stormWindow6)
    if i == 1
        window = 1:stormWindow6(i);
        actInd = storm6.ind(window);
        individualStorm{i} = actInd;
    else 
        beg = stormWindow6(i-1) + 1;
        fin = stormWindow6(i);
        actInd = storm6.ind(beg:fin);
        individualStorm{i} = actInd;
    end
end
clear beg fin i limit window actInd

individualStorm = individualStorm'; %make it a vertical cell array
%create single vector of individual storms
stormEvents = struct();
events = [];
for i = 1:length(individualStorm)
    temp = individualStorm{i};
    for j = 1:length(temp)
        events(end+1) = temp(j);
    end
end
events = events';

stormEvents.wndspd = wndspd(events);
stormEvents.wnddir = wnddir(events);
stormEvents.slp = slp(events);
stormEvents.stp = stp(events);
stormEvents.dewp = dewp(events);
stormEvents.time = time(events);
stormEvents.ind = events;
stormEvents.north = find(stormEvents.wnddir <= 11.25 | stormEvents.wnddir > 270);
stormEvents.south = find(stormEvents.wnddir > 90 & stormEvents.wnddir <= 191.25);
stormEvents.window = stormWindow6;
% Now break up the storm events by year
yr_vec = year(time(1)):year(time(end));

for i = 1:length(yr_vec)
    temp = [];
    for j = 1:length(stormEvents.ind)
        if year(stormEvents.time(j)) == yr_vec(i)
            temp(end+1) = storm6.ind(j);
        end
    end
    eventYear{i} = temp;
    clear temp
end

eventYear = eventYear';
stormEvents.yearBreak = eventYear;

storm6.events = stormEvents;





%% Create structure to house storm data
storm = struct();
storm.three = storm3;
storm.six = storm6;
storm.twelve = storm12;

clear events eventYear i j storm12 storm3 storm6 stormEvents stormFreq stormWindow stormYear12 stormYear6
clear stormYear3 yr_vec