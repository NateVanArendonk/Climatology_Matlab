%% Code to refine winds by direction

%first load in the data

clear
load('/Users/andrewmcauliffe/Desktop/Matlab_Struct/downloaded station data/Whidbey_hourly.mat')
%wind direction for some reason isn't in the correct format so change it
wnddir = wnddir';

wnddir = wnddir(164377:end);
wndspd = wndspd(164377:end);
airtemp = airtemp(164377:end);
dewp = dewp(164377:end);
slp = slp(164377:end);
stp = stp(164377:end);
time = time(164377:end);

%% Get direction to test, this will change

dir1 = 90; %this should be smaller value
dir2 = 170; %this should be larger value

% Find indicies with those directions
group1 = find(wnddir < dir2 & wnddir > dir1);

%Now make data structure of those indicies for that direction
SE.wnddir = wnddir(group1);
SE.wndspd = wndspd(group1);
SE.slp = slp(group1);
SE.time = time(group1);

%% Now get other direction

dir3 = 235;
dir4 = 300;


% Find indicies of those directions
group2 = find(wnddir > dir3 & wnddir < dir4);

%Now make data structure of those indicies for that direction

%FF = struct();
W.wnddir = wnddir(group2);
W.wndspd = wndspd(group2);
W.slp = slp(group2);
W.time = time(group2);


%% Now refine by speed > 10 m/s

group3 = find(wndspd(group1) >= 10);
group4 = find(wndspd(group2) >= 10);

SS.wndspd = SE.wndspd(group3);
SS.wnddir = SE.wnddir(group3);
SS.slp = SE.slp(group3);
SS.time = SE.time(group3);

WW.wndspd = W.wndspd(group4);
WW.wnddir = W.wnddir(group4);
WW.slp = W.slp(group4);
WW.time = W.time(group4); 


clear group1 group2 group3 group4 dir1 dir2 dir3 dir4 wndspd wnddir time slp stp airtemp dewp

plot(SS.time, SS.wnddir, '*')
hold on
myfit = fitlm(SS.time(1:end), SS.wnddir(1:end));
plot(SS.time(1:end), myfit.Fitted)