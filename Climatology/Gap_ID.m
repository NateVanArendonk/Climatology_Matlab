
clearvars

dir_nm = '../../hourly_data/gap_hourly/station_choice/';
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
    
    slp_gap = find(isnan(slp));
    m2 = (length(slp_gap)/length(slp))*100;
    m2 = num2str(m2);
    
    
    txt = sprintf('%s: missing %s percent - speed', station_nm, missing); 
    txt2 = sprintf('%s: missing %s percent - pressure\n', station_nm, m2);
    disp(txt)
    disp(txt2)
end