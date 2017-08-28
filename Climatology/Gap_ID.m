
clearvars

dir_nm = '../../hourly_data/gap_hourly/';
  % grabs all the files ending in .mat
d = dir([dir_nm, '/*.mat']);



% loop through each 
for n = 1:length(d)
    file_nm = d(n).name;
    [pathstr, name, ext] = fileparts(file_nm);  % seperates file name and extension and such 
    station_nm = regexprep(name, '_hourly', ''); % Gets rid of '_hourly' from the name
    
    
    load(strcat(dir_nm,file_nm))
    spd_gap = find(isnan(wndspd));
    missing = (length(spd_gap)/length(wndspd))*100;
    missing = num2str(missing);
    
    
    txt = sprintf('%s: missing %s percent', station_nm, missing); 
    disp(txt)
end