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



%%   HERE IS THE OLD COPY OF THE STORM STRUCTURE 
clearvars

%first load in the data
dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
file_nm = 'whidbey_hourly'; % you will have to change this variable for each station
load_file = strcat(dir_nm,file_nm);
load(load_file)
clear dir_nm file_nm load_file
wnddir = wnddir';

%% Establish Search parameters 
min_duration = 3; % minimum amount of time a storm can last
min_wndspd = 10; % anything less than 10 m/s I will avoid
min_seperation = 12; % anything not seperated by 12 hours will be considered the same event




%% Find all of storms greater than 10 m/s and lasting 3 or more hours
%----------------10 m/s--------------
wndspd10 = find(wndspd >= min_wndspd); %grab the indices of winds > 20 m/s
breaks = find(diff(wndspd10) ~= 1);  %find where the wind speeds >10 m/s indices
% are not consecutive aka the breaks in the index vector and thus a break
% in intense winds


% This takes all the locations of breaks and creates vectors of indices
% that correspond to storms
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
    if length(stormFreq{i}) < min_duration
        shortStorm(end+1) = i;
    end
end
        
stormFreq(shortStorm) = []; %Get rid of all the short storms now

% Now create one vector of all the indices of storms 
ind = [];
for i = 1:length(stormFreq)
    temp = stormFreq{i}; % generate temporary cell array 
    for j = 1:length(temp)
        ind(end+1) = temp(j); %append values in cell array to the structure
    end
end

ind = ind'; %note that storm.ind relates to the indices
%within the wndspd10 variable.  It is the indices of the indices of the
%wind speeds, if that makes sense.  

actual_ind = wndspd10(ind); %actual indices of winds

%Now fill the data structure with all the other info for all the storms
storm.totalStorms.wndspd = wndspd(actual_ind);
storm.totalStorms.wnddir = wnddir(actual_ind);
storm.totalStorms.slp = slp(actual_ind);
storm.totalStorms.stp = stp(actual_ind);
storm.totalStorms.dewp = dewp(actual_ind);
storm.totalStorms.time = time(actual_ind);
storm.totalStorms.ind = actual_ind;
storm.totalStorms.north = find(storm.totalStorms.wnddir <= 11.25 | storm.totalStorms.wnddir > 270);
storm.totalStorms.south = find(storm.totalStorms.wnddir > 90 & storm.totalStorms.wnddir <= 191.25);




%------------Recap-----------------
%So far I have generated a structure that houses all of the storms that
%lasted atleast 3 hours.  

clear shortStorm i j actual_ind


%% Break up Storms by Year
%So now within the structure, I want to break up the winds by year
yr_vec = year(time(1)):year(time(end));

for i = 1:length(yr_vec)    
    yr_inds = find(year(storm.totalStorms.time) == yr_vec(i));
    stormYear{i} = storm.totalStorms.ind(yr_inds);
end

%Note, earliest date for data is (eg. 2016) the first row, oldest (1945) is at
%the bottom

stormYear = stormYear'; %make it vertical
storm.yearBreak = stormYear;
clear i j year_vec 

%-----------Recap-------------------
%I have created a structure that houses all of the storms lasting 3 hours
%Then I created a variable within the structure that houses all of the
%storms and splits them up by year.  This shows how many hours per year
%that winds were above a certain threshold.  

%% Now to find individual storm events seperated by 12 hours within each year

yr_rev = length(stormYear):-1:1; %creates a year vector going from present to past
yr_nm_vec = []; %create empty vector to house yearly names for structure

for i = 1:length(yr_rev)
    cur_yr = strcat('a',num2str(yr_vec(yr_rev((i))))); % generate field name, must start with letter
    %stormByYear.(cur_yr) = [];  % creates a structure that has every year
    yr_nm_vec{i} = cur_yr; % create a yearly number vector to use for iteration
end
yr_nm_vec = yr_nm_vec'; %make it vertical, because I like it better vertical




%--------Now create structure to house all the storms by year--------------
    

% What I will do is go in and find out where the difference between indices
% of storms is greater than or equal to the minimum threshold I set for
% defining specific storm events.  Then, any events that diffs less than 12
% will be considered the same event, and any events that have seperation
% greater than 12 will be considered different.  

total = 0; %this will be used later, it is the total number of storms on record

actual_inds = [];


for i = 1:length(storm.yearBreak)  % all of the storms by year, so it is the number of total years on record
    yr_storms = [];
    block = storm.yearBreak{i};  %grab the specific block of storms for that year
    twelve = find(diff(block) >= min_seperation);  %find all the locations where diff >= 12 indicating individual storms
    if length(twelve) > 1;
        for n = 1:length(twelve) %iterate through those breaks
            if n == 1
            	yr_storms{n} = block(1:twelve(n)); % Grab actual indics of storm
                temp_block = block(1:twelve(n));
                for jj = 1:length(temp_block)
                    actual_inds(end+1) = temp_block(jj);
                end
                total = total + 1;
            else
                yr_storms{n,1} = block(twelve(n-1) + 1:twelve(n));
                total = total + 1;
                temp_block = block(twelve(n-1) + 1:twelve(n));
                for jj = 1:length(temp_block)
                    actual_inds(end+1) = temp_block(jj);
                end
            end
        end
        yr_storms = yr_storms';  
        yr_nm = yr_nm_vec{i};
        stormByYear.(yr_nm) = cell2struct(yr_storms, yr_nm); % add the storms to structure
    else   % In case there are no breaks in the storms meaning a single event
         for z = 1:length(block)
             yr_storms{z} = block(z);
             actual_inds(end+1) = block(z);
         end
        yr_nm = yr_nm_vec{i};
        stormByYear.(yr_nm).singleEvent = cell2struct(yr_storms, yr_nm); %make that single event
    end
    
end
storm.stormByYear = stormByYear;
clear block breaks cur_yr i n stormFreq stormYear stormByYear twelve yr_inds yr_nm yr_rev yr_storms yr_vec z
 


% So what I have done is created a storm structure that has each storm
% broken up by year, and then within each year, I break up the storms by
% events seperated by 12 hours.  

%% Now to make one big Storm Structure

actual_inds = actual_inds';
inds = actual_inds;
clear actual_inds

Storm.wndspd = wndspd(inds);
Storm.wnddir = wnddir(inds);
Storm.slp = slp(inds);
Storm.stp = stp(inds);
Storm.dewp = dewp(inds);
Storm.time = time(inds);

clear airtemp dewp ind inds jj min_duration min_seperation min_wndspd
clear slp stp temp temp_block time total wnddir wndspd10 yr_nm_vec wndspd

%Directional Component to the storms
Storm.north = find(Storm.wnddir <= 11.25 | Storm.wnddir > 270);
Storm.south = find(Storm.wnddir > 90 & Storm.wnddir <= 191.25);




%% Code that works but is not useful right now
% % %% Make a Master Structure
% % storm = struct();
% % 
% % storm.all.events = events;                                                     % Every single event for that station
% % 
% % 
% % %% Refine to grab events lasting 6 hrs or more
% % beg = beg_master;                                                          % Reinitialize vectors of storms
% % fin = fin_master;
% % beg_del = [];                                                              % Empty vector to house values to be deleted
% % fin_del = [];                                                              % Empty vector to house values to be deleted
% % 
% % for i = 1:length(beg)                                                      % For every value in events
% %     if abs(beg(i) - fin(i)) < 6                                            % If the difference between beginning and end is less than 6
% %         beg_del(end+1) = i;                                                % Grab indice to delete
% %         fin_del(end+1) = i;                                                % Grab indice to delete
% %     end
% % end
% % 
% % beg(beg_del) = [];                                                         % Delete the cells that need to be deleted
% % fin(fin_del) = [];                        
% % 
% % event6 = [beg, fin];                                                       % Create a 6 hour event variable
% % 
% % 
% % %% Refine to grab events lasting 12 hrs or more
% % beg = beg_master;                                                          % Reinitialize vectors of storms
% % fin = fin_master;
% % beg_del = [];                                                              % Empty vector to house values to be deleted
% % fin_del = [];                                                              % Empty vector to house values to be deleted
% % 
% % for i = 1:length(beg)                                                      % For every value in events
% %     if abs(beg(i) - fin(i)) < 12                                           % If the difference between beginning and end is less than 12
% %         beg_del(end+1) = i;                                                % Grab indice to delete
% %         fin_del(end+1) = i;                                                % Grab indice to delete
% %     end
% % end
% % 
% % beg(beg_del) = [];                                                         % Delete the cells that need to be deleted
% % fin(fin_del) = [];                        
% % 
% % event12 = [beg, fin];                                                       % Create a 12 hour event variable
% % 
% % 
% % %% Refine to grab events lasting 24 hrs or more
% % beg = beg_master;                                                          % Reinitialize vectors of storms
% % fin = fin_master;
% % beg_del = [];                                                              % Empty vector to house values to be deleted
% % fin_del = [];                                                              % Empty vector to house values to be deleted
% % 
% % for i = 1:length(beg)                                                      % For every value in events
% %     if abs(beg(i) - fin(i)) < 24                                           % If the difference between beginning and end is less than 24
% %         beg_del(end+1) = i;                                                % Grab indice to delete
% %         fin_del(end+1) = i;                                                % Grab indice to delete
% %     end
% % end
% % 
% % beg(beg_del) = [];                                                         % Delete the cells that need to be deleted
% % fin(fin_del) = [];                        
% % 
% % event24 = [beg, fin];     
% % 
% % %% Refine to grab events lasting 36 hrs or more
% % beg = beg_master;                                                          % Reinitialize vectors of storms
% % fin = fin_master;
% % beg_del = [];                                                              % Empty vector to house values to be deleted
% % fin_del = [];                                                              % Empty vector to house values to be deleted
% % 
% % for i = 1:length(beg)                                                      % For every value in events
% %     if abs(beg(i) - fin(i)) < 36                                           % If the difference between beginning and end is less than 36
% %         beg_del(end+1) = i;                                                % Grab indice to delete
% %         fin_del(end+1) = i;                                                % Grab indice to delete
% %     end
% % end
% % 
% % beg(beg_del) = [];                                                         % Delete the cells that need to be deleted
% % fin(fin_del) = [];                        
% % 
% % event36 = [beg, fin];     
% % 
% % %% Refine to grab events lasting 48 hrs or more
% % beg = beg_master;                                                          % Reinitialize vectors of storms
% % fin = fin_master;
% % beg_del = [];                                                              % Empty vector to house values to be deleted
% % fin_del = [];                                                              % Empty vector to house values to be deleted
% % 
% % for i = 1:length(beg)                                                      % For every value in events
% %     if abs(beg(i) - fin(i)) < 48                                           % If the difference between beginning and end is less than 48
% %         beg_del(end+1) = i;                                                % Grab indice to delete
% %         fin_del(end+1) = i;                                                % Grab indice to delete
% %     end
% % end
% % 
% % beg(beg_del) = [];                                                         % Delete the cells that need to be deleted
% % fin(fin_del) = [];                        
% % 
% % event48 = [beg, fin]; 
% % 
% % clear beg beg_del fin fin del i 
% % 
% % %% Refine By Direction of Wind
% % 
% % south_inds = find(wnddir(beg_master) >= south_wind(1)...                   % Find all the locations of south winds from the storms
% %     & wnddir(beg_master) <= south_wind(2));
% % 
% % north_inds = find(wnddir(beg_master) <= north_wind(1)...                   % Find all the locations of north winds from the storms
% %     | wnddir(beg_master) >= north_wind(2));
% % 
% % west_inds = find(wnddir(beg_master) >= west_wind(1)...                     % Find all the locations of west winds from the storms
% %     & wnddir(beg_master) <= west_wind(2));
% % 
% % %---------Note-----------
% % % The values for south_inds, north_inds and west_inds correspond to indice
% % % values in beg_master, so to grab the true indicies, I will have to take
% % % the values of beg_master of the north_inds for example.  This is done
% % % below
% % 
% % south_inds = beg_master(south_inds);
% % north_inds = beg_master(north_inds);
% % west_inds = beg_master(west_inds);
% % 
% % % Now knowing all the locations of specific winds for every storm I will
% % % add find which ones correspond to storms of specific lengths that I found
% % % earlier.  
% % 
% % % Start with all events, this is basically done for me
% % storm.all.south = south_inds;
% % storm.all.north = north_inds;
% % storm.all.west = west_inds;
% % 
% % % Now for 6 hour events
% % tempS = ismember(south_inds, event6(1));
% % tempN = ismember(north_inds, event6(1));
% % tempW = ismember(north_inds, event6(1));








 