% Script that grabs data and then plots in a multi-plot figure
clearvars
addpath /Users/andrewmcauliffe/desktop/matlab_functions
% Date of Storm
yr = 1999; % March 3rd at 7 am is time of landfall
mo = 03;
dy = 03;
station_name = 'whidbey_nas';
station_title = 'Whidbey NAS';

%load('01_20_1993_storm.mat')
%load('12_12_1995_storm.mat')
%load('columbus_day_storm.mat')
load('temp_obs'); load('temp_nnrp'); load('temp_time');
load('WA_coast.mat');
% Find all shapes above threshold
wa_lat = [];
wa_lon = [];
thresh = 500 ;
for j = 1:length(wa_coast)
    temp_x = wa_coast(j).X;
    temp_y = wa_coast(j).Y;
    if length(temp_x) >= thresh && j ~= 3348 % 3348 is oregon
        for m = 1:length(temp_x);
            wa_lat(end+1) = temp_y(m);
            wa_lon(end+1) = temp_x(m);
        end
    end
end

%% Load in multiple obs stations 
% Load in obs data
fol_loc = '/Users/andrewmcauliffe/desktop/hourly_data/gap_hourly'; % location of data
stations = {'bham_airport','mcchord_afb','vic_air','whidbey_nas'}; % station names
stn_names = ['bham','mcc','vic','whid'];
model_time = datenum(yr,mo,dy,0,0,0);
for m = 1:length(stations)
    file_load = strcat(fol_loc,'/',stations{m},'_hourly.mat');
    load(file_load);
    ts = 72;
    % Indice values that will require logic 
    end_inds = [1:ts,(length(time)):-1:(length(time)-ts)];
    % Find corresponding time indicie
    ind = find(time == model_time);
    if ~ismember(ind,end_inds)
        ind_window = (ind-ts:ind+ts);
    else
        if ind <= ts
            ind_window = (ind-(ind-1):ind+ts);
        elseif ind >= length(time)-ts
            ind_window = (ind-ts:length(time));
        else
            disp('ERROR: WRONG WINDOW FOR GRABBING DATA - DOES NOT EXIST')
        end
    end
    % Grab meteo data for window of time
    obs(m).name = stations{m};
    obs(m).wndspd = wndspd(ind_window);
    obs(m).wnddir = wnddir(ind_window)';
    obs(m).slp = slp(ind_window);
    obs(m).time = time(ind_window);
    % Get Lat Lon values from different file
    fol_loc = '/Users/andrewmcauliffe/desktop/hourly_data/';
    file_load = strcat(fol_loc,'/',stations{m},'_hourly.mat');
    temp_obs = load(file_load);
    obs(m).lat = temp_obs.lat;
    obs(m).lon = temp_obs.lon;
    clear airtemp slp time wnddir wndspd
end
obs_time = datenum(yr,mo,dy,0,0,0)-(ts/24):1/24:datenum(yr,mo,dy,0,0,0)+(ts/24);
%%



figure(2)
% ---------- Dimensions for plot
p_left = .05;
p_right = .05;
p_top = .1;
p_bot = .05;
p_big = .05;
p_small = .01;
p_wid = (1-p_right-p_left-p_big)/2;
p_height = (1-p_top-p_bot-p_big)/2;
p_height2 = (p_height-p_small)/2;
p_wid2 = (p_wid-p_small)/2;

% Plot Windspeed
axes('position',[p_left+0*(p_wid+p_big) p_bot+1*(p_height+p_big) p_wid p_height]);
for x = 1:length(obs)
    plot(obs_time,obs(x).wndspd)
    hold on
end
legend('bham airport','mcchord afb','vic air','whidbey')
set(gca,'XTickLabel',[])
ylabel('Wind Speed [m/s]')
grid on

% Plot SLP
axes('position',[p_left+0*(p_wid+p_big) p_bot+0*(p_height+p_big) p_wid p_height]);
for x = 1:length(obs)
    plot(obs_time,obs(x).slp)
    hold on
end
legend('bham airport','mcchord afb','vic air','whidbey','Location','SouthWest')
datetick()
xlabel('Time')
ylabel('Sea Level Pressure [slp]')
grid on

% Add Video of SLP
video_title = sprintf('WA_storm_%d_%d_%d',yr,mo,dy);
v = VideoWriter(video_title,'MPEG-4');
v.FrameRate = 2;
v.Quality = 75; % Default 75
open(v);
inds = zeros(1,length(nn.time));
for tt = 1:length(nn.time)
    clf
    
    % Find Indicie of time in NNRP = Obs time
    I = findnearest(nn.time(tt),obs_time);
    inds(tt) = I;
    
    % Plot Windspeed
    axes('position',[p_left+0*(p_wid+p_big) p_bot+1*(p_height+p_big) p_wid p_height]);
    p1 = plot(obs_time,obs(1).wndspd);
    hold on
    p2 = plot(obs_time,obs(2).wndspd);
    hold on 
    p3 = plot(obs_time,obs(3).wndspd);
    hold on 
    p4 = plot(obs_time,obs(4).wndspd);
%     for x = 1:length(obs)
%         mm = plot(obs_time,obs(x).wndspd);
%         hold on
%     end
    set(gca,'XTickLabel',[])
    ylabel('Wind Speed [m/s]')
    grid on
    hold on 
    plot(obs_time(I),obs(4).wndspd(I),'ko','MarkerFaceColor','k')
    legend([p1 p2 p3 p4],'bham airport','mcchord afb','vic air','whidbey')
    
    % Plot SLP
    axes('position',[p_left+0*(p_wid+p_big) p_bot+0*(p_height+p_big) p_wid p_height]);
    for x = 1:length(obs)
        plot(obs_time,obs(x).slp)
        hold on
    end
    xlabel('Time')
    ylabel('Sea Level Pressure [slp]')
    grid on
    datetick()
    hold on 
    plot(obs_time(I),obs(4).slp(I),'ko','MarkerFaceColor','k')
    
    % ---- Plot NNRP Winds and SLP
    axes('position',[p_left+1*(p_wid+p_big) p_bot+0*(p_height+p_big) p_wid 2*(p_height)+p_big]);
    pcolor(nn.lon,nn.lat,nn.wndspd(:,:,tt))
    shading interp
    xlabel('Degrees Longitude')
    ylabel('Degrees Latitude')
    plot_tit = sprintf('NNRP: %s',datestr(nn.time(tt)));
    title(plot_tit)
    
    hold on % ---------- Add WA Coastline
    plot(wa_lon,wa_lat,'Color',[1,1,1])
    xlim([-128 -122])
    ylim([45 50.5])
    
    hold on % ---------- Add SLP
    dxP = 2; % Plotting contour interval
    dxPl = 2; % Contour Label Interval
    vp = 950:dxP:1080; % Contours to plot
    vl = 950:dxPl:1080; % Contours to label
    [C,h] = contour(nn.lon,nn.lat,nn.slp(:,:,tt),vp,'k');
    temp_wnd = nn.wndspd(:,:,tt);
    caxis([0 1.1*max(temp_wnd(:))])
    clabel(C,h,vl) % Add labels to contour
    
    hold on % ------- Plot station points
    colors = [0    0.4470    0.7410;
              0.8500    0.3250    0.0980;
              0.9290    0.6940    0.1250;
              0.4940    0.1840    0.5560];
              
    for x = 1:length(obs)
        plot(obs(x).lon,obs(x).lat,'o','Color',colors(x,:),'MarkerFaceColor',colors(x,:),'MarkerSize',10)
        hold on
    end
%     % Add Colorbar
    chan = colorbar('Location','EastOutSide');
    set(chan,'Position',[p_left+1*(2*p_wid+p_big) p_bot+0*(p_height+p_big) .02 2*(p_height)+p_big])
    caxis([0 20])
    
    
    frame = getframe(gcf);
    writeVideo(v,frame);
end
close(v);

