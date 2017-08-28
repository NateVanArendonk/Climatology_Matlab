%----------Note-----------------
%This code is used to generate values used for the PlotDistributions script


%% Code to refine wind data by direction

% % clearvars
% % 
% % %first load in the data
dir_nm = '../../hourly_data/gap_hourly/';
% % %dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
file_nm = 'whidbey_nas_hourly'; % you will have to change this variable for each station
load_file = strcat(dir_nm,file_nm);
load(load_file)
% % clear dir_nm file_nm load_file
% % wnddir = wnddir';

%% Refine winds coming from S/SE
%http://climate.umn.edu/snow_fence/components/winddirectionanddegreeswithouttable3.htm
%I will be defining S/SE as any wind from 191.25 degrees to 90 degrees

% if ~exist('wndspd')
%     wndspd = wndspd_obs;
% end

if length(slp) < 2  %Just in case there is no pressure data
    slp = zeros(length(wndspd), 1);
end

southI = find(wnddir > 90 & wnddir <= 191.25);
southI = southI';
south.wnddir = wnddir(southI);
south.wndspd = wndspd(southI);
south.slp = slp(southI);
south.time = time(southI);
%south.stp = time(southI);
%south.dewp = dewp(southI);
clear southI
%% Refine winds from from the N/NW
%I will be defining N/NW as any wind from 0 - 11.25 and 270 - 360

northI = find(wnddir < 11.25 | wnddir > 270);
north.wnddir = wnddir(northI);
north.wndspd = wndspd(northI);
north.slp = slp(northI);
north.time = time(northI);
%north.stp = stp(northI);
%north.dewp = dewp(northI);
clear northI
%% Refine winds coming from the West
%I will be defining W as any wind coming from 258.75 - 281.25

westI = find(wnddir < 281.25 & wnddir > 258.75);
west.wnddir = wnddir(westI);
west.wndspd = wndspd(westI);
west.slp = slp(westI);
west.time = time(westI);
%west.stp = stp(westI);
%west.dewp = dewp(westI);
clear westI


%% Now I will refine by speed into light air, strong breeze, and gale
%Finlayson (2006) defines the three air speeds
%light air = 0 - 10 m/s
%strong breeze = 10 - 20 m/s
%gale = >20 m/s

%To do this I will find all of these parameters for all the winds, then I
%will do the same but for each direction structure

l = find(wndspd > 0 & wndspd <= 10);
b = find(wndspd > 10 & wndspd <= 20);
g = find(wndspd > 20);

light.wndpsd = wndspd(l);
light.wnddir = wnddir(l);
light.slp = slp(l);
%light.stp = stp(l);
%light.dewp = dewp(l);
light.time = time(l);

breeze.wndspd = wndspd(b);
breeze.wnddir = wnddir(b);
breeze.slp = slp(b);
%breeze.stp = stp(b);
%breeze.dewp = dewp(b);
breeze.time = time(b);

gale.wndspd = wndspd(g);
gale.wnddir = wnddir(g);
gale.slp = slp(g);
%gale.stp = stp(g);
%gale.dewp = dewp(g);
gale.time = time(g);


%Now refine light winds by direction
        %light
ls = find(light.wnddir > 90 & light.wnddir <= 191.25);
ln = find(light.wnddir < 11.25 | light.wnddir > 270);
lw = find(light.wnddir < 281.25 & light.wnddir > 258.75);
        %breeze
bs = find(breeze.wnddir > 90 & breeze.wnddir <= 191.25);
bn = find(breeze.wnddir < 11.25 | breeze.wnddir > 270);
bw = find(breeze.wnddir < 281.25 & breeze.wnddir > 258.75); 
        %gale
gs = find(gale.wnddir > 90 & gale.wnddir <= 191.25);
gn = find(gale.wnddir < 11.25 | gale.wnddir > 270);
gw = find(gale.wnddir < 281.25 & gale.wnddir > 258.75); 


% Now make strucutres for these direction and speeds
%%%%%%%%%%%South%%%%%%%%%%
southL.wndspd = wndspd(ls);
southL.wnddir = wnddir(ls);
southL.slp = slp(ls);
%south.stp = stp(ls);
%south.dewp = dewp(ls);
south.time = time(ls);

southB.wndspd = wndspd(bs);
southB.wnddir = wnddir(bs);
southB.slp = slp(bs);
%southB.stp = stp(bs);
%southB.dewp = dewp(bs);
southB.time = time(bs);

southG.wndspd = wndspd(gs);
southG.wnddir = wnddir(gs);
southG.slp = slp(gs);
%southG.stp = stp(gs);
%southG.dewp = dewp(gs);
southG.time = time(gs);

%%%%%%%%%%North%%%%%%%%%%%
northL.wndspd = wndspd(ln);
northL.wnddir = wnddir(ln);
northL.slp = slp(ln);
%northL.stp = stp(ln);
%northL.dewp = dewp(ln);
northL.time = time(ln);

northB.wndspd = wndspd(bn);
northB.wnddir = wnddir(bn);
northB.slp = slp(bn);
%northB.stp = stp(bn);
%northB.dewp = dewp(bn);
northB.time = time(bn);

northG.wndspd = wndspd(gn);
northG.wnddir = wnddir(gn);
northG.slp = slp(gn);
%northG.stp = stp(gn);
%northG.dewp = dewp(gn);
northG.time = time(gn);


%%%%%%%%%%West%%%%%%%%%%%
westL.wndspd = wndspd(lw);
westL.wnddir = wnddir(lw);
westL.slp = slp(lw);
%westL.stp = stp(lw);
%westL.dewp = dewp(lw);
westL.time = time(lw);

westB.wndspd = wndspd(bw);
westB.wnddir = wnddir(bw);
westB.slp = slp(bw);
%westB.stp = stp(bw);
%westB.dewp = dewp(bw);
westB.time = time(bw);

westG.wndspd = wndspd(gw);
westG.wnddir = wnddir(gw);
westG.slp = slp(gw);
%westG.stp = stp(gw);
%westG.dewp = dewp(gw);
westG.time = time(gw);

clear l b g ls ln lw bs bn bw gs gn gw



%% Now refine by month
%This will be a nested structure

%Find indices for each month
jani = find(month(time) == 1);
febi = find(month(time) == 2);
mari = find(month(time) == 3);
apri = find(month(time) == 4);
mayi = find(month(time) == 5);
juni = find(month(time) == 6);
juli = find(month(time) == 7);
augi = find(month(time) == 8);
septi = find(month(time) == 9);
octi = find(month(time) == 10);
novi = find(month(time) == 11);
deci = find(month(time) == 12);

%January
months.jan.wndspd = wndspd(jani);
months.jan.wnddir = wnddir(jani);
months.jan.slp = slp(jani);
%months.jan.stp = stp(jani);
%months.jan.dewp = dewp(jani);
months.jan.time = time(jani);

%February
months.feb.wndspd = wndspd(febi);
months.feb.wnddir = wnddir(febi);
months.feb.slp = slp(febi);
%months.feb.stp = stp(febi);
%months.feb.dewp = dewp(febi);
months.feb.time = time(febi);

%March
months.mar.wndspd = wndspd(mari);
months.mar.wnddir = wnddir(mari);
months.mar.slp = slp(mari);
%months.mar.stp = stp(mari);
%months.mar.dewp = dewp(mari);
months.mar.time = time(mari);

%April
months.apr.wndspd = wndspd(apri);
months.apr.wnddir = wnddir(apri);
months.apr.slp = slp(apri);
%months.apr.stp = stp(apri);
%months.apr.dewp = dewp(apri);
months.apr.time = time(apri);

%May 
months.may.wndspd = wndspd(mayi);
months.may.wnddir = wnddir(mayi);
months.may.slp = slp(mayi);
%months.may.stp = stp(mayi);
%months.may.dewp = dewp(mayi);
months.may.time = time(mayi);

%June
months.june.wndspd = wndspd(juni);
months.june.wnddir = wnddir(juni);
months.june.slp = slp(juni);
%months.june.stp = stp(juni);
%months.june.dewp = dewp(juni);
months.june.time = time(juni);

%July
months.july.wndspd = wndspd(juli);
months.july.wnddir = wnddir(juli);
months.july.slp = slp(juli);
%months.july.stp = stp(juli);
%months.july.dewp = dewp(juli);
months.july.time = time(juli);

%August
months.aug.wndspd = wndspd(augi);
months.aug.wnddir = wnddir(augi);
months.aug.slp = slp(augi);
%months.aug.stp = stp(augi);
%months.aug.dewp = dewp(augi);
months.aug.time = time(augi);

%September 
months.sept.wndspd = wndspd(septi);
months.sept.wnddir = wnddir(septi);
months.sept.slp = slp(septi);
%months.sept.stp = stp(septi);
%months.sept.dewp = dewp(septi);
months.sept.time = time(septi);

%October
months.oct.wndspd = wndspd(octi);
months.oct.wnddir = wnddir(octi);
months.oct.slp = slp(octi);
%months.oct.stp = stp(octi);
%months.oct.dewp = dewp(octi);
months.oct.time = time(octi);

%November
months.nov.wndspd = wndspd(novi);
months.nov.wnddir = wnddir(novi);
months.nov.slp = slp(novi);
%months.nov.stp = stp(novi);
%months.nov.dewp = dewp(novi);
months.nov.time = time(novi);

%December
months.dec.wndspd = wndspd(deci);
months.dec.wnddir = wnddir(deci);
months.dec.slp = slp(deci);
%months.dec.stp = stp(deci);
%months.dec.dewp = dewp(deci);
months.dec.time = time(deci);

clear jani febi mari apri mayi juni juli augi septi octi novi deci

%% need to make a character vector for the months This is for box plots

%make empty character vector 

mo_str = strings(length(wndspd),1);


for i = 1:length(wndspd)
    mo_str(i) = month(time(i));
end

%mo_vec = NaN(1,length(slp));
%mo_vec = mat2cell(mo_vec, length(slp));

for i = 1:length(mo_str)
    if mo_str(i) == "1"
        mo_str(i) = "Jan";
    elseif mo_str(i) == "2"
        mo_str(i) = "Feb";
    elseif mo_str(i) == "3"
        mo_str(i) = "Mar";
    elseif mo_str(i) == "4"
        mo_str(i) = "Apr";
    elseif mo_str(i) == "5"
        mo_str(i) = "May";
    elseif mo_str(i) == "6"
        mo_str(i) = "Jun";
    elseif mo_str(i) == "7" 
        mo_str(i) = "Jul";
    elseif mo_str(i) == "8"
        mo_str(i) = "Aug";
    elseif mo_str(i) == "9" 
        mo_str(i) = "Sept";
    elseif mo_str(i) == "10"
        mo_str(i) = "Oct";
    elseif mo_str(i) == "11"
        mo_str(i) = "Nov";
    elseif mo_str(i) == "12"
        mo_str(i) = "Dec";
    end
end


% % % for i = 1:length(mo_str)
% % %     if mo_str(i) == "1"
% % %         mo_vec(i) = 'Jan';
% % %     elseif mo_str(i) == "2"
% % %         mo_vec(i) = 'Feb';
% % %     elseif mo_str(i) == "3"
% % %         mo_vec(i) = 'Mar';
% % %     elseif mo_str(i) == "4"
% % %         mo_vec(i) = 'Apr';
% % %     elseif mo_str(i) == "5"
% % %         mo_vec(i) = 'May';
% % %     elseif mo_str(i) == "6"
% % %         mo_vec(i) = 'Jun';
% % %     elseif mo_str(i) == "7" 
% % %         mo_vec(i) = 'Jul';
% % %     elseif mo_str(i) == "8"
% % %         mo_vec(i) = 'Aug';
% % %     elseif mo_str(i) == "9" 
% % %         mo_vec(i) = 'Sept';
% % %     elseif mo_str(i) == "10"
% % %         mo_vec(i) = 'Oct';
% % %     elseif mo_str(i) == "11"
% % %         mo_vec(i) = 'Nov';
% % %     elseif mo_str(i) == "12"
% % %         mo_vec(i) = 'Dec';
% % %     end
% % % end



% Convert string into character array
mo_str = char(mo_str);

%% Stats of data to add to figures
coverage = year(time(end)) - year(time(1));

max_wnd = max(wndspd);

%http://cliffmass.blogspot.com/2014/12/highest-pressures-in-northwest-history.html
%according to cliff mass, the highest pressures are around 1050
%I will get rid of unrealistic slp data and choose anything below 1070

slpI = find(slp <= 1070);
max_slp = max(slp(slpI));

min_slp = min(slp);


