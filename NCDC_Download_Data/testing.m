% Loop through stations 
for ii = 1:length(stns)
    cur_name = stns(ii).name;
    space_ind = strfind(cur_name,' ');
    name2find = cur_name(1:space_ind-1);
    inds = [ii]; % to house all the same stations 
    for jj = 1:length(stns)
        [~,temp_name,~] = fileparts(stns(jj).name);
        if contains(temp_name,name2find) && jj ~= ii
            inds(end+1) = jj;
        end
    end
    
    clf
    for jj = 1:length(inds)
        fname = sprintf('station_data/%s',stns(inds(jj)).name);
        S = load(fname);
        S.datenum = datenum(station_data.yr, station_data.mo, station_data.da, station_data.hr, station_data.mn, 30);
        plot(S.yr,S.spd)
        hold on 
        pause
    end
    
    ii = inds(end);
    pause
end
