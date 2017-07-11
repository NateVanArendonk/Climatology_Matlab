function structure = ncdc_structure(usaf,wban,dates,station_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Code to create a data structure from .csv files of station data
%Written by N.VanArendonk 2016/17

%Note, this function calls other functions, and depending on the number of
%dates you are looking to download, can take a while to run (10 - 20 min)

%Upon completion of each run, name the data structures one, two, three,
%etc.

%When fully finished getting all the data, use structure combine to
%concatenate one structure 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%run function to get ncdc data
%This will make a folder same as station_name and house all the dates of
%the station data that is user specified 
ncdc_get_data(usaf,wban,dates,station_name)

%%
%Initialize data structure with data from first year of dates
station_nm = upper(station_name);
date_1 = num2str(dates(1));
file_import = strcat(station_nm,'_',date_1,'.csv');
station_data = csv_import(file_import);
%adds station_data variable from function to matlab workspace
assignin('base','station_data',csv_import(file_import))

date_dif = dates(1) - dates(2);
counter = 1;
date_iter = dates(1) - counter;

%%
%loop through the number of years between user defined dates 
for x = 1:date_dif
    date_use = dates(1) - counter;
    date_str = num2str(date_use);
    station_nm = upper(station_name);
    file_import = strcat(station_nm,'_',date_str,'.csv');
    stn_yr = strcat(station_name,'_',date_str);    
    %run csv import    
    temp_struct = csv_import(file_import);
    %bring in the temp structure
    assignin('base','temp_struct',temp_struct)
    counter = counter + 1;
    
        for x = 2:length(temp_struct.USAF);
            station_data.USAF(end+1) = temp_struct.USAF(x);
            station_data.WBAN(end+1) = temp_struct.WBAN(x);
            station_data.YR(end+1) = temp_struct.YR(x);
            station_data.MO(end+1) = temp_struct.MO(x);
            station_data.DA(end+1) = temp_struct.DA(x);
            station_data.HR(end+1) = temp_struct.HR(x);
            station_data.MN(end+1) = temp_struct.MN(x);
            station_data.DIR(end+1) = temp_struct.DIR(x);
            station_data.SPD(end+1) = temp_struct.SPD(x);
            station_data.GUS(end+1) = temp_struct.GUS(x);
            station_data.TEMP(end+1) = temp_struct.TEMP(x);
            station_data.DEWP(end+1) = temp_struct.DEWP(x);
            station_data.SLP(end+1) = temp_struct.SLP(x);
            station_data.ALT(end+1) = temp_struct.ALT(x);
            station_data.STP(end+1) = temp_struct.STP(x);
            station_data.PCP01(end+1) = temp_struct.PCP01(x);
            station_data.PCP06(end+1) = temp_struct.PCP06(x);
            station_data.PCP24(end+1) = temp_struct.PCP24(x);          
        end
    clear temp_struct    
    
end
 assignin('base','station_data',station_data)  
 clear temp_struct
end















