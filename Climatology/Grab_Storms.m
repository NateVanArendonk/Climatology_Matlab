load('/Users/andrewmcauliffe/Desktop/Climatology/master_storm_structure.mat')


stn_nm = 'whidbey_nas';

data = master.(stn_nm);


%%  Generate ind vectors for each storm
%inds = NaN(length(data),1);

for j = 2:length(data)
    data{j,17}.inds = data{j,1}:data{j,2};
end


%%  