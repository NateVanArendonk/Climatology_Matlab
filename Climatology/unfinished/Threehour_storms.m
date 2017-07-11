%% Find events lasting longer than 3 hours

%first convert to 10 m height for wndspd
%load in data
load('/Users/andrewmcauliffe/Desktop/Matlab/Matlab_Structure/downloaded_data/Whidbey_hourly.mat');


%Finlayson (2009) states that 10 m/s is the typical storm event because
%these events occur more than once a year and for durations of multiple
%hours

%I will start out using 10 m/s as my threshold

%% Find wind speeds greater than 10 m/s
%wndspd10I = wndspd >= 10; %grab indices where wind is greater than 10 m/s
wndspd10m = find(wndspd >= 10); %grab the actual locations of strong winds

%% Find consecutive values for wind       
A = find(diff(wndspd10m)==1);  %find all the locations where the difference is equal to 1
B = A+1; %Because diff returns a vector 1-less than needed, I add 1 to every value in the diff vector
C = union(A,B); % this combines the vectors with no repetitions 

wndCont = wndspd10m(C); %These are all the indices of the storms
wind.ind = wndCont;

storm3 = wndspd(wndCont); %grab the wind speeds now

wndCont = wndspd10m(C); %These are all the indices of the storms
wind.ind = wndCont;    
wind.spd = storm3;   

clear A B C wndCont storm3
% Now I need to find where within the winds > 10 m/s are
% sustained for more than 3 hours.  


%% Find sustained winds
%first I will find the locations of where there are breaks in the winds
breaks = find(diff(wind.ind) ~= 1);

stormBlocks = NaN(length(breaks), max(diff(breaks)));


%Issue with breaks and such figure it out, first and second part of loop
%work, third part need tweaking

% for i = 1:length(breaks)
%     if i == 1
%         tempBlock = wind.ind(1:breaks(i))
%     elseif i == length(breaks)
%         tempBlock = wind.ind(breaks((end - 1)+1: i))
%     else
%         tempBlock = wind.ind(breaks(i - 1) + 1:breaks(i))
%     end
% end
%         
for i = 1:length(breaks)
    if i ~= length(breaks)
        tempBlock = wind.ind(i:breaks(i))
    end
end
