%% Identify data gaps for accurate data coverage 
clearvars
dir_loc = '../../hourly_data/gap_hourly';
file_nm = 'abbotsford_hourly.mat';

load(strcat(dir_loc, '/', file_nm))

% Find NaNs
nan_inds = find(isnan(wndspd));
nan_inds = nan_inds';

nan_dif = find(diff(nan_inds) > 1);
% indices of nan_inds that are greater than 1



