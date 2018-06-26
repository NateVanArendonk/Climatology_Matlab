clearvars

% Load in WA coastline for plotting purposes 
load('wa_coast')
% Find all shapes above threshold
wa_lat = [];
wa_lon = [];
thresh = 10 ;
for j = 1:length(wa_coast)
    temp_x = wa_coast(j).X;
    temp_y = wa_coast(j).Y;
    if length(temp_x) >= thresh && j ~= 3348 % 3348 is oregon
%         disp(j)
%         plot(temp_x,temp_y)
%         pause
        for m = 1:length(temp_x);
            wa_lat(end+1) = temp_y(m);
            wa_lon(end+1) = temp_x(m);
        end
    end
end


% Identify All the repeat and unique stations 
stns = dir('station_data/*.mat');


%%

% Loop through stations 
for ii = 1%:length(stns)
    cur_name = stns(ii).name;
    space_ind = strfind(cur_name,' ');
    name2find = cur_name(1:space_ind);
    
    for jj = 1:length(stns)
        inds = [];
        if contains(stns(jj).name,name2find)
            inds(end+1) = jj
        end
    end    
end