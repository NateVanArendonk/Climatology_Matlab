%% Create a matrix of yearly data with each row being a year of the data

%load in the data
load('/Users/andrewmcauliffe/Desktop/Matlab/Matlab_Structure/downloaded station data/Whidbey_hourly.mat')


%create a year vector of all the years in the data
yr_vec = year(time(1)):year(time(end));

yr_index = NaN(length(yr_vec),1);

%Make a large matrix to houes all the data
data_mat = NaN(length(yr_vec), 8760);  %This will trim the data a little a make it more even and negate leap years
count = 0;

for i = 1:length(yr_vec)
    cur_index = find(year(time) == yr_vec(i),1); %find the first instance of the year
    yr_index(i) = cur_index;  %Add indices to the empty vector
end

%% Now that I have the indicies, I will create a matrix with each row corresponding to one year
for i = 1:length(yr_vec)
    if i < 73
        data_mat(i,:) = wndspd(i:i+1);
    else 
        data_mat(i,:) = wndspd(i:end);
    end
end
    
        

