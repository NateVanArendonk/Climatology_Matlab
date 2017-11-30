%% GEV Test
clearvars

%first load in the data
dir_nm = '../../COOPS_tides/';
%dir_nm = '../../hourly_data/gap_hourly/Station_Choice/';
station_name = 'Seattle';
station_nm = 'seattle';

load_file = strcat(dir_nm,station_nm,'/',station_nm,'_hrV');
load(load_file)
clear dir_nm file_nm load_file
%% Collect maxima

% Years available
yr = year(tides.time(1)):year(tides.time(end));

% rth values to collect (can use less later)
r_num = 10;

% Min distance between events (half hour incr) 24 if half our, 12 if hour
min_sep = 12;

% Preallocate
maxima = zeros(length(yr),r_num);

% Loop
for yy=1:length(yr)
    inds = year(tides.time) == yr(yy);
    temp = tides.WL_VALUE(inds);
    for r=1:r_num
        [maxima(yy,r), I] = max(temp);
        pop_inds = max([1 I-min_sep]):min([length(temp) I+min_sep]);
        temp(pop_inds) = [];
    end
end

% Grab only three values and vectorize it 
maxima = maxima(:,1:3); maxima = maxima(:);
[parmhat, paramCI] = gevfit(maxima);

%%  Print out values for 

fprintf('Parameters found: \n')
disp(['--------------------------------------------'])
disp(['k','               ',num2str(parmhat(1),4)])
disp(['mu','              ',num2str(parmhat(2),4)])
disp(['sigma','           ',num2str(parmhat(3),4)])
disp(['---------------------------------------------'])
fprintf('\n\n')

%%

% cdf of GEV
X = linspace(min(maxima),3*max(maxima),1e4); 
F0  = gevcdf(X,parmhat(1),parmhat(2),parmhat(3)); 
% Return period R
R = 1./(1-F0); % matlab

% Find return period
[~,ind_2] = min(abs(R(1,:)-2));
[~,ind_5] = min(abs(R(1,:)-5));
[~,ind_10] = min(abs(R(1,:)-10));
[~,ind_25] = min(abs(R(1,:)-25));
[~,ind_50] = min(abs(R(1,:)-50));
[~,ind_100] = min(abs(R(1,:)-100));
[~,ind_200] = min(abs(R(1,:)-200));
[~,ind_500] = min(abs(R(1,:)-500));
[~,ind_1000] = min(abs(R(1,:)-1000));


fprintf('Prediction of extreme Total Water Levels: \n')


% val = [X(ind_2);X(ind_5);X(ind_10);X(ind_25);X(ind_50);X(ind_100);X(ind_200);X(ind_500);X(ind_1000)];
% disp('--------------------------------------------------------------------------------------------')
% disp(['Return period (years)','              Predicted       gust       speed       (m/s)'])
% disp(['--------------------- ',' ------------------------------------------------------------------'])
% disp(['       ','(Matlab)'])



disp(['2',',num2str(val(1,4),3)])'
disp(['5',',num2str(val(2,4),3)])'
disp(['10'',num2str(val(3,4),3)])'    
disp(['25',   ',num2str(val(4,4),3)])'
disp(['50',   ',num2str(val(5,4),3)])'
disp(['100',  ',num2str(val(6,4),3)])'
disp(['200',  ',num2str(val(7,4),3)])'
disp(['500',  ',num2str(val(8,4),3)])'
disp(['1000', ',num2str(val(9,4),3)])'

% 
% disp(['--------------------------------------------------------------------------------------------'])
% 
% val = [X(ind_50);X(ind_100);X(ind_200);X(ind_500);X(ind_1000)];
% disp(['--------------------------------------------------------------------------------------------'])
% disp(['Return period (years)','              Predicted       gust       speed       (m/s)'])
% disp(['--------------------- ',' ------------------------------------------------------------------'])
% disp(['       ','                  (Gumbel)','       (Gringorten)','       (moments)','       (Matlab)'])
% disp(['50','                        ',num2str(val(1,1),3),'           ',num2str(val(1,2),3),'               ',num2str(val(1,3),3),'             ',num2str(val(1,4),3)])
% disp(['100','                       ',num2str(val(2,1),3),'             ',num2str(val(2,2),3),'               ',num2str(val(2,3),3),'             ',num2str(val(2,4),3)])
% disp(['200','                       ',num2str(val(3,1),3),'           ',num2str(val(3,2),3),'                 ',num2str(val(3,3),3),'             ',num2str(val(3,4),3)])
% disp(['500','                       ',num2str(val(4,1),3),'           ',num2str(val(4,2),3),'               ',num2str(val(4,3),3),'             ',num2str(val(4,4),3)])
% disp(['1000','                      ',num2str(val(5,1),3),'           ',num2str(val(5,2),3),'                 ',num2str(val(5,3),3),'             ',num2str(val(5,4),3)])
% disp(['--------------------------------------------------------------------------------------------'])


