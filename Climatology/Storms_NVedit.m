clearvars

% Load in the data
dir_nm = '../../hourly_data/gap_hourly/'; 
file_nm = 'whidbey_nas_hourly'; 
load_file = strcat(dir_nm,file_nm);
load(load_file)
clear dir_nm file_nm load_file

% Establish Search parameters 
min_duration = 3; % minimum amount of time a storm can last
min_wndspd = 10; % anything less than 10 m/s I will avoid
event_sep = 12; % anything not seperated by 12 hours will be considered the same event

%% Find all of storms greater than 10 m/s and lasting 3 or more hours
%----------------10 m/s--------------
wndspd_thresh = find(wndspd >= min_wndspd); %grab the indices of winds > 10 m/s
breaks = find(diff(wndspd_thresh) ~= 1);  %find where the wind speeds >10 m/s indices
% are not consecutive aka the breaks in the index vector and thus a break
% in intense winds

% Arrays to hold start and stop indices
start = [];
stop = [];

% Populate with beginning and ending of events 
for jj = 1:length(breaks)
    if jj == 1
        start(end+1) = 1;
        stop(end+1) = breaks(jj);
    else
        start(end+1) = breaks(jj - 1) + 1;
        stop(end+1) = breaks(jj);
    end
end

% Change to vertical orientation - personal preference
start = wndspd_thresh(start)';
stop = wndspd_thresh(stop)';

% Combine the two vectors into a single variable
bookends = [start,stop];

%% Grab all the indices of events, combining events below a threshold

% Create empty cell array
event_inds = cell(length(bookends),1);

for jj = 1:length(bookends)
    if jj == 1
        event_inds{jj,1} = bookends(jj,1):bookends(jj,2); % Populate with first set of start stop indices
    else
        if abs(bookends(jj,1) - bookends(jj-1,2)) < event_sep % If the difference betwen the end of the previous event and the start of the current event are below the threshold, combine them
            temp_inds = {bookends(jj,1):bookends(jj,2)}; % Grab all of indices to be appended
            cell_pop = find(~cellfun('isempty', event_inds)); % Find all the non-empty cells
            last_pop = cell_pop(end); % Grab the last value = the last populated cell
            event_inds{last_pop,1} = [event_inds{last_pop,1},temp_inds{:}]; % combine the events, adding values to last populated cell
        else
            event_inds{jj,1} = bookends(jj,1):bookends(jj,2);
        end
    end
end

% Get rid of empty cells
inds_delete = cellfun('isempty', event_inds);
event_inds(inds_delete) = [];
clear jj last_pop inds_delete temp_inds cell_pop breaks ntr_events start stop dir_nm


%% ------------------------ OLD CODE --------------------------------------








% % % % Find all the starting and stopping indices of events
% % % for i = 1:length(breaks)    
% % %     if i == 1        
% % %         if ismember(breaks(i) + 1, breaks)    % this is the first value, if the sequential value exists in the second spot, signifying that the event is single            
% % %             beg(end+1) = breaks(i); % Same event so beg and fin are the same
% % %             fin(end+1) = breaks(i);            
% % %         else % Otherwise if the sequential value doesn't exist, such that from 1 - breaks(2) is a event, grab that window        
% % %             beg(end+1) = breaks(i);
% % %             fin(end+1) = breaks(i+1);
% % %         end  
% % %     elseif i > 1 % For all other values after the first indice
% % %         if ismember(breaks(i) + 1, breaks) % if the value 1 larger than the current index exists, we know that the current index is a stopping point, because the next value is a single event
% % %             beg(end+1) = breaks(i-1) + 1; % Grab the starting index which is one after the last stopping point
% % %             fin(end+1) = breaks(i); % end on stopping point which is current index
% % %         elseif ismember(breaks(i) - 1, breaks) % if the value 1 less than the current index exists, we know that the current value is a single event 
% % %             beg(end+1) = breaks(i); % these will be the same
% % %             fin(end+1) = breaks(i);
% % %         else %otherwise, if there is no sequential value surrounding the current index
% % %             beg(end+1) = breaks(i-1) + 1; %grab 1 value after the last stopping point
% % %             fin(end+1) = breaks(i); % Current Index is stopping point
% % %         end
% % %     end
% % % end
