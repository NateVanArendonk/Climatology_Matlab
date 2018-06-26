% Test of new format for downloading NCDC data
clearvars

% --- Load in list of NCDC weather stations and find those in WA
% fname = 'station_list.csv';
% delimiter = ',';
% startRow = 2;
% formatSpec = '%q%q%q%q%q%q%q%q%q%q%q%[^\n\r]';
% fileID = fopen(fname,'r');
% data = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
% fclose(fileID);
% usaf = data{1};
% wban = data{2};
% name = data{3};
% country = data{4};
% state = data{5};
% lat = data{7};
% lon = data{8};
% elev = data{9};
% t_start = data{10};
% t_end = data{11};
% 
% la = double(lat);
% lo = double(lon);
% 
% % inds = find(state == 'WA' & lo >= -129 & lo <= -122);
% inds = find(country == 'CA' & lo >= -129 & lo <= -122 & la <= 51.5);
% % 
% S.usaf = usaf(inds);
% S.wban = wban(inds);
% S.name = name(inds);
% S.lat = str2double(lat(inds));
% S.lon = str2double(lon(inds));
% S.elev = str2double(elev(inds));
% S.t_start = t_start(inds);
% S.t_end = t_end(inds);
% save('WA_Stations','-struct','S')
load('WA_Stations.mat')

% save('CA_Stations','-struct','S')
% load('CA_Stations')
%% Loop through and grab each stations data

time = 1940:1:2018;
for ii = 1%:length(lat)
    dir_nm = char(name(ii));
    if contains(dir_nm,'/')
        slash_ind = strfind(dir_nm,'/');
        dir_nm = dir_nm(1:(slash_ind-1));
    end
    if contains(dir_nm,'.')
        period_ind = strfind(dir_nm,'.');
        dir_nm = dir_nm(1:(period_ind-1));
    end
    % If this is the first station - make a directory and store all the
    % info in it
    if ~exist(dir_nm,'dir')
        % Make Directory
        mkdir(dir_nm)
        % Copy Files for parsing into directory
        copyfile('ishJava.class',dir_nm);
        copyfile('ishJava.java',dir_nm);
        copyfile('ncdc_parse_data.m',dir_nm);
        % Change in to directory
        cd(dir_nm)
    else
        % Otherwise if this is a repeat station with a different set of
        % data, find out how many previous stations there are and name
        % accordingly
        
        % Get al files in directory
        file = dir('*');
        % Get the file names
        filenames = {file.name};
        % Find out how many files of the current station exist
        num_files = sum(contains(filenames,dir_nm));
        % Make a new folder with n+1 as the end to house new time period of
        % data
        dir_nm = sprintf('%s_%d',dir_nm,(num_files + 1));
        mkdir(dir_nm)
        % Copy files in to directory for parsing data
        copyfile('ishJava.class',dir_nm);
        copyfile('ishJava.java',dir_nm);
        copyfile('ncdc_parse_data.m',dir_nm);
        % Change in to directory
        cd(dir_nm)
    end
    
    %Open up the ftp site
    ftp_site = ftp('ftp.ncdc.noaa.gov','ftp','vanaren@wwu.edu');
    
    % Loop through dates
    for tt = 1:length(time)
        
        % Current year of iteration
        cur_year = time(tt);
        
        % Name of .gz file that will be downloaded from FTP
        data_file = sprintf('%s-%s-%d.gz',usaf(ii),wban(ii),cur_year);
        
        %Change to directory on NCDC FTP site of date
        if tt == 1 % If it's the first year, map to the correct directory and date
            date_dir = sprintf('pub/data/noaa/%d',cur_year);
            cd(ftp_site,date_dir);
        else % otherwise we are already in the correct directory, just back out a folderyear and move to the correct year
            date_dir = sprintf('../%d',cur_year);
            cd(ftp_site,date_dir);
        end
        
        % Get the data
        try
            % Get .gz file from ftp site
            mget(ftp_site,data_file);
            
            %unzip all files ending in .gz
            gunzip('*.gz');
            %remove .gz file
            delete(data_file);
            
            % Parse the data into a .csv file using the parsing code
            % supplied from FTP site
            unzipped_file = sprintf('%s-%s-%d',usaf(ii),wban(ii),cur_year);
            file_out = sprintf('%s-%s-%d.csv',usaf(ii),wban(ii),cur_year);
            ncdc_parse_data(unzipped_file,file_out)
            fprintf('%s for year %d has been downloaded and stored in csv\n',dir_nm,cur_year);
            
        catch
            % Try Twice
            try
                mget(ftp_site,data_file);
                
                %unzip all files ending in .gz
                gunzip('*.gz');
                %remove .gz file
                delete(data_file);
                
                % Parse the data into a .csv file using the parsing code
                % supplied from FTP site
                unzipped_file = sprintf('%s-%s-%d',usaf(ii),wban(ii),cur_year);
                file_out = sprintf('%s-%s-%d.csv',usaf(ii),wban(ii),cur_year);
                ncdc_parse_data(unzipped_file,file_out)
                fprintf('%s for year %d has been downloaded and stored in csv\n',dir_nm,cur_year);
            catch
                % Print out Missing Time and move on
                fprintf('%s does not have %d - Moving On\n',dir_nm,cur_year);
            end
        end
        close(ftp_site);
    end
    
    % Get list of all newly created csv's
    csv = dir('*.csv');
    % Format of file for reading in csv's
    formatSpec = '%6s%6s%5s%2s%2s%2s%2s%4s%4s%4s%4s%4s%2s%2s%2s%5s%3s%3s%3s%3s%3s%3s%3s%3s%2s%5s%5s%7s%6s%7s%4s%4s%6s%6s%6s%6s%s%[^\n\r]';
    
    % Go through each csv and extract the data
    if ~isempty(csv)
        for nn = 1:length(csv)
            csv_name = csv(nn).name;
            % Open File
            fid = fopen(csv_name,'r');
            % Grab the data
            data = textscan(fid, formatSpec, 'Delimiter', '', 'WhiteSpace', '',  'ReturnOnError', false);
            % Close the file
            fclose(fid);
            
            % columns of data we care about
            data_want = [1 2 3 4 5 6 7 8 9 10 28 29 30];
            
            % Initialize matrix to house new data
            new_data = zeros(length(data{1})-1,length(data_want));
            
            % Loop through the data and replace '***' missing values with NaNs
            % and Get the ones we want
            for cc = 1:length(data_want)
                % Grab the specific column of data
                cur_column = data{data_want(cc)};
                cur_column(1) = []; % Remove the header
                % Replace any Empty values with NaNs
                for mm = 1:length(cur_column)
                    if contains(cur_column{mm},'*')
                        cur_column{mm} = 'NaN';
                    end
                end
                % Convert cell to double array
                temp_d = str2double(cur_column);
                % Populate new matrix with values
                new_data(:,cc) = temp_d;
            end
            
            % Populate structure with data values
            if nn == 1 % if it is the first one, initialize the structure and remove header from data
                O.usaf = new_data(:,1); %O.usaf(1) = [];
                O.wban = new_data(:,2); %O.wban(1) = [];
                O.yr = new_data(:,3); %O.yr(1) = [];
                O.mo = new_data(:,4); %O.mo(1) = [];
                O.da = new_data(:,5); %O.da(1) = [];
                O.hr = new_data(:,6); %O.hr(1) = [];
                O.mn = new_data(:,7); %O.mn(1) = [];
                O.wnddir = new_data(:,8); %O.wnddir(1) = [];
                O.spd = new_data(:,9); %O.spd(1) = [];
                O.gust = new_data(:,10); %O.gust(1) = [];
                O.slp = new_data(:,11); %O.slp(1) = [];
                O.alt = new_data(:,12); %O.alt(1) = [];
                O.stp = new_data(:,13); %O.stp(1) = [];
                O.lat = lat(ii);
                O.lon = lon(ii);
                O.name = name(ii);
                O.elev = elev(ii);
            else % Otherwise, add values on to end of structure
                O.usaf = [O.usaf; new_data(:,1)];
                O.wban = [O.wban; new_data(:,2)];
                O.yr = [O.yr; new_data(:,3)];
                O.mo = [O.mo; new_data(:,4)];
                O.da = [O.da; new_data(:,5)];
                O.hr = [O.hr; new_data(:,6)];
                O.mn = [O.mn; new_data(:,7)];
                O.wnddir = [O.wnddir; new_data(:,8)];
                O.spd = [O.spd; new_data(:,9)];
                O.gust = [O.gust; new_data(:,10)];
                O.slp = [O.slp; new_data(:,11)];
                O.alt = [O.alt; new_data(:,12)];
                O.stp = [O.stp; new_data(:,13)];
            end
            fprintf('%d out of %d added to structure for %s\n',nn,length(csv),dir_nm)
        end
        % Delete Files from Directory
        delete('ishJava.class');
        delete('ishJava.java')
        delete('ncdc_parse_data.m');
        cd('/Users/andrewmcauliffe/desktop/Data_Download_New')
        save(dir_nm,'-struct','O')
        move_name = sprintf('%s.mat',dir_nm);
        movefile(move_name,'station_data')
        clear O
    end
    fprintf('%s is complete:%d out of %d - moving on to next station\n',dir_nm,ii,length(lat))
end
