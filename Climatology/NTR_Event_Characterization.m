clearvars

%first load in the data
dir_nm = '../../COOPS_tides/';                                                    
station_nm = 'seattle';
%load_file = strcat(dir_nm,station_nm,'/',station_nm,'_ntrHr');
load_file = strcat(dir_nm,station_nm,'/',station_nm,'_ntr6min');
load(load_file)
clear dir_nm load_file
%% Establish Search parameters 

% Magnitude Parameters for NTR
wl_thresh = 0.6096;
% 0.1524
% 0.3048
% 0.4572
% 0.6096
event_sep = 12;  % 6 hour window = 12; 12 hour window = 24                                                           

% Note -- NTR is in half hour increments
%% Find all Extreme NTR events

% Convert to real numbers
ntr = real(ntr);

% Find all events above the certain threshold
ntr_events = find(ntr >= wl_thresh);                                         

% Find where the break in the event vector doesn't equal 1, signifying
% different events
breaks = find(diff(ntr_events) ~= 1);   % breaks are the breaks of the events, aka indices of indices                                    
                                                                             
% Create start and stop variables for events                                                                          
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

% Change to vertical orientation - personal preference, easier for viewing
start = ntr_events(start)';
stop = ntr_events(stop)';  
bookends = [start,stop]; % Create a vector of beginning and ending events
%% Grab all the indices of events, combining events below a threshold
event_inds = cell(length(bookends),1); % create empty cell array 

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
%% Now break up the events by years

% Create a vector of years
yr_vec = year(time(1)):year(time(end));

% Preallocate
events_by_year = cell(length(yr_vec),1);

% Grab each event for each year
for yr = 1:length(yr_vec)
    for n = 1:length(event_inds)
        temp_inds = event_inds{n};
        if year(time(temp_inds(1))) == yr_vec(yr)
            events_by_year{yr,1} = [events_by_year{yr,1},event_inds(n)];
        end
    end
end

events_per_year = zeros(length(yr_vec),1);
for j = 1:length(events_per_year)
    events_per_year(j) = length(events_by_year{j,1});
end


% Calculate Duration of events from indices

% Find duration of events
duration = zeros(length(event_inds),1);

for j = 1:length(duration)
    duration(j) = length(event_inds{j,1});
end

% Convert from half hourly to units of hours 
duration = duration ./ 2;


% Calculate Total Hour above Threshold
total_hours = zeros(length(event_inds),1);
for m = 1:length(total_hours)
    total_hours(m) = length(event_inds{m,1});
end
total_hours = sum(total_hours);




%% Calculate fraction of events in winter months

% First create a vector for each year of indices 
% Preallocate
indices_by_year = cell(length(yr_vec),1);
winter_inds = zeros(length(yr_vec),2);
winter_months = [1,2,3,4,10,11,12];
% Create a vector for each year of indices
for yr = 1:length(yr_vec)
    for n = 1:events_per_year(yr)
        %temp_vals = events_per_year{yr,1}{1,n};
        indices_by_year{yr,1} = [indices_by_year{yr,1},events_by_year{yr,1}{1,n}];
    end
    % Now find winter months
    mo_inds = month(time(indices_by_year{yr,1}));
    wi_inds = find(ismember(mo_inds,winter_months));
    winter_inds(yr,1) = length(wi_inds);
    winter_inds(yr,2) = length(indices_by_year{yr,1});
end
% Calculate fraction of winter months
% First get rid of any zeros

winter_inds(any(winter_inds==0,2),:) = []; % get rid of any zeros


frac_winter = winter_inds(:,1)./winter_inds(:,2);

fprintf('\n%4.2f: Avg. Events per year\n', mean(events_per_year));
fprintf('%4.2f: Max number of events on record\n', max(events_per_year));
fprintf('%4.2f hours: Mean Duration\n', mean(duration));
fprintf('%4.2f hour [%4.2f days]: Max Duration\n', max(duration), (max(duration)/24));
fprintf('%4.2f: Percent during Oct - Apr\n', 100*(mean(frac_winter)));
fprintf('%4.2f: Total Number of Winter Hours\n',sum(winter_inds(:,1))/length(yr_vec));





%% Plot

% % % % Establish NTR threshold for plotting
% % % thresh1 = 0.1524; thresh2 = 0.3048; thresh3 = .6096; % meters
% % % %thresh1 = 0.5; thresh2 = 1.0; thresh3 = 1.5; % feet
% % % 
% % % % Preallocate
% % % th_inds1 = zeros(length(event_inds),1);
% % % th_inds2 = th_inds1;
% % % th_inds3 = th_inds1;
% % % 
% % % % Find all the events 
% % % for j = 1:length(event_inds)
% % %     temp1 = find(ntr(event_inds{j,1}) >= thresh1);
% % %     temp2 = find(ntr(event_inds{j,1}) >= thresh2);
% % %     temp3 = find(ntr(event_inds{j,1}) >= thresh3);
% % %     
% % %     th_inds1(j) = length(temp1);
% % %     th_inds2(j) = length(temp2);
% % %     th_inds3(j) = length(temp3);
% % % end
% % % 
% % % del1 = find(th_inds1 == 0);
% % % del2 = find(th_inds2 ==0);
% % % del3 = find(th_inds3 == 0);
% % % 
% % % th_inds1(del1) = [];
% % % th_inds2(del2) = [];
% % % th_inds3(del3) = [];
% % % 
% % % clear temp1 temp2 temp3 j n 
% % % 
% % %         