function [ y_interp ] = interpShortGap( x, y, x_interp, maxInterpLength )
%[ y_interp ] = interpShortGap( x, y, x_interp, maxInterpLength )
%   x, y - data values, x may be unevenly distributed with gaps
%   x_inter - desired time series
%   maxInterpLength - maximum length to interpolate over, 
%       NOTE: in units of x_interp
%
%   Default to linear interopolation
    
% Interpolate everywhere
y_interp = interp1(x,y,x_interp,'linear');

% Find locations where gaps in x are greater than tolerance
locs = find(diff(x)>maxInterpLength);

% Set regions in x_interp where gaps are large to NaN
for nn=1:length(locs)
    inds = x_interp > x(locs(nn)) & x_interp < x(locs(nn)+1);
    y_interp(inds) = NaN;
end

end

