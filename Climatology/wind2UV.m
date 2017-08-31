function out = wind2UV(direct, deg, type, spd)
 
% direct = wind coming from or winds going, in reference to degree
    % For this variable please input 'to' or 'from'
% deg = degree of wind direction
% type = cartesian or compass for degree of original winds
    % For this variable please input 'compass' or 'cartesian' 
% wndspd = speed of winds
 
 
% ex. wind2UV('from', 315, 'compass', 10)
 
 
if ~length(strfind(type, 'CART')) == 1 % if the wind type is compass
    if strcmpi(direct, 'FROM') % if the winds are given as coming from instead of going
        if deg > 180 && deg < 360% Convert winds to where they are going 
            deg = deg - 180;
        elseif deg == 360
            deg = 180;  
        else
            deg = deg + 180;
        end
    % Now convert from compass to cartesian
    deg = 90 - deg;
    end
else  % Otherwise, if the winds are already in cartesian
    if strcmpi(direct, 'FROM') % if the winds are given as coming from instead of going
        if deg > 180 && deg < 360
            deg = deg - 180;
        elseif deg == 360
            deg = 180;
        else
            deg = deg + 180;
        end
    end
end
    
 
% Now break down into U and V components
out.u = spd*(cosd(deg));
out.v = spd*(sind(deg));
 
 
%assignin('base', 'out', out)
 
 
 
end
 
    
    
    
    
 
 
 
 
 

