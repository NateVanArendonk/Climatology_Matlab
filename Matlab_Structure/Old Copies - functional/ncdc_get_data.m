function out = working(usaf,wban,dates,station_name)
%   Retrieve NCDC data from FTP site located here: 
%   ftp://ftp.ncdc.noaa.gov/pub/data/noaa/
%   
%   List of stations can be found here:
%   ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.txt
%   
%   *****Important to note that if the USAF number starts with a ZERO, put the
%   station number in single quotes*********  
%   
%   Code to download .gz files from NOAA NCDC ftp site 
%   and unzip the files. 
%   Written by N. VanArendonk, 2016/17
%
%   Dates can be either a single year or multiple year span to work through
%   [date1 date2].
%   
%   Put larger year first eg. 2010 compared to 1990, 2010 goes in date1
%   spot. 
%   
%   This program will only download the data and return .csv files, if you
%   want a data structure, use ncdc_structure.m. It calls the same
%   variables.
%
%   
%
%   
%
%%

%Initialize some empty variables
date_str = [];
usaf_str = [];
wban_str = [];
dash = '-';
under_sc = '_';
ftype = '.gz';
cur_dir = pwd; 

%Now for the fun part, iterations
if length(dates) == 1;
    %Make a new directorty on desktop 
    folder_nm = upper(station_name);
    mkdir(folder_nm);
    
    %copy java files from current directory into newly created directory 
    copyfile('ishJava.class',strcat(cur_dir,'/',folder_nm));
    copyfile('ishJava.java',strcat(cur_dir,'/',folder_nm));
    copyfile('ncdc_parse_working.m',strcat(cur_dir,'/',folder_nm));
    copyfile('csv_import.m',strcat(cur_dir,'/',folder_nm));
    %change to newly created directory
    cd(folder_nm);
    
    %convert date, usaf, wban from num 2 str
    date_str = num2str(dates);  
    usaf_str = num2str(usaf);
    wban_str = num2str(wban);
    
    %%Open up the ftp site 
    data_source = ftp('ftp.ncdc.noaa.gov');  

%Now change directory to /pub/data/noaa to access years with downloadable
%data.
    cd(data_source,'pub/data/noaa');
    cd(data_source,date_str);  %change to directy of inital date
    file_name = strcat(usaf_str,dash,wban_str,dash,date_str,ftype);  %create file name
    st_yr = strcat(station_name,date_str);
    unzpd = mget(data_source,file_name,st_yr);  %get unzipped file and store it in newly created folder
    cd(st_yr)
    gunzip('*.gz')
    close(data_source)
    delete(file_name);
    
    %now parse the data
    file_out = strcat(folder_nm,under_sc,date_str,'.csv');
    ncdc_parse_working(file_use,file_out)
    
    
else
    %calculate difference in user input dates
    date_dif = dates(1) - dates(2);
    counter = 0;
    
    %Make a new directorty on desktop 
    folder_nm = upper(station_name);
    mkdir(folder_nm);
    
    %copy java files from current directory into newly created directory 
    copyfile('ishJava.class',strcat(cur_dir,'/',folder_nm));
    copyfile('ishJava.java',strcat(cur_dir,'/',folder_nm));
    copyfile('ncdc_parse_working.m',strcat(cur_dir,'/',folder_nm));
    copyfile('csv_import.m',strcat(cur_dir,'/',folder_nm));
    %change to new directory
    cd(folder_nm);
    
    %loop through all dates specified by user and retrieve FTP data, unzip
    %and parse
    for x = 0:date_dif
        date_use = dates(1) - counter;
        date_str = num2str(date_use);  %convert date, usaf, wban from num 2 str
        usaf_str = num2str(usaf);
        wban_str = num2str(wban);
        
        %%Open up the ftp site 
        data_source = ftp('ftp.ncdc.noaa.gov');
        %Now change directory to /pub/data/noaa to access years with downloadable
        %data.
        
        
        %Change to directory on NCDC site
        cd(data_source,'pub/data/noaa');
        %change to directy of inital date
        cd(data_source,date_str);
        %create file name of USAF-WBAN-Date to be used for data retrival 
        file_name = strcat(usaf_str,dash,wban_str,dash,date_str,ftype);
        %file_use has same as file_name but without .gz
        file_use = strcat(usaf_str,dash,wban_str,dash,date_str);
        
        %create variable for station name_date
        st_yr = strcat(station_name,date_str);
        
        %get unzipped file and store it in newly created folder
        unzpd = mget(data_source,file_name);  
        
        %unzip all files ending in .gz
        gunzip('*.gz');
        %remove .gz file
        delete(file_name);
        %add 1 to the counter 
        counter = counter + 1;
        %close ftp source 
        close(data_source)
        
        %now parse the data by calling parse function
        file_out = strcat(folder_nm,under_sc,date_str,'.csv');
        ncdc_parse_working(file_use,file_out)
        
        
        
        %Now change back to directory with STATION NAME to run code again
        folder_chg = strcat(cur_dir,'/',folder_nm);
        cd(folder_chg);
    end
    
%now delete the Java and parse files from station folder
delete('ishJava.class');
delete('ishJava.java');
delete('ncdc_parse_working.m');

    
end
%delete('csv_import.m')
%cd(cur_dir);


end





