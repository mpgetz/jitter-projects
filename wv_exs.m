%function to try reclustering noise from curated examples of varying lag

%clu_set = self.clu_set;
%subset = find(clu_set ~= 0 & clu_set ~= 1);
%clu_set = clu_set(subset);

c1 = 5;
c2 = 7;

new_clus = {};
lags = [-26:1:27];
shank = 1;

for i=1:54
    %using 50 templates for cluster creation; based on approx. lower bound 
    % of num spikes/cluster
    wv1 = wvs{shank}(:, :, randsample(find(clus{shank}==c1), 50));
    wv2 = wvs{shank}(:, :, randsample(find(clus{shank}==c2), 50));
    if lags(i) >= 0
        new_clus{i} = wv1 + [wv2(:, (54-lags(i)):end, :), wv2(:, 1:54-(lags(i)+1), :)];
    else
        new_clus{i} = wv1 + [wv2(:, (54+lags(i))+1:end, :), wv2(:, 1:54+lags(i), :)];
    end
end

%re-perform PCA
%extend clus and wvs
surr_clu_set = unique(clus{1});
n = length(new_clus);
surr_clus = [1:n]+max(unique(clus{1}));
surr_clus = repmat(surr_clus', 1, 50);
surr_clus = reshape(surr_clus, 1, []);

%attempt to recluster noise
noise = wvs{1}(:, :, find(clus{1}==1));
for n=1:length(noise)
    %nothing
end
