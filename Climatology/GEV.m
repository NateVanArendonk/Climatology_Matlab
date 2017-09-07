function paramEsts = GEV(type, r_val, dir_loc, station_nm, output)
%Function to run GEV analysis on data of choice

% type = type of GEV analysis to perform - Block, Rth.  e.g. 'block', 'rth'
% r_val = number of maxima per year to choose - e.g. 4
% dir_loc = directory location of data - e.g. '../../COOPS_tides/';
% station_nm = name of station to grab data for - e.g. 'seattle'
% output = type of output desired - Exceedance prob, Recurrence Interval
    % e.g. 'RI', 'PE', 'ALL' - Choose 'ALL' for all output
    
data = load(strcat(dir_loc,station_nm));







end

