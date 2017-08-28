%% Load in Data
clearvars
dir_nm = '../../hourly_data/gap_hourly/';                                                     
file_nm = 'whidbey_nas';                                   
load_file = strcat(dir_nm,file_nm, '_hourly');
load(load_file)
clear dir_nm load_file

%%
y1 = year(time(1));
y2 = year(time(end));
x1 = 960;
xB = 5;
xB1 = 10;  % Use this to see if binning is occuring
xB2 = 20;  % Use this to plot coarser winds to show change thru time

slp_thresh = 980;


[X,Y] = meshgrid(x1:xB:990,y1:1:y2);
Z = zeros(size(X));   % make empty grid
Z2 = zeros(size(X)); % Grid that will highlight heavy points
B = zeros(size(X)); % pdf grid
Zspd = zeros(size(X)); 

for y = 1:length(Y(:,1))                                                   % For every value in Y
    yr_ind = find(year(time) == Y(y));                                     % Find that current year
    if length(yr_ind) > 8760 * .5
        for x = 1:length(X(1,:))                                               % For every value in x
            if x == 1                                                          % First value only
                slp_ind = find(slp(yr_ind) <= X(1,x));                      % Find all directions between 0 and first threshold
                if isempty(slp_ind)                                            % If it's empty
                    Z(y,x) = 0;                                                % Set it equal to zero
                else
                    Z(y,x) = length(slp_ind);                                  % Otherwise populate Z with length of hits

            
                end
            else
                slp_ind = find(slp(yr_ind) <= X(1,x) & slp(yr_ind) > X(1, x-1));  % Find all directions between current and 1 less threshold
                if isempty(slp_ind)
                    Z(y,x) = 0;
                else
                    Z(y,x) = length(slp_ind);
                end
            end
        end
        B(y,:) = pdf('Normal', Z(y,:), 0, 1);  % Calculates PDF from data
    end
end

% Normalize the Data    
Znorm = Z - min(Z(:));
Znorm = Znorm ./ max(Znorm(:)); % 
%Znorm = log(Znorm + .0001);

%%

figure
%imagesc(10:10:360,yr1:1:yr2,log10(Z))
imagesc(x1:xB:990,y1:1:y2, Z)
set(gca,'YDir','normal') % set to normal Y scale
colorbar
ylabel('Year')
xlabel('Sea Level Pressure [mbar]')
title('SLP Through Time')
caxis([0,10])

xlim([960 990])






%% Save the Plot
cd('../../Matlab_Figures/HeatMap/New')

outname = sprintf('HeatMap_%s',file_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

cd('../../../matlab/Climatology')


%% Same plot but for winds above specific thresholds
% % % 
% % % spd_thresh = 10; % establish search parameter
% % % 
% % % spd_inds = find(wndspd > spd_thresh);
% % % 
% % % y1 = year(time(1));
% % % y2 = year(time(end));
% % % x1 = 10;
% % % xB = 8;
% % % xB1 = 10;  % Use this to see if binning is occuring
% % % xB2 = 20;  % Use this to plot coarser winds to show change thru time
% % % 
% % % 
% % % [X,Y] = meshgrid(x1:x1:360,y1:1:y2);
% % % Z = zeros(size(X));   % make empty grid
% % % Z2 = zeros(size(X)); % Grid that will highlight heavy points
% % % B = zeros(size(X)); % pdf grid
% % % 
% % % for y = 1:length(Y(:,1))                                                   % For every value in Y
% % %     yr_ind = find(year(time(spd_inds)) == Y(y));                                     % Find that current year
% % %     for x = 1:length(X(1,:))                                               % For every value in x
% % %         if x == 1                                                          % First value only
% % %             dir_ind = find(wnddir(yr_ind) <= X(1,x));                      % Find all directions between 0 and first threshold
% % %             if isempty(dir_ind)                                            % If it's empty
% % %                 Z(y,x) = 0;                                                % Set it equal to zero
% % %             else
% % %                 Z(y,x) = length(dir_ind);                                  % Otherwise populate Z with length of hits
% % %                 if Z(y,x) > 500
% % %                     Z2(y,x) = Z(y,x) + 1000;
% % %                 else
% % %                     Z2(y,x) = Z(y,x);
% % %                 end
% % %             end
% % %         else
% % %             dir_ind = find(wnddir(yr_ind) <= X(1,x) & wnddir(yr_ind) > X(1, x-1));  % Find all directions between current and 1 less threshold
% % %             if isempty(dir_ind)
% % %                 Z(y,x) = 0;
% % %             else
% % %                 Z(y,x) = length(dir_ind);
% % %                 if Z(y,x) > 500
% % %                     Z2(y,x) = Z(y,x) + 1000;
% % %                 else
% % %                     Z2(y,x) = Z(y,x);
% % %                 end
% % %             end
% % %         end
% % %     end
% % %     B(y,:) = pdf('Normal', Z(y,:), 0, 1);  % Calculates PDF from data
% % % end
% % % 
% % % figure
% % % %imagesc(10:10:360,yr1:1:yr2,log10(Z))
% % % imagesc(x1:x1:360,y1:1:y2, Z)
% % % set(gca,'YDir','normal') % set to normal Y scale
% % % colorbar
% % % ylabel('Year')
% % % xlabel('Wind Direction [degrees]')
% % % title('Wind Direction Through Time')
% % % 
% % % 
