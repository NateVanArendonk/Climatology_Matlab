function tide_filt = filter_tides( tide )
% tide_filt = filter_tides( tide )
% Estimates NTR (non-tidal-residual) following methods in:
%   Bromirski, P. D., Flick, R. E., & Cayan, D. R. (2003). Storminess variability along the California coast: 1858-2000. Journal of Climate, 16(6), 982–993. https://doi.org/10.1175/1520-0442(2003)016<0982:SVATCC>2.0.CO;2
%
% Inputs expected in 0.5 hour interval, without NaN values
% time must de-duped
%
% Processed in 4096-hour records
% First and last 4096/2 hours set to NaN due to window edge effects
%
% S. C. Crosby 09/05/17

% Tide frequencies to remove (Set by hand based on observed frequencies and bandwiths)
filt_fr_cen = [0.9677 1.9154 2.9567 3.9344 4.8780 5.7971 6.7606 7.7796 8.7273 9.7561]; % [cpd]
filt_fr_left = [0.842 1.787 2.721 3.770 4.664 5.602 6.60 7.64 8.591 9.57]; % [cpd]
filt_bw = 2*(filt_fr_cen-filt_fr_left); % [cpd]

% Constants
N = 2^13+1; %8193 (2 x 4096 + 1)
N_short = 2^13;
df = 48;
dt = 1/df;
cen_inds = (N-1)/4:(N-(N-1)/4); % Inds to save in center

% Initialize
tide_filt = zeros(size(tide));

% Loop over 4096 hour segments, 50% overlap, using just center 50% to avoid
% edge effects (note half-hourly data)
num_loops = floor(length(tide)/(N_short/2));
for ll = 1:num_loops-1
    
    % get a record from the tide series (50% overlap)
    inds_get = (ll-1)*N_short/2+1:(ll-1)*N_short/2+N;
    data = tide(inds_get);
    
    % Demean
    data_mean = mean(data);
    data = data - data_mean;
    %data = detrend(data);
    
    % Apply window
    win = hanning(N)';
    y = data.*win;
    
    % FFT
    yf = fft(y);
    
    % Create freq axes for one side
    f = 0:1/(N*dt):df/2;
    
    % Create freq that aligns with yf
    % f_raw = [0 f(2:end) fliplr(f(2:end))];
    
    % Loop over tide bands we want to filter
    yf_filt = yf; % initialize
    for t_num = 1:length(filt_fr_cen)
        t_downfr = .3; % Distance down freq from peak to use for variance estimate [cpd]
        t_fr = filt_fr_cen(t_num);
        t_bandwidth = filt_bw(t_num)/2; %One-sided bandwidth
        
        % Fill tide band with random noise similar to spectra nearby
        yf_filt = remove_band(yf_filt, f, t_fr, t_bandwidth, t_downfr );
    end
    
    % Reconstruct time series and adjust for window
    y_filt = ifft(yf_filt)./win;
    
    % Smooth with 3-point triangular
    y_filt = conv(y_filt,triang(6)/sum(triang(6)),'same');
        
    % Extract 50% center and save to out vector
    tide_filt(inds_get(cen_inds)) = y_filt(cen_inds);
        
end

% NaN out the first and last part of record where zero (edge effects)
tide_filt(1:(N-1)/4) = NaN;
tide_filt((ll-1)*N_short/2+N+1:end) = NaN;

end


function yf_filt = remove_band( yf, f, t_band, t_bandwidth, t_downfr )
% yf_filt = remove_band( yf, f, t_band, t_bandwidth, t_downfr )
%   Detailed explanation goes here

% Store first fft real entry (variance or mean)
first = yf(1);

% One-sided fft
N = length(yf);
yf1 = yf(2:(N+1)/2);
yf1r = real(yf1);
yf1i = imag(yf1);
f1 = f(2:end);

% Estimate down freq variance
I1 = findnearest(t_band+t_bandwidth,f1);
I2 = findnearest(t_band+t_bandwidth+t_downfr,f1);
yf1r_var = var(detrend(yf1r(I1:I2)));
yf1i_var = var(detrend(yf1i(I1:I2)));

% Estimate mean/trend at band
I1 = findnearest(t_band-t_bandwidth*2,f1);
I2 = findnearest(t_band+t_bandwidth*2,f1);
yf1r_fit = polyfit(f1(I1:I2),yf1r(I1:I2),1);
yf1i_fit = polyfit(f1(I1:I2),yf1i(I1:I2),1);

% Generate random signal to fill
I1 = findnearest(t_band-t_bandwidth,f1);
I2 = findnearest(t_band+t_bandwidth,f1);
x = f1(I1:I2);
yf1r_fill = yf1r_fit(2)+yf1r_fit(1)*x;
yf1r_fill = yf1r_fill + sqrt(yf1r_var)*randn(size(x));
yf1i_fill = yf1i_fit(2)+yf1i_fit(1)*x;
yf1i_fill = yf1i_fill + sqrt(yf1i_var)*randn(size(x));

% Sub in random signal
yf1r(I1:I2) = yf1r_fill;
yf1i(I1:I2) = yf1i_fill;

% Create two sided spectrum with zero mean (Note negative, second side must
% be complex conjugate)
yf_filt = complex([first yf1r fliplr(yf1r)],[0 yf1i -fliplr(yf1i)]);

end


