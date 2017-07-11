fileID = fopen('painfield_extra.txt');
formatSpec = '%s';
N = 32786;
paine = textscan(fileID, formatSpec,'%d %d %d %d %d %d %d %d %d %d %d %f %d %d %d %d %d %d %d %d %d %d %d %f %d %f %d %d %d %d %d %d %d'...
    , 'headerLines', 33, 'Delimiter',' ',N);
fclose(fileID)

