function [ wspd_scaled ] = scaleWindPowerLaw( wspd, ref_height, scaled_height, surface_type )
%[ wspd_scaled ] = scaleWind( wspd, ref_height, scaled_height, surface_type )
%   Using wind speed power law, scale from reference to new height
%   Surface type must be 'land' or 'sea'
%   Assumptions include stable atmospheric conditions
%   Reference: Hsu, S. A., Meindl, E. A., & Gilhousen, D. B. (1994). 
%   Determining the Power-Law Wind-Profile Exponent under Near-Neutral 
%   Stability Conditions at Sea. Journal of Applied Meteorology, 33(6), 
%   757?765. http://doi.org/10.1175/1520-0450(1994)033<0757:DTPLWP>2.0.CO;2

validStrings = {'land', 'sea'};
valid_surface = validatestring(surface_type,validStrings);

switch valid_surface
    case 'land'
        p = 0.14;
    case 'sea'
        p = 0.11;
end

wspd_scaled = wspd.*(scaled_height./ref_height).^p;   %ref_height and wspd are known, scaled height = 10

end