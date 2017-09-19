inds = zeros(1,length(RI));

yr_vec = 1:1:100;
inds_mat = zeros(length(yr_vec),length(RI));
wl_mat = inds_mat;
tic
% Find each location of 100 year water level
for j = 1:length(RI)
    for m = 1:length(yr_vec)
        % Grab one column of data
        vals = RI(:,j);
        % Find the location of each yearly water level
        temp_ind = findnearest(m,vals);
        temp_wl = x_axis(temp_ind(1));
        % Add it to the matrix 
        inds_mat(m,j) = temp_ind(1);
        wl_mat(m,j) = temp_wl;
    end
end

toc