%% Code to compare the plots of 6 min and hourly tide data for GEV analysis


clearvars

%first load in the data
%dir_nm = '../../hourly_data/';
dir_nm = '../../COOPS_tides/';
station_name = 'Seattle';
station_nm = 'seattle';

%load_file = strcat(dir_nm,station_nm,'/',station_nm,'_hrV');
load_file = strcat(dir_nm,station_nm,'/',station_nm,'_6minV');
load(load_file)
%%  Create half hourly time vec and interp data onto 

% Create half hourly time vec
tvec = datenum(year(tides.time(1)),month(tides.time(1)),15):...
    (365.25/17520):datenum(year(tides.time(end)),...
    month(tides.time(end)),15);

[~, II] = unique(tides.time);


% Interp onto vector using tidal data
%tides_half = interp1(tides.time(II), tides.WL_VALUE(II), tvec, 'linear');
tides_half = interpShortGap(tides.time(II),tides.WL_VALUE(II),tvec, 6);
%tides_half = interpShortNaN(tides.WL_VALUE(II), tvec, 6);
%% Filter the tides to grab ntr

ntr.ntr = filter_tides(tides_half);
ntr.time = tvec;
% Convert from complex to real numbers
ntr.ntr = real(ntr.ntr);
%% Save data



cd('../../')

save_nm = sprintf(strcat(station_nm, '_ntr6min'));

save(save_nm, '-struct', 'ntr')

cd('matlab/Climatology')
