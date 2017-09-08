function [ data_interp ] = interpShortNaN( data_x, data_y, maxInterpLength )
%[ data_interp ] = interpShortNaN( data_x, data_y, maxInterpLength )
%   Linearly interpolate data unless stretches of NaN values exceed
%   specified maxInterpLength
%       data_x, data_y must be row vectors
%       maxInterpLength must be an integer
%       Assumes reguarly spaced data_x values

% Check if row
if ~isrow(data_x) || ~isrow(data_y)
    error('data must be row vector')
end

% Linear interpolate data to NaNs regardless of missing length
inds = ~isnan(data_y);
data_interp = interp1(data_x(inds),data_y(inds),data_x,'linear');

% Locate NaNs
temp = isnan(data_y); 

%Create char vector, where B's are the NaNs, A's are not
temp = char(temp+'A'); 

%Find start/end indices of strings of B greater than maxInterpLength
myreg = sprintf('B{%d,}',maxInterpLength);
[a, b] = regexp( temp, myreg, 'start', 'end' ); 

% Fill in located regions with NaN values
for nn=1:length(a)
    data_interp(a(nn):b(nn))=NaN;
end

end

