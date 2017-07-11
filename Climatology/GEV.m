%% GEV Fit for Block Maxima

clearvars

%first load in the data
dir_nm = '/Users/andrewmcauliffe/Desktop/hourly_data/';
station_nm = 'Whidbey_NAS';
file_nm = 'whidbey_hourly'; % you will have to change this variable for each station
load_file = strcat(dir_nm,file_nm);
load(load_file)
clear dir_nm file_nm load_file
wnddir = wnddir';


% Find yearly max

yr_vec = year(time(1)):year(time(end)); %make a year vec

maxima = NaN(length(yr_vec),1); %create vector to house all of the block maxima
for i = 1:length(yr_vec)
    yr_ind = find(year(time) == yr_vec(i));
    %max_val = max(wndspd(yr_ind));
    maxima(i) = max(wndspd(yr_ind));
end
clear i
% Get GEV statistics about the data
[paramEsts, paramCIs] = gevfit(maxima);
kMLE = paramEsts(1);        % Shape parameter
sigmaMLE = paramEsts(2);    % Scale parameter
muMLE = paramEsts(3);       % Location parameter
%% Plot the GEV
% histogram(maxima,min(maxima)/1.1:1.1*max(maxima),'FaceColor',[.8 .8 1])
% xgrid = linspace(min(maxima)/1.1,1.1*max(maxima),1000);
% line(xgrid,gevpdf*10(xgrid,kMLE,sigmaMLE,muMLE));
% 
% p = gevpdf(y,kMLE,sigmaMLE,muMLE);
% line(y,.25*length(maxima)*p,'color','r')


%% Plot Hist and GEV
uprbnd = 1.1*max(maxima); %upper bound
lowerBnd = min(maxima)/1.1;  %lower bound
bins = floor(lowerBnd):ceil(uprbnd);  %number of bins
h = bar(bins,histc(maxima,bins)/length(maxima),'histc'); %plot the hist
h.FaceColor = [.9 .9 .9]; %coloring
ygrid = linspace(lowerBnd,uprbnd,100);  %line for GEV fit
line(ygrid,gevpdf(ygrid,kMLE,sigmaMLE,muMLE));  %plot the line
xlabel('Block Maximum');
ylabel('Probability Density');
xlim([lowerBnd uprbnd]);


tbox = sprintf('mu = %4.2f \nsigma = %4.2f \nk = %4.2f',paramEsts(1),paramEsts(2),paramEsts(3));
%text(ax.XLim(1)*1.01,ax.YLim(2)*.9,tbox)
text(20,0.3, tbox)


%% Save the Plot
outname = sprintf('GEV_%s',station_nm);
hFig = gcf;
hFig.PaperUnits = 'inches';
hFig.PaperSize = [8.5 11];
hFig.PaperPosition = [0 0 7 7];
print(hFig,'-dpng','-r350',outname) %saves the figure, (figure, filetype, resolution, file name)
close(hFig)


%%