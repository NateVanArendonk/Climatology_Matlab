%% Wind Rose
data_type = 'NCDC';
station_nm = 'Paine_Field';
options.nDirections = 24;
%sta_num = [1 2 3 4 5];
options.vWinds = [0 5 10 15 20 25]; %Specify the wind speeds that you want to appear on the windrose
options.AngleNorth = 0;
options.AngleEast = 90;
options.labels = {'North (360°)','South (180°)','East (90°)','West (270°)'};
options.TitleString = [];
%options.axes = ax;
%inds_w = (~isnan(O.wnddir) & ~isnan(O.wndspd));
[figure_handle,count,speeds,directions,Table] = WindRose(SS.wnddir,SS.wndspd,options);
%suptitle('Paine Field')


 outname = sprintf('WindRose_%s_%s',data_type,station_nm);
 hFig = gcf;
 hFig.PaperUnits = 'inches';
 hFig.PaperSize = [7 7];
 hFig.PaperPosition = [0 0 7 7];
 print(hFig,'-dpng','-r350',outname)
% 
% close(hFig)