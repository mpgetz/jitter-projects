%Exploratory code for finding overlapping wave synch in spk data

%exclude waveforms with excessive continuous oscillation: 
% assume this suggests noise

examples = {};
templates = {};

%compute waveform templates by averaging and
%bound max by sum of largest waveform averages
%for i=1:length(wvs)
for i=2:2
    %compute template waves
    clu_set = unique(clus{i});
    %remove '0' cluster
    clu_set = clu_set(find(clu_set));

    avg = [];
    avgs = [];
    for j=1:length(clu_set)
        avg = mean(wvs{i}(:, :, find(clus{i}==clu_set(j))), 3);
        avgs = [avgs, avg];
    end
    templates{i} = reshape(avgs, 8, 54, []);
    %sort template waves 

    %for wv=1:size(wvs{i}, 3)
    %    if isempty(find(max(wvs{i}(:, :, wv))>200))
    %        candidates = [candidates, wvs{i}(:, :, wv)];
    %    end
    %end
    %examples{i} = candidates;
end

%perform matching and subtraction based on location
% of largest peaks to generate candidates


%perform stat analysis to generate examples of extreme synch
