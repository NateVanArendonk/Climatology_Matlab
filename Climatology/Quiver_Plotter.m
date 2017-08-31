%% Plot mean values for wind direction by decade for salish stations with quiver
clearvars
dir_nm = '../../hourly_data/gap_hourly/Station_Choice/decadal/';                                                     
file_nm = 'decadal_stations';                                   
load_file = strcat(dir_nm,file_nm);
load(load_file)
clear dir_nm load_file