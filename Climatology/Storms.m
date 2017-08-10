

%first load in the data
% dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
% dir_nm = '../../hourly_data/';                                                         % goes back 2 directories, to the desktop directory
% file_nm = 'whidbey_nas';                                   % you will have to change this variable for each station
% load_file = strcat(dir_nm,file_nm, '_hourly');
% load(load_file)
% clear dir_nm file_nm load_file


% If runnining multiple
load_file = strcat(dir_nm,file_nm);
load(load_file)


wnddir = wnddir';



%% Establish Search parameters 

% Magnitude Parameters for Wind Speeds
min_duration = 3;                                                          % minimum amount of time a storm can last
min_wndspd = 10;                                                           % anything less than 10 m/s I will avoid
event_sep = 3;                                                             % anything that is seperated by 3 hours is considered the same event

% Wind Direction Parameters
south_wind = [100 260];
north_wind = [80 280];
west_wind = [210 330];
%% Find all of storms greater than 10 m/s and lasting 3 or more hours
%----------------10 m/s--------------

wndspd10 = find(wndspd >= min_wndspd);                                     %grab the indices of winds > 10 m/s

breaks = find(diff(wndspd10) ~= 1);                                        %find where the wind speeds >10 m/s indices
                                                                           % are not consecutive aka the breaks in the index vector and thus a break
                                                                           % in intense winds

beg = [];                                                                  % Vector to contain beginning of storms
fin = [];                                                                  % Vector to contain all the end locations of storms

% Find all the starting and stopping indices of events
for i = 1:length(breaks)    
    if i == 1        
        if ismember(breaks(i) + 1, breaks)                                 % this is the first value, if the sequential value exists in the second spot, signifying that the event is single            
            beg(end+1) = breaks(i);                                        % Same event so beg and fin are the same
            fin(end+1) = breaks(i);            
        else                                                               % Otherwise if the sequential value doesn't exist, such that from 1 - breaks(2) is a event, grab that window        
            beg(end+1) = breaks(i);
            fin(end+1) = breaks(i+1);
        end  
    elseif i > 1                                                           % For all other values after the first indice
        if ismember(breaks(i) + 1, breaks)                                 % if the value 1 larger than the current index exists, we know that the current index is a stopping point, because the next value is a single event
            beg(end+1) = breaks(i-1) + 1;                                  % Grab the starting index which is one after the last stopping point
            fin(end+1) = breaks(i);                                        % end on stopping point which is current index
        elseif ismember(breaks(i) - 1, breaks)                             % if the value 1 less than the current index exists, we know that the current value is a single event 
            beg(end+1) = breaks(i);                                        % these will be the same
            fin(end+1) = breaks(i);
        else                                                               %otherwise, if there is no sequential value surrounding the current index
            beg(end+1) = breaks(i-1) + 1;                                  %grab 1 value after the last stopping point
            fin(end+1) = breaks(i);                                        % Current Index is stopping point
        end
    end
end

% Change to vertical orientation
beg = beg';
fin = fin';

% Grab actual indices
beg = wndspd10(beg);
fin = wndspd10(fin);

beg_master = beg;                                                          % These will be unedited vectors that I will use to reinitialize  
fin_master = fin;                                                          % the beg and fin vector each time I search new parameters

%-------------Recap------------------
% I have generated 2 lists of events corresponding to times when winds are
% greater than 10m/s and grabbed the starting and stopping points of each
% event.  

% Now I need to go through these events and combine any start and stop
% locations that are closer than a specific threshold and get rid of any
% events that don't last more than a specific threshold.  

%% Combine any events that are within a specific threshold of time

% Threshold was established at the beginning of code
                                                        
beg_del = [];                                                              % Empty vector to house values to be deleted
fin_del = [];                                                              % Empty vector to house values to be deleted

% Loop and combine
for i = 2:length(beg)                                                      % For every starting point, starting at 2 because the first starting point is overlooked       
    if abs(beg(i) - fin(i-1)) <= event_sep                                 % If the absolute value of the ith beginning minus the jth end is less than or equal to 3
        beg_del(end+1) = i;                                                % Indice in beg to be deleted                    
        fin_del(end+1) = i-1;                                              % Indice in fin to be deleted                  
    end
end

beg(beg_del) = [];                                                         % Delete the cells that need to be deleted
fin(fin_del) = [];                                                         % Delete the cells that need to be deleted

events = [beg,fin];                                                        % Generate a 2 column matrix of beginning and ends of storm events


%% Remove any events that don't last for a specific duration

% Threshold was established at the beginning of the code

beg_del = [];                                                              % Empty vector to house values to be deleted
fin_del = [];                                                              % Empty vector to house values to be deleted

for i = 1:length(events)                                                   % For every value in events
    if abs(beg(i) - fin(i)) < 3                                            % If the difference between beginning and end is less than 3
        beg_del(end+1) = i;                                                % Grab indice to delete
        fin_del(end+1) = i;                                                % Grab indice to delete
    end
end

beg(beg_del) = [];                                                         % Delete the cells that need to be deleted
fin(fin_del) = [];                                                         % Delete the cells that need to be deleted

storm = [beg,fin];                                                         % Generate a 2 column matrix of beginning and ends of storm events

clear breaks i beg beg_del fin fin_del i 


%% Begin making the master 'structure' of the storm events

% First Generate some parameters to go for each storm event such as
% duration, max winds, min winds, max pressure, etc.  


% Calculate the duration of the storm                                      % Use {} when accessing and writting data to a cell FYI
for i = 1:length(storm)
    storm(i,3) = abs(storm(i,1) - storm(i,2));
end
    
% Calculate max wind speed during storm
for i = 1:length(storm)                    
    storm(i,4) = max(wndspd(storm(i,1):storm(i,2)));                       
end

% Calculate min wind speed during storm
for i = 1:length(storm)                    
    storm(i,5) = min(wndspd(storm(i,1):storm(i,2)));                       
end

% Calculate the mean wind speed during storm
for i = 1:length(storm)                    
    storm(i,6) = mean(wndspd(storm(i,1):storm(i,2)));                       
end

% Calculate the variance in speed during the storm
for i = 1:length(storm)                    
    storm(i,7) = var(wndspd(storm(i,1):storm(i,2)));                       
end
% Calculate the max pressure during storm
for i = 1:length(storm)                    
    storm(i,8) = max(slp(storm(i,1):storm(i,2)));                          
end

% Calculate the min pressure during storm
for i = 1:length(storm)                    
    storm(i,9) = min(slp(storm(i,1):storm(i,2)));                          
end

% Calculate the mean pressure during the storm
for i = 1:length(storm)                    
    storm(i,10) = mean(slp(storm(i,1):storm(i,2)));                        
end

% Calculate the variance in pressure during the storm
for i = 1:length(storm)                    
    storm(i,11) = min(slp(storm(i,1):storm(i,2)));                         
end

% Calculate the mean wind direction during the storm
for i = 1:length(storm)                                                   
    storm(i,12) = mean(wnddir(storm(i,1):storm(i,2)));
end

% Calculate the mode of the wind direction, dominant wind direction
for i = 1:length(storm)
    storm(i,13) = mode(wnddir(storm(i,1):storm(i,2)));
end

%%

storm = num2cell(storm);                                                   % Converts double array to cell array to incorporate text


% Determine the season of the storm
% Spring: March 1 - May 31
% Summer: June 1 - Aug. 31
% Fall: Sept. 1 - Nov. 30
% Winter Dec. 1 - Feb 28/Feb 29
spring = [3, 4, 5];
summer = [6, 7, 8];
fall = [9, 10, 11];
winter = [12, 1, 2];

%-------Note--------
% The possibility exists that a storm could occur in march and end in june
% thus covering 2 seasons.  I will declare the beginning month as the
% season that the storm falls under

for i = 1:length(storm)
    cur_mo = month(time(storm{i,1}));
    if ismember(cur_mo, spring)
        storm{i,14} = 'Spring';
    elseif ismember(cur_mo, summer)
        storm{i,14} = 'Summer';
    elseif ismember(cur_mo, fall)
        storm{i,14} = 'Fall';
    else
        storm{i,14} = 'Winter';
    end
end



% Now state the wind direction of the storm, focusing more on north south
% winds

%---------Note-----------
% North winds will be anything less than 80 degress and anything greater
% than 290

% South winds will be anything greater than 100 degrees and anything less
% than 260 degrees

% Anything in between will be east or west winds

% Note that I am basing this off of the average wind direction, change from
% storm{i,12} to storm{i,13} to grab mode instead of mean.  

for i = 1:length(storm)
    if storm{i,12} >= 100 && storm{i,12} <= 260
        storm{i,15} = 'South';
    elseif storm{i,12} <= 80 || storm{i,12} >= 280
        storm{i,15} = 'North';
    elseif storm{i,12} > 80 && storm{i,12} < 100
        storm{i,15} = 'East';
    else
        storm{i,15} = 'West';
    end
end

% Add the year the event occured
for i = 1:length(storm)
    storm{i,16} = year(time(storm{i,1}));
end

% Now add a header to the cell array

header = {'Start', 'End', 'Duration', 'Max Speed', 'Min Speed'...
    'Avg. Speed', 'Speed Variance', 'Max Pres', 'Min Pres',...
    'Avg. Pres', 'Pres. Variance', 'Avg. Direction',...
    'Dominant Direction', 'Storm Season', 'Storm Direction', 'Year'};  

% Add header
blank = storm;                                                             % blank is the same data without header for use of adding data later on
storm = [header; storm];      

%% Make a Color Map of duration vs speed

% Grab and create the variables that I want
duration = blank(:,3);                                                     % Duration variable
duration = cell2mat(duration); 

avg_spd = blank(:,6);                                                      % Average Speed variable
avg_spd = cell2mat(avg_spd);

max_spd = blank(:,4);                                                      % Max Speed variable
max_spd = cell2mat(max_spd);


% First make the grid, I am going from 0:48 on the x-axis because I am going
% to have 16 'bins' -> 0-3, 3-6, 6-9 etc. all the way to 48
% For y-axis I am having 15 'bins' and looking at wind increments of 2 m/s
% starting from zero all the way to 30.  

[X,Y] = meshgrid(3:1:48,10:1:30);
Z = zeros(size(X));

for x = 1:length(X(1,:))                                                   % For every value in mesh of x-axis
    dur = find(duration >= (X(1,x)));                                      % Find all the durations that exist longer than current threshold
    for y = 1:length(X(:,1))                                               % For every value in mesh of y-axi                                  % Find all locations of durations longer than current threshold
        spd = find(avg_spd(dur) >= Y(y,1));                                % Of those durations, find all winds that are larger than current threshold
        if ~isempty(spd)
            Z(y,x) = length(spd);
        else
            Z(y,x) = 0;
        end
    end
end

figure
imagesc(3:1:48,10:1:30,log10(Z))
set(gca,'YDir','normal') % set to normal Y scale
colorbar
ylabel('Average Wind Speed [m/s]')
xlabel('Duration [hr]')
title('Wind Duration vs Speed Threshold - Log Transform')

% Save the Plot
cd('../../Matlab_Figures/storms/heatMaps/avgDuration')

outname = sprintf('avgSpeedvsDuration_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%cd('../../../matlab/Climatology')

% Calculate the event recurrence interval for wind speeds
%---------Notes--------------
% The above plot calculates the number of hits per year for a specific wind
% speed at various durations.  Thus knowing the number of years on the
% record, I can then take each number of counts and divide by the number of
% years to find the yearly recurrence interval.  
yr_vec = year(time(1)):year(time(end));
yr_len = length(yr_vec);
AvgEvent_RI = Z./yr_len;

%% Color map for Max wind speeds 

[X,Y] = meshgrid(3:1:48,10:1:30);
Z = zeros(size(X));

for x = 1:length(X(1,:))                                                   % For every value in mesh of x-axis
    dur = find(duration >= (X(1,x)));                                      % Find all the durations that exist longer than current threshold
    for y = 1:length(X(:,1))                                               % For every value in mesh of y-axi                                  % Find all locations of durations longer than current threshold
        spd = find(max_spd(dur) >= Y(y,1));                                % Of those durations, find all winds that are larger than current threshold
        if ~isempty(spd)
            Z(y,x) = length(spd);
        else
            Z(y,x) = 0;
        end
    end
end

figure
imagesc(3:1:48,10:1:30,log10(Z))
set(gca,'YDir','normal') % set to normal Y scale
colorbar
ylabel('Maximum Wind Speed [m/s]')
xlabel('Duration [hr]')
title('Wind Duration vs Speed Threshold - Log Transform')

% Calculate Event Recurrence for Max winds
MaxEvent_RI = Z./yr_len;


cd('../maxDuration')

outname = sprintf('maxSpdvsDuration_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)


%% Occurences by Year
hits_vec = NaN(length(yr_vec), 1);
hits12_vec = NaN(length(yr_vec), 1);
starts = blank(:,1);                                                       % Grab the beginning of Events
starts = cell2mat(starts);                                                 % Convert from Cell to Double


for yr = 1:length(yr_vec)                                                  % For every year
    hits = find(year(time(cell2mat(blank(:,1)))) == yr_vec(yr));           % Find all the events per year
    hits12 = find(duration(hits) >= 12);                                   % Of those events, Find the ones that last longer than 12 hours
    
    hits_vec(yr) = length(hits);                                           % Add them to the list
    hits12_vec(yr) = length(hits12);
end


% Now plot the results
clf 

subplot(2,1,1)
plot(yr_vec, hits_vec)
xlabel('Time [years]')
ylabel('Number of Events')
title('Events by Year')

subplot(2,1,2)
plot(yr_vec, hits12_vec)
xlabel('Time [years]')
ylabel('Number of Events')
title('Events Lasting 12+ Hours')

% Save plot
cd('../../Events/FullTimeSeries')

outname = sprintf('EventsPerYear_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)


%% Make a plot of Number of Occurences per year

% using avg_spd variable above I will generate plots of number of events
% per year

thresh_vec = 2:2:26;                                                       % This will be the vector of thresholds I am looking at
avg_vec = NaN(1,length(thresh_vec));
max_vec = NaN(1,length(thresh_vec));

for n = 1:length(thresh_vec)
    avg_vec(n) = length(find(avg_spd >= thresh_vec(n)));                   % Find all the locations the average speed is above the current threshold
    max_vec(n) = length(find(max_spd >= thresh_vec(n)));                   % Find all locations where max speed is above current threshold
end
    
figure
plot(thresh_vec, avg_vec)
hold on
plot(thresh_vec, max_vec)
legend('Average Speed', 'Max Speed');
xlabel('Wind Speed [m/s]')
ylabel('Number of Occurences')
title('Total Number of Occurences')

cd('../totalHits')

outname = sprintf('TotalHits_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%% Now for by year

avg_vec = avg_vec./yr_len;                                                 % Divide number of occurences by year of record
max_vec = max_vec./yr_len;
figure
plot(thresh_vec, avg_vec)
hold on
plot(thresh_vec, max_vec)
legend('Average Speed', 'Max Speed');
xlabel('Wind Speed [m/s]')
ylabel('Number of Occurences')
title('Number of Occurences per Year')

cd('../hitsPerYear')

outname = sprintf('HitsPerYear_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)


%% Direction through time heat map

y1 = year(time(1));
y2 = year(time(end));
x1 = 10;
xBy = 10;  % Use this to see if binning is occuring
xB2 = 20;  % Use this to plot coarser winds to show change thru time


[X,Y] = meshgrid(x1:xBy:360,y1:1:y2);
Z = zeros(size(X));   % make empty grid

for y = 1:length(Y(:,1))                                                   % For every value in Y
    yr_ind = find(year(time) == Y(y));                                     % Find that current year
    for x = 1:length(X(1,:))                                               % For every value in x
        if x == 1                                                          % First value only
            dir_ind = find(wnddir(yr_ind) <= X(1,x));                      % Find all directions between 0 and first threshold
            if isempty(dir_ind)                                            % If it's empty
                Z(y,x) = 0;                                                % Set it equal to zero
            else
                Z(y,x) = length(dir_ind);                                  % Otherwise populate Z with length of hits
            end
        else
            dir_ind = find(wnddir(yr_ind) <= X(1,x) & wnddir(yr_ind) > X(1, x-1));  % Find all directions between current and 1 less threshold
            if isempty(dir_ind)
                Z(y,x) = 0;
            else
                Z(y,x) = length(dir_ind);
            end
        end
    end
end
        
    

figure
%imagesc(10:10:360,yr1:1:yr2,log10(Z))
imagesc(x1:xBy:360,y1:1:y2, Z)
set(gca,'YDir','normal') % set to normal Y scale
colorbar
ylabel('Year')
xlabel('Wind Direction [degrees]')
title('Wind Direction Through Time')

cd('../../heatMaps/dxdtFine')

outname = sprintf('DirThruTimeHeatFINE_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)


%%  Coarser Plot that doesn't show binning if present
[X,Y] = meshgrid(x1:xB2:360,y1:1:y2);
Z = zeros(size(X));   % make empty grid

for y = 1:length(Y(:,1))                                                   % For every value in Y
    yr_ind = find(year(time) == Y(y));                                     % Find that current year
    for x = 1:length(X(1,:))                                               % For every value in x
        if x == 1                                                          % First value only
            dir_ind = find(wnddir(yr_ind) <= X(1,x));                      % Find all directions between 0 and first threshold
            if isempty(dir_ind)                                            % If it's empty
                Z(y,x) = 0;                                                % Set it equal to zero
            else
                Z(y,x) = length(dir_ind);                                  % Otherwise populate Z with length of hits
            end
        else
            dir_ind = find(wnddir(yr_ind) <= X(1,x) & wnddir(yr_ind) > X(1, x-1));  % Find all directions between current and 1 less threshold
            if isempty(dir_ind)
                Z(y,x) = 0;
            else
                Z(y,x) = length(dir_ind);
            end
        end
    end
end
        
    

figure
%imagesc(10:10:360,yr1:1:yr2,log10(Z))
imagesc(x1:xB2:360,y1:1:y2, Z)
set(gca,'YDir','normal') % set to normal Y scale
colorbar
ylabel('Year')
xlabel('Wind Direction [degrees]')
title('Wind Direction Through Time')

cd('../dxdtCoarse')

outname = sprintf('DirThruTimeHeatCOARSE_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

cd('../../../../matlab/Climatology')

