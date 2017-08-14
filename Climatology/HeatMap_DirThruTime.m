cl%% Load in Data
clearvars
dir_nm = '../../hourly_data/gap_hourly/';                                                     
file_nm = 'bham_airport';                                   
load_file = strcat(dir_nm,file_nm, '_hourly');
load(load_file)
clear dir_nm file_nm load_file

%%
y1 = year(time(1));
y2 = year(time(end));
x1 = 10;
xB = 8;
xB1 = 10;  % Use this to see if binning is occuring
xB2 = 20;  % Use this to plot coarser winds to show change thru time


[X,Y] = meshgrid(x1:x1:360,y1:1:y2);
Z = zeros(size(X));   % make empty grid
Z2 = zeros(size(X)); % Grid that will highlight heavy points
B = zeros(size(X)); % pdf grid

for y = 1:length(Y(:,1))                                                   % For every value in Y
    yr_ind = find(year(time) == Y(y));                                     % Find that current year
    if length(yr_ind) > 8760 * .5
        for x = 1:length(X(1,:))                                               % For every value in x
            if x == 1                                                          % First value only
                dir_ind = find(wnddir(yr_ind) <= X(1,x));                      % Find all directions between 0 and first threshold
                if isempty(dir_ind)                                            % If it's empty
                    Z(y,x) = 0;                                                % Set it equal to zero
                else
                    Z(y,x) = length(dir_ind);                                  % Otherwise populate Z with length of hits
                    if Z(y,x) > 500
                        Z2(y,x) = Z(y,x) + 1000;
                    else
                        Z2(y,x) = Z(y,x);
                    end
                end
            else
                dir_ind = find(wnddir(yr_ind) <= X(1,x) & wnddir(yr_ind) > X(1, x-1));  % Find all directions between current and 1 less threshold
                if isempty(dir_ind)
                    Z(y,x) = 0;
                else
                    Z(y,x) = length(dir_ind);
                    if Z(y,x) > 500
                        Z2(y,x) = Z(y,x) + 1000;
                    else
                        Z2(y,x) = Z(y,x);
                    end
                end
            end
        end
        B(y,:) = pdf('Normal', Z(y,:), 0, 1);  % Calculates PDF from data
    end
end

% Normalize the Data    
Znorm = Z - min(Z(:));
Znorm = Znorm ./ max(Znorm(:));
%Znorm = log(Znorm + .0001);

% Add the mean on top as a line 
yr_vec = year(time(1)):1:year(time(end));
yr_vec = yr_vec';
wnddir_mean = NaN(length(yr_vec),1);
for j = 1:length(yr_vec)
    yr_inds = find(year(time) == yr_vec(j));
    wnddir_mean(j) = mean(wnddir(yr_inds));
end

figure
%imagesc(10:10:360,yr1:1:yr2,log10(Z))
imagesc(x1:x1:360,y1:1:y2, Z2)
set(gca,'YDir','normal') % set to normal Y scale
colorbar
ylabel('Year')
xlabel('Wind Direction [degrees]')
title('Wind Direction Through Time')

hold on
line(wnddir_mean, yr_vec, 'Color', 'black')




%% Same plot but for winds above specific thresholds

spd_thresh = 10; % establish search parameter

spd_inds = find(wndspd > spd_thresh);

y1 = year(time(1));
y2 = year(time(end));
x1 = 10;
xB = 8;
xB1 = 10;  % Use this to see if binning is occuring
xB2 = 20;  % Use this to plot coarser winds to show change thru time


[X,Y] = meshgrid(x1:x1:360,y1:1:y2);
Z = zeros(size(X));   % make empty grid
Z2 = zeros(size(X)); % Grid that will highlight heavy points
B = zeros(size(X)); % pdf grid

for y = 1:length(Y(:,1))                                                   % For every value in Y
    yr_ind = find(year(time(spd_inds)) == Y(y));                                     % Find that current year
    for x = 1:length(X(1,:))                                               % For every value in x
        if x == 1                                                          % First value only
            dir_ind = find(wnddir(yr_ind) <= X(1,x));                      % Find all directions between 0 and first threshold
            if isempty(dir_ind)                                            % If it's empty
                Z(y,x) = 0;                                                % Set it equal to zero
            else
                Z(y,x) = length(dir_ind);                                  % Otherwise populate Z with length of hits
                if Z(y,x) > 500
                    Z2(y,x) = Z(y,x) + 1000;
                else
                    Z2(y,x) = Z(y,x);
                end
            end
        else
            dir_ind = find(wnddir(yr_ind) <= X(1,x) & wnddir(yr_ind) > X(1, x-1));  % Find all directions between current and 1 less threshold
            if isempty(dir_ind)
                Z(y,x) = 0;
            else
                Z(y,x) = length(dir_ind);
                if Z(y,x) > 500
                    Z2(y,x) = Z(y,x) + 1000;
                else
                    Z2(y,x) = Z(y,x);
                end
            end
        end
    end
    B(y,:) = pdf('Normal', Z(y,:), 0, 1);  % Calculates PDF from data
end

figure
%imagesc(10:10:360,yr1:1:yr2,log10(Z))
imagesc(x1:x1:360,y1:1:y2, Z)
set(gca,'YDir','normal') % set to normal Y scale
colorbar
ylabel('Year')
xlabel('Wind Direction [degrees]')
title('Wind Direction Through Time')


