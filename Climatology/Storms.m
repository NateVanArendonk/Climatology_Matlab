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


%---------Recap-------------
%So I've created two structures, one that has all of the storms 





 