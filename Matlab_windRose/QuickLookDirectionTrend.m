% Look for decadal trends in wind direction
%   Start with yearly averages
%       Simple winddir avg
%       Windspeed weighted winddir avg
%
%   Next, repeat for each month or season
%       e.g. How are Winter wind directions changing in the last 50yrs?
%
%   Need to identify trends, and classify trends as either significant or
%   insignificant. Consult basic statistical theory
%
%   Start with Bham data, not sure if columns are read in correctly,
%   assumed to be u,v (East,North) wind velocities. But this may likely be
%   wrong.


%% Read in bham airport data

fid = fopen('wind_data_BELLINGHAMINTL.dat');
data = textscan(fid,'%s %s %f %f\n');

  
%% Create timevec (slow-ish, 1-5min)
tic
time = NaN(length(data{1}),1);  %create a NaN matrix, with Length rows and 1 column
for tt = 1:length(data{1})    
    time(tt) = datenum([data{1}{tt} data{2}{tt}],'yyyy-mm-ddHH:MM:SS');
    %data{1} houses 1948-01-01 and data{2} houses 23:00:00
    %so making datenums for every value in the time vector
    
end
toc

%% Convert to dir and speed

wnddir = 180/pi*atan2(data{4},data{3});

% Rotate winds to compass directions
wnddir = 90 - wnddir;
wnddir(wnddir<0)=wnddir(wnddir<0)+360;

% switch to conventional coming from dir
wnddir = wnddir+180;
wnddir = wrapTo360(wnddir);

wndspd = sqrt(data{4}.^2+ data{3}.^2);


%% Quick plot of raw data 
subplot(211)
plot(time,wndspd)
subplot(212)
plot(time,wnddir)
datetick('x')

%% Bin by year
yr_vec = 1948:2015;  %creates a vector spanning from 48 to 2015
wndspd_mean = NaN(length(yr_vec),1);  %sets this variable equal to NaNs the length of yr_vec
wnddir_mean = wndspd_mean;  %Equal to NaNs 
wnddir_weighted = wndspd_mean; %Equal to Nans
for yr = 1:length(yr_vec)
    tinds = year(time)==yr_vec(yr);
    
    %This will run the length of yr_vec, so tinds is a logical "vector"
    %that stores the indices where for that iteration, the time vector has
    %the same value as the yr_vec
    
    % then run an if statement, to see if there are enough values to
    % calculate a mean for the year, if there are then calculate the mean
    % at each tind for the entire year and then start over.  
    
    
    if sum(tinds) > 365*24*.5 %50% of year
        wndspd_mean(yr) = mean(wndspd(tinds));
        wnddir_mean(yr) = mean(wnddir(tinds));
        wnddir_weighted(yr) = sum(wndspd(tinds).*wnddir(tinds))/sum(wndspd(tinds));
    end
end    

%% Plot binned results, fit trend lines
clf
subplot(311)
plot(yr_vec,wndspd_mean)

subplot(312)
plot(yr_vec,wnddir_mean)

subplot(313)
plot(yr_vec,wnddir_weighted)
hold on
myfit = fitlm(yr_vec(1:24),wnddir_weighted(1:24));
plot(yr_vec(1:24),myfit.Fitted)   
myfit = fitlm(yr_vec(24:end),wnddir_weighted(24:end));
plot(yr_vec(24:end),myfit.Fitted)
    
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
