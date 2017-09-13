%% r - value sensitivity analysis for GEV parameters
clearvars

%first load in the data
dir_nm = '../../COOPS_tides/';
%dir_nm = '../../hourly_data/gap_hourly/Station_Choice/';
station_name = 'Seattle';
station_nm = 'seattle';

load_file = strcat(dir_nm,station_nm,'/',station_nm,'_hrV');
load(load_file)
clear dir_nm file_nm load_file


%% Cursory Look
% clf
% plot(tides.time,tides.WL_VALUE)
% datetick


%% Collect maxima

% Years available
yr = year(tides.time(1)):year(tides.time(end));

% rth values to collect (can use less later)
r_num = 10;

% Min distance between events (half hour incr) 24 if half our, 12 if hour
min_sep = 12;

% Preallocate
data = zeros(length(yr),r_num);

% Loop
for yy=1:length(yr)
    inds = year(tides.time) == yr(yy);
    temp = tides.WL_VALUE(inds);
    for r=1:r_num
        [data(yy,r), I] = max(temp);
        pop_inds = max([1 I-min_sep]):min([length(temp) I+min_sep]);
        temp(pop_inds) = [];
    end
end


%% Estimate the GEV paramters


% limits
xlim = [.2 1];
xlim = [2.6 4];

clf
pdf_data = histogram(data(:,1),8,'Normalization','pdf');
hold on

pdf_data = histogram(data(:),8,'Normalization','pdf');

mycolors = jet(10);

for rth_num = 1:10
parmhat = gevfit_rth(data(:,1:rth_num));

temp = data(:,1:rth_num);
parmhat_sv = gevfit_rth(temp(:));


% GEV pdf 
x_axis = linspace(xlim(1),xlim(2),100);
pdf_gev = gevpdf(x_axis,parmhat(1),parmhat(2),parmhat(3)); 
pdf_gev_sv = gevpdf(x_axis,parmhat_sv(1),parmhat_sv(2),parmhat_sv(3)); 


plot(x_axis,pdf_gev,'Color',mycolors(rth_num,:))
plot(x_axis,pdf_gev_sv,'--','Color',mycolors(rth_num,:))

end

chan = colorbar;
colormap(mycolors)

legend('r=1','r=10')

chan.YTick = .05:.1:.95;
chan.YTickLabel = 1:10;
ylabel(chan,'r-value')
ylabel('Probability')
xlabel('Maximum yearly TWL [m]')
title('Seattle')

%% Save Plot 

cd('../../');
outname = sprintf('Rvalue_sensitivity_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)

%cd('../../../matlab/Climatology')
cd('matlab/Climatology')