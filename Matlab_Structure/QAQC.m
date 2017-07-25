clearvars
% load the data
dir_nm = '../../';
file_loc = 'hourly_data/';
file_nm = 'van_airport';
load(strcat(dir_nm, file_loc, file_nm, '_hourly.mat'))
clear dir_nm file_loc file_nm

% 8760 hours in a year 

%% Check Yearly Max's
yr_vec = year(time(1)):year(time(end)); %make a year vec
maxima = NaN(length(yr_vec),1); %create vector to house all of the block maxima
for i = 1:length(yr_vec)
    yr_ind = find(year(time) == yr_vec(i));
    % If there is more than 50% of the hours missing for that year, I will
    % skip it
    if length(yr_ind) < 8760 * .5
        continue
    else
    %max_val = max(wndspd(yr_ind));
        maxima(i) = max(wndspd(yr_ind));
    end
end

del_ind = find(maxima < 10);   % find indices less than 10, likely indicating poor data coverage or a large data gap
maxima(del_ind) = []; % get rid of data
yr_vec(del_ind) = []; % get rid of year from year vec










