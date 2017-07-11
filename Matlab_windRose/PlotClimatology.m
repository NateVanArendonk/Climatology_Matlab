%%%%Made by Sean, not too useable for me at the moment (NV: 6/21/17)


clearvars

% Make some climatology plots


% Define sites of interest to extract
fname = 'D:\GoogleDrive\CoastalChangeModeling\Workplan\WeatherStationMeta.csv';
Station = readStationMeta( fname );


% Data folder
% fol_loc = '../DownloadMetData';
% fol_loc = '../ExtractNNRP/Output';
 fol_loc = '../ExtractGriddedWeather/Output';

% Data type
% data_type = 'obs';
% data_type = 'NNRP';
 data_type = 'HRDPS';

%%%%%%%%%%%%%%%%%%%%%%%% WIND ROSE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Station to use
for sta_num = [2 3 4 5 7]

% Fname
fname = sprintf('%s/%s_%s.mat',fol_loc,data_type,Station.shortName{sta_num});

% Load
O = load(fname);

%ax = subplot(211);

% Wind Rose
options.nDirections = 32;
%options.nspeeds = 10;
options.vWinds = [0 5 10 15 20 25];
options.AngleNorth = 0;
options.AngleEast = 90;
options.labels = {'North (360°)','South (180°)','East (0°)','West (270°)'};
options.TitleString = [];
%options.axes = ax;
%inds_w = (~isnan(O.wnddir) & ~isnan(O.wndspd));
[figure_handle,count,speeds,directions,Table] = WindRose(O.wnddir,O.wndspd_10m,options);
suptitle(Station.longName{sta_num})

outname = sprintf('WindRose_%s_%s',data_type,Station.shortName{sta_num});
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [7 7];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname)

close(hFig)
end


%%
%%%%%%%%%%%%%%%%%%%%%%%% WAVE ROSE (For Hein Bank Obs only) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Station to use
clear options 
for sta_num = [2]

% Fname
fname = sprintf('%s/%s_%s.mat',fol_loc,data_type,Station.shortName{sta_num});

% Load
O = load(fname);

%ax = subplot(211);

% Wind Rose
options.nDirections = 32*2;
%options.nspeeds = 10;
options.AngleNorth = 0;
options.AngleEast = 90;
options.labels = {'North (360°)','South (180°)','East (0°)','West (270°)'};
options.vWinds = [0 .5 1 1.5 2 2.5 3];
options.TitleString = [];
options.LabLegend = 'Hs [m]';
options.LegendVariable = 'Hs';
%options.axes = ax;
%inds_w = (~isnan(O.wnddir) & ~isnan(O.wndspd));
[figure_handle,count,speeds,directions,Table] = WindRose(O.wavedir,O.waveheight,options);
suptitle(Station.longName{sta_num})

outname = sprintf('WaveRose_%s_%s',data_type,Station.shortName{sta_num});
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [7 7];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname)

close(hFig)
end

return


% %% Waves
% data_type = 'obs';
% fol_loc = '../DownloadMetData';
% 
% sta_num = 2;
% 
% % Fname
% fname = sprintf('%s/%s_%s.mat',fol_loc,data_type,Station.shortName{sta_num});
% 
% % Load
% O = load(fname);
% 
% clf
% subplot(311)
% plot(O.time,O.waveheight)
% xlim([datenum(2011,10,1) datenum(2012,1,1)])
% subplot(312)
% plot(O.time,O.wavemeanperiod)
% hold on
% plot(O.time,O.wavepeakperiod)
% xlim([datenum(2011,10,1) datenum(2012,1,1)])
% subplot(313)
% plot(O.time,O.wavedir)
% xlim([datenum(2011,10,1) datenum(2012,1,1)])
% 









