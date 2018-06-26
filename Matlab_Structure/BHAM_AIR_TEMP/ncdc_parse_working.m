function out = ncdc_parse_working(file_name,file_output)
%Run Java program to parse data
%   

%now run java script to parse the data
space = ' ';
java = 'java';
java_file = 'ishJava';
unix_run = char(strcat({java},{space},{java_file},{space},{file_name},{space},{file_output}));
unix(unix_run);
delete(file_name);


end

