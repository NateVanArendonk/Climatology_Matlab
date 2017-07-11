temp = struct();
temp.x = [];
for i = 1:length(trans);
    temp.x(end+1) = str2double(trans(i,1));
    