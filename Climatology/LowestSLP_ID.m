
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
    [val, ind] = min(slp);

    if val < 950
        slp(ind) = [];
    end
    val = min(slp);

    val = num2str(val);
    
    inds = find(slp < 980);
    ival = length(inds)/length(slp)*100;
    ival = num2str(ival);
    
    
    
    txt = sprintf('%s: Lowest slp = %s', station_nm, val); 
    txt2 = sprintf('%s: Percent below 980 = %s', station_nm, ival);
    disp(txt)
    disp(txt2)
954969end